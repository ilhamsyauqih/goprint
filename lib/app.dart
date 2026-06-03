import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

/// Root widget aplikasi GoPrint.
///
/// Menggunakan [MaterialApp.router] dengan go_router untuk navigasi
/// deklaratif, serta dukungan Light Mode & Dark Mode.
class GoPrintApp extends StatelessWidget {
  const GoPrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GoPrint',
      debugShowCheckedModeBanner: false,

      // ─── Theme ───────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ─── Router ──────────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}
