import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../checkin/check_in_modal.dart';

/// Persistent bottom-nav shell wrapping Home / Progress / Coach / Settings.
///
/// Per design system §8: 4 tabs (no Check-in tab). FAB is only shown on Home
/// and Progress. Check-in is the verb of the app, surfaced via the FAB and
/// opening a modal bottom sheet over the current tab.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (label: 'Home', icon: Icons.home_outlined, selected: Icons.home),
    (
      label: 'Progress',
      icon: Icons.show_chart_outlined,
      selected: Icons.show_chart,
    ),
    (label: 'Coach', icon: Icons.chat_outlined, selected: Icons.chat),
    (label: 'Settings', icon: Icons.settings_outlined, selected: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final i = navigationShell.currentIndex;
    final showFab = i == 0 || i == 1;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () => _openCheckIn(context),
              icon: const Icon(Icons.add),
              label: const Text('Check in'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (idx) => navigationShell.goBranch(
          idx,
          initialLocation: idx == navigationShell.currentIndex,
        ),
        destinations: [
          for (final item in _items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selected),
              label: item.label,
            ),
        ],
      ),
    );
  }

  void _openCheckIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CheckInModal(),
    );
  }
}
