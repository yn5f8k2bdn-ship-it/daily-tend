import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_constants.dart';
import '../../theme/app_tokens.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Brand lockup — wordmark + tagline + three-zone illustrations.
              Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.contain,
                semanticLabel:
                    '$kAppName. Tend to yourself. Live your purpose. '
                    'Love your people.',
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'A minute a day. One small thing across your health, your '
                'work, and the people you love.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google sign-in lands in Phase 1.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonal(
                onPressed: () => context.go('/onboarding/name'),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: const Text('Continue with email'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'By continuing you agree to our Terms and Privacy Policy. '
                "$kAppName isn't medical advice.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
