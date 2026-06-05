import 'package:flutter/material.dart';

class AppStateStore extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void updateThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();
  }

  void reset() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

final AppStateStore appStateStore = AppStateStore();
