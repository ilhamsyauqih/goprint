import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/order/screens/order_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoPrint User Order Tracking',
      debugShowCheckedModeBanner: false,
      
      // Integrate Premium Light & Dark Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically adapts to system settings
      
      // Default Entry Screen
      home: const OrderListScreen(),
    );
  }
}
