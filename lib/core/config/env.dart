/// Compile-time environment configuration.
///
/// Values are injected with `--dart-define` (see `.vscode/launch.json`) so that
/// no secrets are committed to source. The anon key is a *public* client key,
/// safe to ship in the app; all privileged access is gated by Supabase RLS.
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Fail fast on a misconfigured launch rather than crashing deep inside the
  /// Supabase SDK with an opaque error.
  static void assertConfigured() {
    assert(
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
      'Missing SUPABASE_URL / SUPABASE_ANON_KEY. Run with --dart-define '
      '(see .vscode/launch.json).',
    );
  }
}
