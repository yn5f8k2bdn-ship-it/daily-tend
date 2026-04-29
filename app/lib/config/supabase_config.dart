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
}
