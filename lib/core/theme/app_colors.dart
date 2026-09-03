import 'package:flutter/material.dart';

class AppColors {
  // ── Primary brand (violet-purple — dashboard header, steps, buttons) ───────
  static const Color primary = Color(0xFF6C63FF); // violet-purple
  static const Color primaryLight = Color(0xFF857DFF); // lighter violet
  static const Color primarySoft = Color(0xFFA59EFF); // soft violet
  static const Color primarySurface = Color(0xFFF3F4F6); // neutral light surface

  // ── Semantic / metric colors ───────────────────────────────────────────────
  static const Color steps = Color(0xFF10B981); // Emerald Green
  static const Color calories = Color(0xFFEF4444); // Red / Coral
  static const Color water = Color(0xFF3B82F6); // Blue
  static const Color protein = Color(0xFF8B5CF6); // Purple
  
  // ── Meal specific colors ──────────────────────────────────────────────────
  static const Color breakfast = Color(0xFFF59E0B); // Warm Amber
  static const Color lunch = Color(0xFF0EA5E9); // Sky Blue
  static const Color dinner = Color(0xFF6366F1); // Indigo

  // ── Progress track tints (8% opacity equivalents of semantic colors) ───────
  static const Color stepsTrack = Color(0xFFECFDF5);
  static const Color caloriesTrack = Color(0xFFFEF2F2);
  static const Color waterTrack = Color(0xFFEFF6FF);
  static const Color proteinTrack = Color(0xFFF5F3FF);

  // ── Neutrals ───────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF9FAFB); // sleek light background
  static const Color surface = Colors.white; // card surface
  static const Color border = Color(0xFFE5E7EB); // subtle 1px border color
  static const Color textPrimary = Color(0xFF111827); // dark text
  static const Color textSecondary = Color(0xFF6B7280); // muted grey text

  // ── Screen gradients (subtle transitions) ──────────────────────────────────
  static const LinearGradient screenGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5A52E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient foodGradient = LinearGradient(
    colors: [Color(0xFFF9FAFB), Color(0xFFF9FAFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient stepsGradient = LinearGradient(
    colors: [Color(0xFFF9FAFB), Color(0xFFF9FAFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5A52E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Specific card colors (mapped to semantic design tokens) ────────────────
  static const Color weeklySummaryBg = Colors.white;
  static const Color nutritionCardBg = Colors.white;
  static const Color monthlyCardBg = Colors.white;
  static const Color dailyAvgCardBg = Colors.white;
}

