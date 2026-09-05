import 'package:flutter/material.dart';

class AppColors {
  // ── Core Brand Accent ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF00A86B); // Primary Emerald Green
  static const Color emerald = Color(0xFF00A86B);
  static const Color emeraldLightBg = Color(0xFFE8F8F2);
  static const Color primarySurface = Color(0xFFE8F8F2);
  static const Color primarySoft = Color(0xFF34D399);

  // ── Category Metric Colors ────────────────────────────────────────────────
  static const Color steps = Color(0xFF8B5CF6); // Purple
  static const Color calories = Color(0xFFFF6B4A); // Orange
  static const Color water = Color(0xFF00B4D8); // Blue
  static const Color protein = Color(0xFFF59E0B); // Gold

  // ── Action Pill & Badge Colors ─────────────────────────────────────────────
  static const Color lavenderPillLight = Color(0xFFF1EFFF);
  static const Color lavenderPillDark = Color(0xFF24204F);
  static const Color lavenderText = Color(0xFF6366F1);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient indigoGradient = LinearGradient(
    colors: [Color(0xFF5B4DF5), Color(0xFF4338CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF00A86B), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light Theme Palette ────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightRingTrack = Color(0xFFF1F5F9);

  // ── Dark Theme Palette ─────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0x0FFFFFFF); // white.withOpacity(0.06)
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkRingTrack = Color(0x1FFFFFFF); // white12

  // ── Legacy Backwards Compatibility Mappings ────────────────────────────────
  static const Color accent = Color(0xFF5B4DF5);
  static const Color breakfast = Color(0xFFF59E0B);
  static const Color lunch = Color(0xFF00A86B);
  static const Color dinner = Color(0xFF5B4DF5);
  static const Color carbs = Color(0xFF00B4D8);
  static const Color fat = Color(0xFF8B5CF6);
  static const Color fiber = Color(0xFF00A86B);
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color border = lightBorder;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textCaption = lightTextMuted;
  static const Color stepsTrack = Color(0x1F8B5CF6);
  static const Color caloriesTrack = Color(0x1FFF6B4A);
  static const Color waterTrack = Color(0x1F00B4D8);
  static const Color proteinTrack = Color(0x1FF59E0B);
  static const LinearGradient screenGradient = emeraldGradient;
  static const LinearGradient buttonGradient = emeraldGradient;
}
