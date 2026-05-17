import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/profile_repository.dart';
import '../../widgets/onboarding_scaffold.dart';

/// Onboarding step 1 of 6 — name capture.
class OnboardingNameScreen extends ConsumerStatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  ConsumerState<OnboardingNameScreen> createState() =>
      _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends ConsumerState<OnboardingNameScreen> {
  final _controller = TextEditingController();
  bool _canContinue = false;
  bool _saving = false;

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

  Future<void> _continue() async {
    if (_saving || !_canContinue) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateDisplayName(_controller.text);
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      context.go('/onboarding/goal');
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
    return OnboardingScaffold(
      stepIndex: 1,
      headline: 'What should we call you?',
      subhead: "First name is fine. Nickname's fine too.",
      helper: 'Used in check-ins and reminders. Only you see it.',
      primaryLabel: 'Continue',
      canContinue: _canContinue && !_saving,
      onContinue: _continue,
      skipDestination: '/onboarding/goal',
      body: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: const InputDecoration(labelText: 'Your name'),
        onSubmitted: (_) => _continue(),
      ),
    );
  }
}
