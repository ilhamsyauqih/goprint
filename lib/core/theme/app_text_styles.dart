import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografi GoPrint — sesuai PRD Design System Section 4.4.
///
/// Heading: **Poppins**  ·  Body: **Inter**
class AppTextStyles {
  AppTextStyles._();

  // ─── Poppins — Heading / Title ───────────────────────────────────

  /// Display Large — 32sp Bold 700 (Splash, Onboarding title)
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  /// Headline Large — 28sp SemiBold 600 (Judul halaman utama)
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  /// Headline Medium — 24sp SemiBold 600 (Judul seksi, kartu utama)
  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  /// Title Large — 20sp Medium 500 (Nama layanan, judul dialog)
  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  /// Title Medium — 16sp Medium 500 (Label tab, header list)
  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // ─── Inter — Body / Label ────────────────────────────────────────

  /// Body Large — 16sp Regular 400 (Deskripsi, paragraf panjang)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// Body Medium — 14sp Regular 400 (Konten umum, label form)
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// Label Large — 14sp Medium 500 (Teks tombol, badge)
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Label Medium — 12sp Medium 500 (Caption, metadata)
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Label Small — 10sp Regular 400 (Timestamp, footnote)
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  /// Build a complete [TextTheme] from the PRD styles.
  static TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
