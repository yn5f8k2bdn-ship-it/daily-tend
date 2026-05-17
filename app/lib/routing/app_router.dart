import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import '../auth/auth_providers.dart';
import '../data/profile.dart';
import '../data/profile_repository.dart';
import '../screens/auth/sign_in_screen.dart';
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

/// A small `ChangeNotifier` that bridges Riverpod state changes to
/// GoRouter's `refreshListenable`. We notify whenever the signed-in
/// user or the cached profile changes; GoRouter then re-runs `redirect`.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen<User?>(
      currentUserProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
    _ref.listen<AsyncValue<Profile?>>(
      currentProfileProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }
  final Ref _ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavKey,
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(signedInProvider);
      final location = state.matchedLocation;
      final isAuthPage = location == '/' || location == '/auth';
      final isOnboarding = location.startsWith('/onboarding');

      if (!signedIn) {
        return isAuthPage ? null : '/';
      }

      // Signed in. Check onboarding state from the cached profile.
      final profileAsync = ref.read(currentProfileProvider);
      final onboardingComplete = profileAsync.when(
        data: (p) => p?.onboardingComplete,
        loading: () => null,
        error: (_, __) => null,
      );
      if (onboardingComplete == null) {
        // Profile still loading or errored. Don't bounce the user
        // around — stay put and re-evaluate when it resolves.
        return null;
      }

      if (!onboardingComplete) {
        return isOnboarding ? null : '/onboarding/name';
      }

      // Onboarding complete: keep authed users out of welcome / auth /
      // onboarding flows.
      if (isAuthPage || isOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const SignInScreen()),

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
});
