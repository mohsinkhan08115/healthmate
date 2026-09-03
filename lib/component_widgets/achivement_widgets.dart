import 'package:flutter/material.dart';
import 'package:healthmate/core/theme/app_colors.dart';

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
    final isAchieved = day > 0;
    final isStreak = text.toLowerCase().contains("streak");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: isAchieved
                ? AppColors.stepsTrack
                : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isAchieved ? AppColors.steps : AppColors.textSecondary,
            size: 20,
          ),
        ),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtext,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isAchieved
                ? AppColors.stepsTrack
                : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isStreak
                ? (isAchieved ? "$day days" : "0 days")
                : (isAchieved ? "Unlocked" : "Locked"),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAchieved ? AppColors.steps : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

