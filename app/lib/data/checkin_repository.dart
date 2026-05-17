import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_providers.dart';
import 'profile.dart';

/// One day's check-in row. Mirrors the columns the app cares about
/// from `check_ins` — there are a few server-managed fields (`id`,
/// `created_at`) we don't read on the client today.
class CheckIn {
  const CheckIn({
    required this.userId,
    required this.mood,
    required this.stress,
    required this.energy,
    required this.sleep,
    required this.habitCompletion,
    required this.focusZone,
    required this.localDate,
    this.reflectionNote,
  });

  final String userId;
  final int mood;
  final int stress;
  final int energy;
  final int sleep;
  final bool habitCompletion;
  final Zone focusZone;
  final String localDate; // YYYY-MM-DD in the user's local timezone
  final String? reflectionNote;

  factory CheckIn.fromRow(Map<String, dynamic> row) {
    return CheckIn(
      userId: row['user_id'] as String,
      mood: row['mood'] as int,
      stress: row['stress'] as int,
      energy: row['energy'] as int,
      sleep: row['sleep'] as int,
      habitCompletion: (row['habit_completion'] as bool?) ?? false,
      focusZone: Zone.fromWire(row['focus_zone'] as String?)!,
      localDate: row['local_date'] as String,
      reflectionNote: row['reflection_note'] as String?,
    );
  }
}

/// Read/write access to `check_ins`. All operations run under the
/// user's JWT so RLS enforces `user_id = auth.uid()`.
class CheckinRepository {
  CheckinRepository(this._client);

  final SupabaseClient _client;

  /// User's local-calendar date as `YYYY-MM-DD`. The Postgres `local_date`
  /// column is what the unique-per-day constraint is checked against —
  /// it must reflect the user's wall-clock date, not UTC.
  static String _todayLocal() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Upsert today's check-in. If the user has already checked in today
  /// (rare but possible if they re-open the modal), the existing row
  /// is overwritten rather than erroring on the unique constraint.
  Future<void> submitToday({
    required int mood,
    required int stress,
    required int energy,
    required int sleep,
    required Zone focusZone,
    bool habitCompletion = false,
    String? reflectionNote,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Cannot submit a check-in while signed out.');
    }
    final note = reflectionNote?.trim();
    await _client.from('check_ins').upsert(
      {
        'user_id': userId,
        'mood': mood,
        'stress': stress,
        'energy': energy,
        'sleep': sleep,
        'habit_completion': habitCompletion,
        'focus_zone': focusZone.wireName,
        'reflection_note': (note == null || note.isEmpty) ? null : note,
        'local_date': _todayLocal(),
      },
      onConflict: 'user_id,local_date',
    );
  }

  /// Today's check-in row for the current user, or null if not yet done.
  Future<CheckIn?> fetchToday() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('check_ins')
        .select()
        .eq('user_id', userId)
        .eq('local_date', _todayLocal())
        .maybeSingle();
    if (row == null) return null;
    return CheckIn.fromRow(row);
  }
}

final checkinRepositoryProvider = Provider<CheckinRepository>((ref) {
  return CheckinRepository(ref.watch(supabaseClientProvider));
});

/// Today's check-in for the current user. Invalidate after a submit.
final todayCheckinProvider = FutureProvider<CheckIn?>((ref) async {
  ref.watch(currentUserProvider);
  return ref.watch(checkinRepositoryProvider).fetchToday();
});
