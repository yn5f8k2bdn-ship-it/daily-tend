import 'package:flutter/material.dart';

import '../data/onboarding_content.dart';
import '../theme/app_tokens.dart';

/// Three-segment zone picker (Self / Purpose / Loved Ones).
///
/// Per design system §8: "All three segments are equal width — no
/// default-selected primary zone." Selected segment uses the zone's
/// container fill; unselected segments are outlined.
class ZoneSegmented extends StatelessWidget {
  const ZoneSegmented({
    super.key,
    required this.selectedZoneId,
    required this.onChanged,
  });

  final String? selectedZoneId;
  final ValueChanged<String> onChanged;

  Color _zoneContainer(BuildContext context, String id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (id) {
      'self' =>
        isDark ? AppColors.zoneSelfContainerDark : AppColors.zoneSelfContainer,
      'purpose' => isDark
          ? AppColors.zonePurposeContainerDark
          : AppColors.zonePurposeContainer,
      'loved_ones' => isDark
          ? AppColors.zoneLovedOnesContainerDark
          : AppColors.zoneLovedOnesContainer,
      _ => Theme.of(context).colorScheme.surfaceContainerLow,
    };
  }

  IconData _zoneIcon(String id, {required bool filled}) {
    return switch (id) {
      'self' => filled ? Icons.self_improvement : Icons.self_improvement_outlined,
      'purpose' => filled ? Icons.flag : Icons.flag_outlined,
      'loved_ones' => filled ? Icons.diversity_3 : Icons.diversity_3_outlined,
      _ => Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: kZones.map((z) {
        final selected = z.id == selectedZoneId;
        final bg = selected
            ? _zoneContainer(context, z.id)
            : theme.colorScheme.surface;
        final border = selected
            ? null
            : Border.all(color: theme.colorScheme.outlineVariant);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: InkWell(
            onTap: () => onChanged(z.id),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: border,
              ),
              child: Row(
                children: [
                  Icon(
                    _zoneIcon(z.id, filled: selected),
                    size: 28,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(z.label, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          z.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
    );
  }
}
