import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/onboarding_content.dart';
import '../../data/profile.dart' as model;
import '../../data/profile_repository.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/onboarding_scaffold.dart';

/// Onboarding step 6 of 6 — coaching tone. Persists the chosen tone and
/// flips `onboarding_complete = true`, which triggers the router redirect
/// to push the user onto `/home`.
class OnboardingToneScreen extends ConsumerStatefulWidget {
  const OnboardingToneScreen({super.key});

  @override
  ConsumerState<OnboardingToneScreen> createState() =>
      _OnboardingToneScreenState();
}

class _OnboardingToneScreenState extends ConsumerState<OnboardingToneScreen> {
  String? _selectedToneId;
  bool _saving = false;

  Future<void> _finish() async {
    if (_saving || _selectedToneId == null) return;
    final tone = model.CoachingTone.fromWire(_selectedToneId!);
    if (tone == null) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateCoachingTone(tone);
      await repo.markOnboardingComplete();
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You're in. Let's start with a quick check-in."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Router redirect will route based on onboardingComplete=true, but
      // we also push explicitly so the user doesn't see a flicker.
      context.go('/home');
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingScaffold(
      stepIndex: 6,
      headline: 'How should we talk to you?',
      subhead: 'Pick the one that feels right today. You can change it any time in Settings.',
      helper: 'All four are kind. They just land differently.',
      primaryLabel: 'Finish setup',
      canContinue: _selectedToneId != null && !_saving,
      onContinue: _finish,
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
