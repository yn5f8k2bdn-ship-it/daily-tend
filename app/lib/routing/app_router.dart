import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/coach/coach_screen.dart';
import '../screens/home/home_dashboard_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/onboarding/onboarding_energy_screen.dart';
import '../screens/onboarding/onboarding_goal_screen.dart';
import '../screens/onboarding/onboarding_name_screen.dart';
import '../screens/onboarding/onboarding_sleep_screen.dart';
import '../screens/onboarding/onboarding_stress_screen.dart';
import '../screens/onboarding/onboarding_tone_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/welcome/welcome_screen.dart';

final _rootNavKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavKey,
  routes: [
    GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),

    // Onboarding flow — linear, each step pushes to the next.
    GoRoute(
      path: '/onboarding/name',
      builder: (_, __) => const OnboardingNameScreen(),
    ),
    GoRoute(
      path: '/onboarding/goal',
      builder: (_, __) => const OnboardingGoalScreen(),
    ),
    GoRoute(
      path: '/onboarding/stress',
      builder: (_, __) => const OnboardingStressScreen(),
    ),
    GoRoute(
      path: '/onboarding/energy',
      builder: (_, __) => const OnboardingEnergyScreen(),
    ),
    GoRoute(
      path: '/onboarding/sleep',
      builder: (_, __) => const OnboardingSleepScreen(),
    ),
    GoRoute(
      path: '/onboarding/tone',
      builder: (_, __) => const OnboardingToneScreen(),
    ),

    // Persistent bottom-nav shell wrapping the four main tabs.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (_, __) => const ProgressScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/coach', builder: (_, __) => const CoachScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
