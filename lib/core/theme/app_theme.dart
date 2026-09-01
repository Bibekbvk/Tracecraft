import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Palette
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color primaryCyan = Color(0xFF00CEC9);
  static const Color accentPink = Color(0xFFFD79A8);
  static const Color flameOrange = Color(0xFFFF7675);
  static const Color starGold = Color(0xFFFFB300);

  // Dark Palette
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF181B24);
  static const Color darkSurfaceCard = Color(0xFF222634);

  // Light Palette
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceCard = Color(0xFFF0F2F8);

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: primaryPurple,
        secondary: primaryCyan,
        surface: darkSurface,
        surfaceContainerHighest: darkSurfaceCard,
        error: flameOrange,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.white10),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: primaryPurple.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryCyan)
              : const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const IconThemeData(color: primaryCyan)
              : const IconThemeData(color: Colors.white54),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        secondary: primaryCyan,
        surface: lightSurface,
        surfaceContainerHighest: lightSurfaceCard,
        error: flameOrange,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1E2026),
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF1E2026)),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E2026)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF1E2026)),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2026)),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: primaryPurple.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryPurple)
              : const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const IconThemeData(color: primaryPurple)
              : const IconThemeData(color: Colors.black54),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
