import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/onboarding_content.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/onboarding_scaffold.dart';

/// Onboarding step 2 of 6 — main goal(s).
///
/// Multi-select up to [_maxSelections]. Founder spec change 2026-04-29:
/// originally single-select per `docs/content/goals.md` §1; widened to allow
/// 2–3 picks so the rules engine can blend zone affinities (e.g. "more
/// energy" + "show up for family" weights both Self and Loved Ones).
class OnboardingGoalScreen extends StatefulWidget {
  const OnboardingGoalScreen({super.key});

  @override
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen> {
  static const _maxSelections = 3;
  final Set<String> _selected = {};

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (_selected.length < _maxSelections) {
        _selected.add(id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Three is plenty. Unpick one to swap.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final n = _selected.length;
    final counterText = switch (n) {
      0 => 'One is fine. Three is the most.',
      1 => '1 picked.',
      2 => '2 picked.',
      _ => "3 picked — that's the most.",
    };

    return OnboardingScaffold(
      stepIndex: 2,
      headline: 'What brought you here?',
      subhead: 'One, two, or three — whatever fits. You can change them later.',
      helper: "We'll weight what we suggest around the ones you pick.",
      primaryLabel: 'Continue',
      canContinue: _selected.isNotEmpty,
      onContinue: () => context.go('/onboarding/stress'),
      skipDestination: '/onboarding/stress',
      skipLabel: "I'll decide later",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selection counter
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              counterText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          ...kGoals.map((goal) {
            final selected = _selected.contains(goal.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InkWell(
                onTap: () => _toggle(goal.id),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: selected ? cs.primaryContainer : cs.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: selected
                        ? null
                        : Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: selected ? cs.primary : cs.outline,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: selected
                                    ? cs.onPrimaryContainer
                                    : cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              goal.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: selected
                                    ? cs.onPrimaryContainer
                                        .withValues(alpha: 0.75)
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
