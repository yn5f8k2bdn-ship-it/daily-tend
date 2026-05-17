import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import 'auth_providers.dart';

/// Thin wrapper over the Supabase auth client + native Google Sign-In.
/// All UI auth actions (sign up, sign in, sign out) route through here.
class AuthController {
  AuthController(this._client);

  final SupabaseClient _client;

  static bool _googleInitialized = false;

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email.trim(), password: password);
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signInWithGoogle() async {
    if (SupabaseConfig.googleWebClientId.isEmpty) {
      throw StateError(
        'Google Sign-In is not configured: SupabaseConfig.googleWebClientId is empty. '
        'Set the Web OAuth client ID from Google Cloud Console before using this flow.',
      );
    }

    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: SupabaseConfig.googleWebClientId,
      );
      _googleInitialized = true;
    }

    final GoogleSignInAccount account =
        await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google Sign-In returned no ID token.');
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> signOut() async {
    if (_googleInitialized) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Non-fatal: still proceed with Supabase sign-out.
      }
    }
    await _client.auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(supabaseClientProvider));
});
