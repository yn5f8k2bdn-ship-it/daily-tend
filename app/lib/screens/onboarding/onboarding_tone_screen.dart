import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/onboarding_content.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/onboarding_scaffold.dart';

/// Onboarding step 6 of 6 — coaching tone.
class OnboardingToneScreen extends StatefulWidget {
  const OnboardingToneScreen({super.key});

  @override
  State<OnboardingToneScreen> createState() => _OnboardingToneScreenState();
}

class _OnboardingToneScreenState extends State<OnboardingToneScreen> {
  String? _selectedToneId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingScaffold(
      stepIndex: 6,
      headline: 'How should we talk to you?',
      subhead: 'Pick the one that feels right today. You can change it any time in Settings.',
      helper: 'All four are kind. They just land differently.',
      primaryLabel: 'Finish setup',
      canContinue: _selectedToneId != null,
      onContinue: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You're in. Let's start with a quick check-in."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/home');
      },
      skipDestination: '/home',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: kCoachingTones.map((tone) {
          final selected = _selectedToneId == tone.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              onTap: () => setState(() => _selectedToneId = tone.id),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: selected
                      ? null
                      : Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          tone.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: selected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tone.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: selected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            tone.example,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: selected
                                  ? theme.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.75)
                                  : theme.colorScheme.onSurfaceVariant,
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
        }).toList(),
      ),
    );
  }
}
