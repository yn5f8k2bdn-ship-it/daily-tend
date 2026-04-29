import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/onboarding_scaffold.dart';

/// Onboarding step 1 of 6 — name capture.
class OnboardingNameScreen extends StatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  final _controller = TextEditingController();
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _canContinue) {
        setState(() => _canContinue = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      stepIndex: 1,
      headline: 'What should we call you?',
      subhead: "First name is fine. Nickname's fine too.",
      helper: 'Used in check-ins and reminders. Only you see it.',
      primaryLabel: 'Continue',
      canContinue: _canContinue,
      onContinue: () => context.go('/onboarding/goal'),
      skipDestination: '/onboarding/goal',
      body: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: const InputDecoration(labelText: 'Your name'),
        onSubmitted: (_) {
          if (_canContinue) context.go('/onboarding/goal');
        },
      ),
    );
  }
}
