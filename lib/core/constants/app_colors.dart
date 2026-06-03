import 'package:flutter/material.dart';

/// Palet warna GoPrint — sesuai PRD Design System Section 4.2 & 4.3.
class AppColors {
  AppColors._();

  // ─── Brand / Accent — Teal ───────────────────────────────────────
  static const Color teal200 = Color(0xFF80CBC4);
  static const Color teal300 = Color(0xFF4DB6AC);
  static const Color teal400 = Color(0xFF26A69A);
  static const Color teal600 = Color(0xFF00897B);
  static const Color teal700 = Color(0xFF00796B);
  static const Color teal800 = Color(0xFF00695C);
  static const Color teal900 = Color(0xFF004D40);

  // ─── Light Mode ──────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFEEEEEE);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightSubtleText = Color(0xFF9E9E9E);
  static const Color lightPrimaryText = Color(0xFF212121);

  // ─── Dark Mode ───────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2E2E2E);
  static const Color darkElevated = Color(0xFF3D3D3D);
  static const Color darkBorder = Color(0xFF4D4D4D);
  static const Color darkMutedText = Color(0xFF9E9E9E);
  static const Color darkPrimaryText = Color(0xFFFAFAFA);

  // ─── Status Colors — Light Mode ──────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF01579B);

  // ─── Status Colors — Dark Mode ───────────────────────────────────
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warningDark = Color(0xFFFFCA28);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color infoDark = Color(0xFF42A5F5);

  // ─── Gradient helpers ────────────────────────────────────────────
  /// Header gradient Light: Teal 600 → Teal 900, arah 135°
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal600, teal900],
  );

  /// Header gradient Dark: Teal 800 → Dark Background
  static const LinearGradient headerGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal800, darkBackground],
  );

  /// Splash radial gradient
  static const RadialGradient splashGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.25,
    colors: [teal400, teal600, teal900],
  );

  /// Primary button gradient
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [teal600, teal900],
  );
}
