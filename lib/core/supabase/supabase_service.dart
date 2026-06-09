// lib/core/supabase/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  /// Initialize Supabase client
  static Future<void> initialize() async {
    if (!AppConfig.isValid) {
      throw StateError(
        'Supabase URL and Anon Key are not configured. '
        'Please pass them via --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
      );
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  /// Get active Supabase client instance
  SupabaseClient get client => Supabase.instance.client;
}

/// Riverpod provider for SupabaseClient
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService().client;
});
