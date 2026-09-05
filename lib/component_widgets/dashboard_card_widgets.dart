import 'package:flutter/material.dart';
import 'package:healthmate/component_widgets/circular_progress_indicator.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/core/theme/app_theme.dart';

class CardWidgets extends StatelessWidget {
  final String text;
  final String value;
  final IconData icon;
  final double progressValue;
  final String goalText;

  const CardWidgets({
    super.key,
    required this.text,
    required this.value,
    required this.icon,
    required this.progressValue,
    required this.goalText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final baseRingColor = isDark ? AppColors.darkRingTrack : AppColors.lightRingTrack;

    // Map Category Accent Colors per spec
    Color accentColor = AppColors.steps;
    final lowerText = text.toLowerCase();
    if (lowerText.contains("step")) {
      accentColor = AppColors.steps; // Purple #8B5CF6
    } else if (lowerText.contains("cal")) {
      accentColor = AppColors.calories; // Orange #FF6B4A
    } else if (lowerText.contains("water")) {
      accentColor = AppColors.water; // Blue #00B4D8
    } else if (lowerText.contains("prot")) {
      accentColor = AppColors.protein; // Gold #F59E0B
    }

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Header Row: Small category icon + title ────────────────────────
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // ── Middle Row: Circular Progress Indicator + Numerical Value/Target ──
          Row(
            children: [
              CustomCircularProgressIndicator(
                progress: progressValue,
                size: 48,
                strokeWidth: 4.5,
                activeColor: accentColor,
                baseColor: baseRingColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "/ $goalText",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Bottom: Thin matching linear bar ─────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0.0, 1.0),
              backgroundColor: accentColor.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 3.5,
            ),
          ),
        ],
      ),
    );
  }
}
