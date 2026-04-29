import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/onboarding_content.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/five_point_scale.dart';
import '../../widgets/onboarding_scaffold.dart';

/// Onboarding step 3 of 6 — stress baseline.
class OnboardingStressScreen extends StatefulWidget {
  const OnboardingStressScreen({super.key});

  @override
  State<OnboardingStressScreen> createState() => _OnboardingStressScreenState();
}

class _OnboardingStressScreenState extends State<OnboardingStressScreen> {
  int? _value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingScaffold(
      stepIndex: 3,
      headline: 'Lately, how stressed do you feel?',
      subhead: 'On most days, not today specifically.',
      helper: "This sets your starting point. It'll move over time.",
      primaryLabel: 'Continue',
      canContinue: _value != null,
      onContinue: () => context.go('/onboarding/energy'),
      skipDestination: '/onboarding/energy',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FivePointScale(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            extremeLabels: const ['Calm', 'Running hot'],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_value != null)
            Text(
              ScaleLabels.stress[_value! - 1],
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
