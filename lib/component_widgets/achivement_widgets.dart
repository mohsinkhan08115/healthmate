import 'package:flutter/material.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/core/theme/app_theme.dart';

class AchievementWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;
  final int day;
  const AchievementWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.subtext,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final isAchieved = day > 0;
    final isStreak = text.toLowerCase().contains("streak");

    final badgeBg = isAchieved
        ? AppColors.steps.withOpacity(isDark ? 0.2 : 0.12)
        : (isDark ? Colors.white.withOpacity(0.05) : AppColors.primarySurface);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isAchieved ? AppColors.steps : textSecondary,
            size: 20,
          ),
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtext,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isStreak
                ? (isAchieved ? "$day days" : "0 days")
                : (isAchieved ? "Unlocked" : "Locked"),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAchieved ? AppColors.steps : textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
