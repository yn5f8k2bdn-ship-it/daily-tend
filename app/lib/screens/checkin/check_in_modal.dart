import 'package:flutter/material.dart';

import '../../data/onboarding_content.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/five_point_scale.dart';
import '../../widgets/zone_segmented.dart';

/// Modal bottom-sheet daily check-in.
///
/// Per design system §8 + copy library §3. Static for now — no persistence.
/// Phase 2 wires Drift cache + Supabase write-through.
class CheckInModal extends StatefulWidget {
  const CheckInModal({super.key});

  @override
  State<CheckInModal> createState() => _CheckInModalState();
}

class _CheckInModalState extends State<CheckInModal> {
  int? _mood;
  int? _stress;
  int? _energy;
  int? _sleep;
  String? _focusZone;
  final _noteController = TextEditingController();

  bool get _canSubmit =>
      _mood != null &&
      _stress != null &&
      _energy != null &&
      _sleep != null &&
      _focusZone != null;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  children: [
                    Text("Today's check-in", style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'A minute, tops. Be honest — nobody else sees this.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    _Section(
                      heading: "How's your mood right now?",
                      child: FivePointScale(
                        value: _mood,
                        onChanged: (v) => setState(() => _mood = v),
                        extremeLabels: const ['Low', 'Really good'],
                      ),
                      caption: _mood == null
                          ? null
                          : ScaleLabels.checkInMood[_mood! - 1],
                    ),
                    _Section(
                      heading: 'Stress level today?',
                      child: FivePointScale(
                        value: _stress,
                        onChanged: (v) => setState(() => _stress = v),
                        extremeLabels: const ['None', 'Overloaded'],
                      ),
                      caption: _stress == null
                          ? null
                          : ScaleLabels.checkInStress[_stress! - 1],
                    ),
                    _Section(
                      heading: 'Energy today?',
                      child: FivePointScale(
                        value: _energy,
                        onChanged: (v) => setState(() => _energy = v),
                        extremeLabels: const ['Empty', 'Firing'],
                      ),
                      caption: _energy == null
                          ? null
                          : ScaleLabels.checkInEnergy[_energy! - 1],
                    ),
                    _Section(
                      heading: "Last night's sleep?",
                      child: FivePointScale(
                        value: _sleep,
                        onChanged: (v) => setState(() => _sleep = v),
                        extremeLabels: const ['Broken', 'Solid'],
                      ),
                      caption: _sleep == null
                          ? null
                          : ScaleLabels.checkInSleep[_sleep! - 1],
                    ),
                    _Section(
                      heading: 'Where does your energy need to go today?',
                      subhead: "One zone. We'll build the day around it.",
                      child: ZoneSegmented(
                        selectedZoneId: _focusZone,
                        onChanged: (id) => setState(() => _focusZone = id),
                      ),
                    ),
                    _Section(
                      heading: 'Anything you want to note?',
                      subhead: 'Optional. One line is fine.',
                      child: TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'e.g. "Short on sleep, big meeting at 10."',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Submit button anchored at the bottom
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: FilledButton(
                  onPressed: _canSubmit ? () => _submit(context) : null,
                  child: const Text('Save check-in'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Done. Your day's on the home screen. No need to hurry."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.heading,
    this.subhead,
    required this.child,
    this.caption,
  });

  final String heading;
  final String? subhead;
  final Widget child;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(heading, style: theme.textTheme.titleMedium),
          if (subhead != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subhead!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          child,
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(caption!, style: theme.textTheme.titleSmall),
            ),
          ],
        ],
      ),
    );
  }
}
