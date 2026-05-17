import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_providers.dart';
import 'profile.dart';

/// Read/write access to the caller's row in `profiles`. All operations
/// run under the caller's JWT so Row-Level Security (`user_id = auth.uid()`)
/// is enforced.
class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  /// Fetch the current user's profile row. Returns null if no row exists
  /// (which shouldn't happen — the auth trigger seeds one — but is
  /// handled defensively).
  Future<Profile?> fetchCurrent() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return Profile.fromRow(row);
  }

  Future<void> updateDisplayName(String displayName) =>
      _update({'display_name': displayName.trim()});

  Future<void> updateGoal(String goal) =>
      _update({'goal': goal.trim()});

  Future<void> updateCoachingTone(CoachingTone tone) =>
      _update({'coaching_tone': tone.wireName});

  Future<void> updatePreferredZone(Zone zone) =>
      _update({'preferred_zone': zone.wireName});

  Future<void> markOnboardingComplete() =>
      _update({'onboarding_complete': true});

  Future<void> _update(Map<String, dynamic> patch) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Cannot update profile while signed out.');
    }
    await _client.from('profiles').update(patch).eq('user_id', userId);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

/// The current user's profile. Re-fetches when the user changes
/// (sign-in / sign-out). Invalidate after mutations to refresh.
/// Not autoDispose: the router redirect listens to this for the
/// lifetime of the app and we don't want it torn down between navs.
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  // Re-evaluate when auth state changes (e.g. sign-in switches user).
  ref.watch(currentUserProvider);
  return ref.watch(profileRepositoryProvider).fetchCurrent();
});
