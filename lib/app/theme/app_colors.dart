import 'package:flutter/material.dart';

/// Palet warna dark mode modern untuk GymStreak.
/// Background gelap kehijauan dengan aksen hijau neon/lime.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B1210);
  static const Color surface = Color(0xFF141C19);
  static const Color surfaceElevated = Color(0xFF1C2622);
  static const Color divider = Color(0xFF232D29);

  static const Color accent = Color(0xFFB6FF3C);
  static const Color accentDark = Color(0xFF8FD634);
  static const Color accentMuted = Color(0xFF3E4A32);

  static const Color textPrimary = Color(0xFFF2F5F3);
  static const Color textSecondary = Color(0xFFA0ACA6);
  static const Color textMuted = Color(0xFF6B7570);

  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFC24B);
  static const Color success = accent;

  /// Warna indikator heatmap kalender aktivitas.
  static const Color heatmapNone = Color(0xFF232D29);
  static const Color heatmapLight = Color(0xFF3E6B3A);
  static const Color heatmapMedium = Color(0xFF5FA83A);
  static const Color heatmapHeavy = Color(0xFFB6FF3C);
}
