import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// AI coach screen — empty/placeholder state.
///
/// Phase 4 wires `generate_coach_reply` Edge Function + streaming chat UI.
class CoachScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Talk to the coach.',
                style: theme.textTheme.headlineMedium,
              ),
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
                children: _starters
                    .map((s) => ActionChip(
                          label: Text(s),
                          onPressed: () =>
                              _showComingSoon(context),
                        ))
                    .toList(),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: cs.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Coach lands in Phase 4.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(Icons.send_outlined, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Coach isn't medical advice. If something's urgent, talk to a "
                'real person.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coach lands in Phase 4 — Edge Function + streaming chat.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
