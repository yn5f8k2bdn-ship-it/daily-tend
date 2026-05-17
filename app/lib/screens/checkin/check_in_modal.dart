import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/checkin_repository.dart';
import '../../data/onboarding_content.dart';
import '../../data/profile.dart' as model;
import '../../theme/app_tokens.dart';
import '../../widgets/five_point_scale.dart';
import '../../widgets/zone_segmented.dart';

/// Modal bottom-sheet daily check-in.
///
/// Submits to Supabase `check_ins` via `CheckinRepository`. Idempotent on
/// `(user_id, local_date)` — re-opening and resubmitting on the same day
/// overwrites today's row rather than erroring.
class CheckInModal extends ConsumerStatefulWidget {
  const CheckInModal({super.key});

  @override
  ConsumerState<CheckInModal> createState() => _CheckInModalState();
}

class _CheckInModalState extends ConsumerState<CheckInModal> {
  int? _mood;
  int? _stress;
  int? _energy;
  int? _sleep;
  String? _focusZone;
  final _noteController = TextEditingController();
  bool _submitting = false;

  bool get _canSubmit =>
      _mood != null &&
      _stress != null &&
      _energy != null &&
      _sleep != null &&
      _focusZone != null &&
      !_submitting;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final zone = model.Zone.fromWire(_focusZone);
    if (zone == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(checkinRepositoryProvider).submitToday(
            mood: _mood!,
            stress: _stress!,
            energy: _energy!,
            sleep: _sleep!,
            focusZone: zone,
            reflectionNote: _noteController.text,
          );
      ref.invalidate(todayCheckinProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Done. Your day's on the home screen. No need to hurry.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                  onPressed: _canSubmit ? _submit : null,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save check-in'),
                ),
              ),
            ],
          ),
        );
      },
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
