import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/supabase/supabase_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase using AppConfig credentials
  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: GoPrintApp(),
    ),
  );
}
