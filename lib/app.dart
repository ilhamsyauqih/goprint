import 'package:flutter/material.dart';

import 'core/state/app_state_store.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class GoPrintApp extends StatelessWidget {
  const GoPrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStateStore,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'GoPrint',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: appStateStore.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
