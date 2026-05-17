import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/checkin_repository.dart';
import '../../data/profile.dart';
import '../../data/profile_repository.dart';
import '../../theme/app_tokens.dart';

/// Today's-focus dashboard.
///
/// Reflects the user's most recent check-in. Once the rules engine lands
/// (Phase 4), the day_type + three zone-action strings will derive from
/// that check-in. For now they're a static placeholder.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final profile = ref.watch(currentProfileProvider).maybeWhen(
          data: (p) => p,
          orElse: () => null,
        );
    final checkin = ref.watch(todayCheckinProvider).maybeWhen(
          data: (c) => c,
          orElse: () => null,
        );

    final greeting = profile?.displayName?.trim().isNotEmpty == true
        ? 'Morning, ${profile!.displayName!.trim()}.'
        : 'Morning.';

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
            Text(greeting, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'One thing at a time today.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _FocusCard(checkin: checkin),
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

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.checkin});

  final CheckIn? checkin;

  String _zoneLabel(Zone z) {
    switch (z) {
      case Zone.self:
        return 'Self';
      case Zone.purpose:
        return 'Purpose';
      case Zone.lovedOnes:
        return 'Loved Ones';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final hasCheckin = checkin != null;
    final headline = hasCheckin
        ? '${_zoneLabel(checkin!.focusZone)} · today'
        : "Today's check-in is waiting";
    final caption = hasCheckin
        ? 'Pick one thing below. Ignore the rest.'
        : 'Tap the Check in button. A minute is plenty.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Today's focus",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                ),
              ),
              if (hasCheckin) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            headline,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            caption,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.85),
            ),
          ),
        ],
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
