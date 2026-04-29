import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_constants.dart';
import '../../theme/app_tokens.dart';

/// Settings screen — placeholder list of section rows.
///
/// Phase 7 wires real toggles + actions (logout, delete account, etc.).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            _SectionLabel('Account'),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              subtitle: const Text('Name, goal, timezone'),
              onTap: () => _showComingSoon(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () => context.go('/'),
            ),
            const Divider(),
            _SectionLabel('Coaching'),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Coaching tone'),
              subtitle: const Text('Calm'),
              onTap: () => _showComingSoon(context),
            ),
            const Divider(),
            _SectionLabel('Reminders'),
            ListTile(
              leading: const Icon(Icons.alarm_outlined),
              title: const Text('Daily reminder'),
              subtitle: const Text("We'll nudge you once. No repeats."),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            const Divider(),
            _SectionLabel('Privacy'),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Private mode'),
              subtitle: const Text(
                'Hides your notes when someone else picks up your phone.',
              ),
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
            const Divider(),
            _SectionLabel('About'),
            ListTile(
              title: Text('$kAppName · pre-V1 prototype'),
              subtitle: const Text(
                "Coach isn't medical advice. If something's urgent, "
                'talk to a real person.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lands in Phase 7 — Settings polish.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
