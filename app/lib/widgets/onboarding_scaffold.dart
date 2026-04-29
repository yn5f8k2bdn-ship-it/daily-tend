import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_tokens.dart';

/// Shared chrome for onboarding steps 1-6.
///
/// - Top: Back / Skip buttons + step counter
/// - Body: caller's content
/// - Bottom: primary CTA (disabled until [canContinue] is true)
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.stepIndex, // 1..6
    required this.headline,
    this.subhead,
    this.helper,
    required this.body,
    required this.primaryLabel,
    required this.canContinue,
    required this.onContinue,
    this.skipDestination,
    this.skipLabel = 'Skip',
  });

  static const int totalSteps = 6;

  final int stepIndex;
  final String headline;
  final String? subhead;
  final String? helper;
  final Widget body;
  final String primaryLabel;
  final bool canContinue;
  final VoidCallback onContinue;
  final String? skipDestination;
  final String skipLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: stepIndex > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
        actions: [
          if (skipDestination != null)
            TextButton(
              onPressed: () => context.go(skipDestination!),
              child: Text(skipLabel),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Step $stepIndex of $totalSteps',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(headline, style: theme.textTheme.headlineLarge),
              if (subhead != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  subhead!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (helper != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  helper!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(child: body),
              ),
              FilledButton(
                onPressed: canContinue ? onContinue : null,
                child: Text(primaryLabel),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
