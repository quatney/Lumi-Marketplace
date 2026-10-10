/// Compile-time Supabase connection settings.
///
/// Supply these with `--dart-define-from-file=supabase.env.json`. The example
/// file is safe to commit; the project-specific file is ignored by Git.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
