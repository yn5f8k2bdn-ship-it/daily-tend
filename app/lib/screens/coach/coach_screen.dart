import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/coach_repository.dart';
import '../../theme/app_tokens.dart';

/// AI coach screen — chat transcript + input. Posts each user turn to
/// the `generate_coach_reply` Edge Function (which persists both sides
/// of the exchange server-side, then returns the coach reply + actions).
class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  static const _starters = [
    'I had a rough day.',
    "I can't get started.",
    'Help me wind down.',
    "I'm overthinking something.",
    'What should I do in 10 minutes?',
    'I feel flat.',
  ];

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    if (_sending) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _inputController.clear();
    setState(() => _sending = true);
    _scrollToBottom();

    try {
      await ref.read(coachNotifierProvider.notifier).send(trimmed);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coach didn\'t answer: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final transcript = ref.watch(coachNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: transcript.when(
                data: (messages) => _Transcript(
                  messages: messages,
                  scrollController: _scrollController,
                  onStarterTap: _sending ? null : _send,
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Could not load the coach transcript.\n$e',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
            _InputBar(
              controller: _inputController,
              sending: _sending,
              onSend: _send,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                "Coach isn't medical advice. If something's urgent, talk to a "
                'real person.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Transcript extends StatelessWidget {
  const _Transcript({
    required this.messages,
    required this.scrollController,
    required this.onStarterTap,
  });

  final List<CoachMessage> messages;
  final ScrollController scrollController;
  final void Function(String)? onStarterTap;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _EmptyState(onStarterTap: onStarterTap);
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        final showActions = msg.role == MessageRole.coach &&
            msg.actions.isNotEmpty &&
            i == messages.length - 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: msg.role == MessageRole.user
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              _Bubble(message: msg),
              if (showActions) ...[
                const SizedBox(height: AppSpacing.sm),
                _ActionChips(actions: msg.actions),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStarterTap});

  final void Function(String)? onStarterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text('Talk to the coach.', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ask anything — a rough morning, a stuck feeling, what to do '
            "about tonight. Short answers, no advice you didn't ask for.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Try one of these',
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: CoachScreen._starters
                .map(
                  (s) => ActionChip(
                    label: Text(s),
                    onPressed: onStarterTap == null ? null : () => onStarterTap!(s),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final CoachMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isUser = message.role == MessageRole.user;
    final bg = isUser ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fg = isUser ? cs.onPrimaryContainer : cs.onSurface;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.md),
            topRight: const Radius.circular(AppRadius.md),
            bottomLeft: Radius.circular(isUser ? AppRadius.md : AppRadius.xs),
            bottomRight: Radius.circular(isUser ? AppRadius.xs : AppRadius.md),
          ),
        ),
        child: Text(
          message.content,
          style: theme.textTheme.bodyLarge?.copyWith(color: fg),
        ),
      ),
    );
  }
}

class _ActionChips extends StatelessWidget {
  const _ActionChips({required this.actions});
  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final action in actions)
          ActionChip(
            label: Text(action),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Noted. That's enough for now."),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
      ],
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final Future<void> Function(String) onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                enabled: !sending,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                decoration: const InputDecoration(
                  hintText: 'Say what\'s on your mind…',
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            IconButton(
              icon: sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              color: cs.primary,
              onPressed: sending ? null : () => onSend(controller.text),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}
