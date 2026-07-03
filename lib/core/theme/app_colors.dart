import 'package:flutter/material.dart';

class AppColors {
  // ── Primary brand (violet-purple — dashboard header, steps, buttons) ───────
  static const Color primary = Color(0xFF6C63FF); // violet-purple
  static const Color primaryLight = Color(0xFF857DFF); // lighter violet
  static const Color primarySoft = Color(0xFFA59EFF); // soft violet
  static const Color primarySurface = Color(0xFFEEEDFF); // lavender tint

  // ── Semantic / metric colors ───────────────────────────────────────────────
  static const Color steps = Color(
    0xFF6C63FF,
  ); // violet  – steps (matches dashboard card)
  static const Color calories = Color(
    0xFFFF6B35,
  ); // orange  – calories (matches nutrition card + meal kcal)
  static const Color water = Color(0xFF4CC9F0); // sky blue – hydration
  static const Color protein = Color(0xFF06D6A0); // teal    – protein/nutrition

  // ── Progress track tints ───────────────────────────────────────────────────
  static const Color stepsTrack = Color(0xFFEEEDFF); // violet tint
  static const Color caloriesTrack = Color(0xFFFFEDE6); // orange tint
  static const Color waterTrack = Color(0xFFE6F7FD); // sky tint
  static const Color proteinTrack = Color(0xFFE6FBF5); // teal tint

  // ── Neutrals ───────────────────────────────────────────────────────────────
  static const Color background = Color(
    0xFFF8F8FF,
  ); // near-white with violet hint
  static const Color surface = Color(0xFFEEEDFF); // card surface / border
  static const Color textPrimary = Color(0xFF1A1A2E); // dark navy text
  static const Color textSecondary = Color(0xFF6B7280); // muted grey text

  // ── Screen gradients ───────────────────────────────────────────────────────
  // Dashboard "Welcome Back" header — purple (matches image 1)
  static const LinearGradient screenGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFBB86FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Food Logger header — green (matches image 3)
  static const LinearGradient foodGradient = LinearGradient(
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Steps screen header — purple (matches image 2)
  static const LinearGradient stepsGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFBB86FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF857DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Specific card colors (matching screenshots exactly) ────────────────────
  static const Color weeklySummaryBg = Color(
    0xFF6C63FF,
  ); // purple weekly summary
  static const Color nutritionCardBg = Color(
    0xFFFF6B35,
  ); // orange nutrition card (image 3)
  static const Color monthlyCardBg = Color(
    0xFF6C63FF,
  ); // purple "Total This Month" (image 2)
  static const Color dailyAvgCardBg = Color(
    0xFFFF6B35,
  ); // orange "Daily Average"   (image 2)
}
