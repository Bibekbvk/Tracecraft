import 'package:flutter/material.dart';

/// App-wide color palette tailored for visual excellence and high contrast drawing environments.
class AppColors {
  // Primary brand accents
  static const Color primary = Color(0xFF6C5CE7); // Royal Electric Violet
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);

  // Secondary & Accents
  static const Color accentCyan = Color(0xFF00CEC9); // Neon Cyan for active tools & guides
  static const Color accentAmber = Color(0xFFFFB300); // Warm Amber for streaks & ratings
  static const Color accentPink = Color(0xFFFD79A8); // Neon Pink for favorites & likes
  static const Color accentGreen = Color(0xFF00B894); // Mint Emerald for completed badges

  // Dark Theme Backgrounds
  static const Color backgroundDark = Color(0xFF0F1117); // Ultra deep charcoal
  static const Color surfaceDark = Color(0xFF181B24); // Elevated dark surface
  static const Color surfaceElevated = Color(0xFF222634); // Floating card surface
  static const Color surfaceHighlight = Color(0xFF2C3244); // Hover/border highlight

  // Light Theme Backgrounds
  static const Color backgroundLight = Color(0xFFF7F9FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFEEF2F6);

  // Borders and Glassmorphism
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassSurface = Color(0x80181B24);
  static const Color glassSurfaceLight = Color(0x80FFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFF1F2F6);
  static const Color textSecondary = Color(0xFFA4B0BE);
  static const Color textMuted = Color(0xFF57606F);

  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);

  // Grid & Tracing Guides
  static const Color defaultGridColor = Color(0x9900CEC9);
  static const Color defaultPencilColor = Color(0xFF222222);
}
