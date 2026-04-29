import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/onboarding_content.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/five_point_scale.dart';
import '../../widgets/onboarding_scaffold.dart';

/// Onboarding step 4 of 6 — energy baseline.
class OnboardingEnergyScreen extends StatefulWidget {
  const OnboardingEnergyScreen({super.key});

  @override
  State<OnboardingEnergyScreen> createState() => _OnboardingEnergyScreenState();
}

class _OnboardingEnergyScreenState extends State<OnboardingEnergyScreen> {
  int? _value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingScaffold(
      stepIndex: 4,
      headline: 'And your energy?',
      subhead: 'Same idea — how it usually is, not today.',
      helper: "Low energy isn't a failure. It's information.",
      primaryLabel: 'Continue',
      canContinue: _value != null,
      onContinue: () => context.go('/onboarding/sleep'),
      skipDestination: '/onboarding/sleep',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FivePointScale(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            extremeLabels: const ['Empty', 'Full tank'],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_value != null)
            Text(
              ScaleLabels.energy[_value! - 1],
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
