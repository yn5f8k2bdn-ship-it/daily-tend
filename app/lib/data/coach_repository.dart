import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_providers.dart';

/// Who said it. Mirrors the `message_role` Postgres enum.
enum MessageRole {
  user,
  coach;

  String get wireName => name; // both happen to match the enum literals

  static MessageRole? fromWire(String? wire) {
    switch (wire) {
      case 'user':
        return MessageRole.user;
      case 'coach':
        return MessageRole.coach;
    }
    return null;
  }
}

/// One row in `coach_messages`, plus optional ephemeral `actions` for the
/// most-recent coach reply (the table itself only stores the text).
class CoachMessage {
  const CoachMessage({
    required this.role,
    required this.content,
    required this.createdAt,
    this.actions = const [],
  });

  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final List<String> actions;

  factory CoachMessage.fromRow(Map<String, dynamic> row) {
    return CoachMessage(
      role: MessageRole.fromWire(row['role'] as String?) ?? MessageRole.coach,
      content: row['content'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

/// What the `generate_coach_reply` Edge Function returns on success.
class CoachReply {
  const CoachReply({required this.reply, required this.actions});
  final String reply;
  final List<String> actions;
}

/// Talks to the `generate_coach_reply` Edge Function and reads from
/// `coach_messages`. All operations run under the caller's JWT so RLS
/// scopes message reads to the signed-in user.
class CoachRepository {
  CoachRepository(this._client);

  final SupabaseClient _client;

  /// Chronological transcript for the current user. Cold-start hydration.
  Future<List<CoachMessage>> fetchHistory({int limit = 100}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await _client
        .from('coach_messages')
        .select('role, content, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: true)
        .limit(limit);
    return [for (final row in rows) CoachMessage.fromRow(row)];
  }

  /// Send a user turn and return the coach's parsed reply. The Edge
  /// Function persists BOTH the user message and the coach reply to
  /// `coach_messages` server-side, so the client doesn't need to write.
  Future<CoachReply> sendMessage(String userMessage) async {
    final res = await _client.functions.invoke(
      'generate_coach_reply',
      body: {'user_message': userMessage},
    );
    if (res.status < 200 || res.status >= 300) {
      final data = res.data;
      final msg = (data is Map && data['detail'] is String)
          ? data['detail'] as String
          : (data is Map && data['error'] is String)
              ? data['error'] as String
              : 'Coach call failed (HTTP ${res.status}).';
      throw Exception(msg);
    }
    final data = res.data;
    if (data is! Map) {
      throw Exception('Coach returned an unexpected shape: $data');
    }
    final reply = (data['reply'] as String?)?.trim() ?? '';
    final actionsRaw = data['actions'];
    final actions = <String>[
      if (actionsRaw is List)
        for (final a in actionsRaw)
          if (a is String && a.trim().isNotEmpty) a.trim(),
    ];
    if (reply.isEmpty) {
      throw Exception('Coach returned an empty reply.');
    }
    return CoachReply(reply: reply, actions: actions);
  }
}

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepository(ref.watch(supabaseClientProvider));
});

/// Live transcript for the Coach screen. Loads history on init and
/// appends user + coach messages as they're sent.
class CoachNotifier extends AsyncNotifier<List<CoachMessage>> {
  @override
  Future<List<CoachMessage>> build() async {
    // Re-evaluate when the signed-in user changes.
    ref.watch(currentUserProvider);
    return ref.read(coachRepositoryProvider).fetchHistory();
  }

  /// Append the user's turn optimistically, call the Edge Function,
  /// then append the coach reply. On error, rolls back the optimistic
  /// message so the UI doesn't show a turn the server didn't receive.
  Future<void> send(String userMessage) async {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) return;
    final repo = ref.read(coachRepositoryProvider);
    final before = state.value ?? const <CoachMessage>[];

    final now = DateTime.now();
    final optimistic = CoachMessage(
      role: MessageRole.user,
      content: trimmed,
      createdAt: now,
    );
    state = AsyncData([...before, optimistic]);

    try {
      final reply = await repo.sendMessage(trimmed);
      state = AsyncData([
        ...state.value ?? const [],
        CoachMessage(
          role: MessageRole.coach,
          content: reply.reply,
          createdAt: DateTime.now(),
          actions: reply.actions,
        ),
      ]);
    } catch (e) {
      // Roll back the optimistic user turn so the UI matches the server.
      state = AsyncData(before);
      rethrow;
    }
  }
}

final coachNotifierProvider =
    AsyncNotifierProvider<CoachNotifier, List<CoachMessage>>(
  CoachNotifier.new,
);
