/// Supabase project configuration.
///
/// **Both values below are safe to ship in the client app.** The publishable
/// key (formerly called "anon key") is designed to live in client code; it
/// authorises Supabase Auth + RLS-gated table access only. Row-Level Security
/// is what protects your data, not the secrecy of this key.
///
/// What MUST never appear here:
///   - service_role key (bypasses all RLS — server-side only)
///   - database password
///   - OpenAI API key (server-side, set via `supabase secrets set`)
///
/// Before public release: move both values to `--dart-define` build flags and
/// gitignore this file, so a forked repo doesn't carry the project URL.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://fpgadotiobvesybkeemz.supabase.co';
  static const String publishableKey =
      'sb_publishable_Cz2IrmRbc69Z8MhTPVmrUA_GbgqbKNK';

  /// Google Cloud Console OAuth 2.0 "Web application" client ID.
  /// Required by `signInWithIdToken` to verify the Google ID token
  /// returned by `google_sign_in`. The Android OAuth client (with
  /// package id + SHA-1) is registered separately and does not need
  /// to be referenced from Dart.
  /// Safe to ship in the client — the Client ID is public; only the
  /// matching Client Secret is sensitive (lives in Supabase only).
  static const String googleWebClientId =
      '304653422207-9ae4jrbmfc3lp5djri1ehhjrrtreajuc.apps.googleusercontent.com';
}
