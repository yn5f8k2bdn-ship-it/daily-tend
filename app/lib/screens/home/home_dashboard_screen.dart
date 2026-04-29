import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Today's-focus dashboard.
///
/// Static skeleton — once Phase 1 auth + Phase 2 check-in persistence land,
/// the focus zone, day_type, and three zone-action strings come from the
/// rules engine output for the user's most recent check-in.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.huge,
          ),
          children: [
            Text('Morning.', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'One thing at a time today.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Today's focus card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's focus",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Self · Gentle day',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Pick one thing below. Ignore the rest.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Three small things',
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            const _ZoneActionCard(
              zoneId: 'self',
              zoneLabel: 'Self',
              actionText: 'Drink a full glass of water now.',
            ),
            const SizedBox(height: AppSpacing.md),
            const _ZoneActionCard(
              zoneId: 'purpose',
              zoneLabel: 'Purpose',
              actionText:
                  'Pick the smallest piece of work and finish only that.',
            ),
            const SizedBox(height: AppSpacing.md),
            const _ZoneActionCard(
              zoneId: 'loved_ones',
              zoneLabel: 'Loved Ones',
              actionText: "Send a one-line message to someone you've been "
                  'meaning to.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneActionCard extends StatelessWidget {
  const _ZoneActionCard({
    required this.zoneId,
    required this.zoneLabel,
    required this.actionText,
  });

  final String zoneId;
  final String zoneLabel;
  final String actionText;

  Color _accent(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (zoneId) {
      'self' => dark ? AppColors.zoneSelfDark : AppColors.zoneSelf,
      'purpose' => dark ? AppColors.zonePurposeDark : AppColors.zonePurpose,
      'loved_ones' =>
        dark ? AppColors.zoneLovedOnesDark : AppColors.zoneLovedOnes,
      _ => Theme.of(context).colorScheme.primary,
    };
  }

  IconData _icon() => switch (zoneId) {
        'self' => Icons.self_improvement,
        'purpose' => Icons.flag,
        'loved_ones' => Icons.diversity_3,
        _ => Icons.circle,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = _accent(context);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 4dp zone-color edge bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_icon(), size: 20, color: accent),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          zoneLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      actionText,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Nice. That's enough for $zoneLabel today.",
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Mark as done'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
