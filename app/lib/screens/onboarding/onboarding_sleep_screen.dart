import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/onboarding_content.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/five_point_scale.dart';
import '../../widgets/onboarding_scaffold.dart';

/// Onboarding step 5 of 6 — sleep quality baseline.
class OnboardingSleepScreen extends StatefulWidget {
  const OnboardingSleepScreen({super.key});

  @override
  State<OnboardingSleepScreen> createState() => _OnboardingSleepScreenState();
}

class _OnboardingSleepScreenState extends State<OnboardingSleepScreen> {
  int? _value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingScaffold(
      stepIndex: 5,
      headline: "How's your sleep these days?",
      subhead: 'Rough guess is fine.',
      helper: "Sleep touches everything else. We'll keep an eye on it.",
      primaryLabel: 'Continue',
      canContinue: _value != null,
      onContinue: () => context.go('/onboarding/tone'),
      skipDestination: '/onboarding/tone',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FivePointScale(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            extremeLabels: const ['Broken', 'Solid'],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_value != null)
            Text(
              ScaleLabels.sleep[_value! - 1],
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
