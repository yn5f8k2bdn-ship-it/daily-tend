import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The Supabase client. Initialised in `main.dart` before `runApp`.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Stream of Supabase auth state changes. Fires on sign-in, sign-out,
/// token refresh, and password recovery. The `AsyncValue` wrapper means
/// listeners see loading state on first build.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// The current authenticated user, or null if signed out.
/// Reads from `client.auth.currentUser` (synchronous) and also
/// re-evaluates whenever `authStateChangesProvider` ticks so that
/// listeners rebuild on sign-in / sign-out.
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(supabaseClientProvider).auth.currentUser;
});

/// True iff a user session exists. Derived shortcut for routing logic.
final signedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
