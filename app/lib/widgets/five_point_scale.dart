import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 5 evenly-spaced segmented pills (1..5).
///
/// Per design system §8:
///   "The 1–5 scale is discrete and emotional, not continuous. A slider
///   invites indecision. Five evenly-spaced 56 × 48 dp pills are thumb-sized,
///   announce as '1 of 5' to screen readers, and give instant feedback."
///
/// Optional `extremeLabels` shows tiny captions above pills 1 and 5 only —
/// the "struggling" / "thriving" pattern from the design system.
class FivePointScale extends StatelessWidget {
  const FivePointScale({
    super.key,
    required this.value,
    required this.onChanged,
    this.extremeLabels,
  });

  /// Currently-selected value, 1..5, or null for unset.
  final int? value;
  final ValueChanged<int> onChanged;

  /// `[lowLabel, highLabel]` shown above pills 1 and 5. Optional.
  final List<String>? extremeLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (extremeLabels != null && extremeLabels!.length == 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  extremeLabels![0],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  extremeLabels![1],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(5, (i) {
            final v = i + 1;
            final selected = value == v;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 4 ? 0 : AppSpacing.sm),
                child: _Pill(
                  value: v,
                  selected: selected,
                  onTap: () => onChanged(v),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bg = selected ? cs.primary : cs.surfaceContainerLowest;
    final fg = selected ? cs.onPrimary : cs.onSurface;
    final border = selected ? null : Border.all(color: cs.outlineVariant);

    return Semantics(
      label: '$value of 5',
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: border,
          ),
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
