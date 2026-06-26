import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/supabase/supabase_service.dart';
import 'features/shop/data/mock_shops.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase using AppConfig credentials
  await SupabaseService.initialize();

  // Sync shops from Supabase on startup
  try {
    await MockShops.syncFromSupabase();
  } catch (e) {
    debugPrint('Failed to sync shops on startup: $e');
  }

  runApp(
    const ProviderScope(
      child: GoPrintApp(),
    ),
  );
}
