// lib/core/config/app_config.dart

class AppConfig {
  /// Supabase project URL loaded from --dart-define
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://txbiojrukrjohnvptfli.supabase.co',
  );

  /// Supabase anonymous key loaded from --dart-define
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_Y-02BflEnFJL4fPPv0w2MQ_fDo273_L',
  );

  /// Helper to validate environment variables
  static bool get isValid {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}
