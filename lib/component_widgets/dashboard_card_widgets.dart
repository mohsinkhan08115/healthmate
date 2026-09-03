import 'package:flutter/material.dart';
import 'package:healthmate/core/theme/app_colors.dart';

class CardWidgets extends StatelessWidget {
  const CardWidgets({
    super.key,
    required this.text,
    required this.value,
    required this.icon,
    required this.progressValue,
    required this.goalText,
  });

  final IconData icon;
  final String text;
  final String value;
  final double progressValue;
  final String goalText;

  @override
  Widget build(BuildContext context) {
    Color metricColor = AppColors.primary;
    Color trackColor = AppColors.primarySurface;

    final lowerText = text.toLowerCase();
    if (lowerText.contains("step")) {
      metricColor = AppColors.steps;
      trackColor = AppColors.stepsTrack;
    } else if (lowerText.contains("cal")) {
      metricColor = AppColors.calories;
      trackColor = AppColors.caloriesTrack;
    } else if (lowerText.contains("water")) {
      metricColor = AppColors.water;
      trackColor = AppColors.waterTrack;
    } else if (lowerText.contains("prot")) {
      metricColor = AppColors.protein;
      trackColor = AppColors.proteinTrack;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: metricColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value.split(' ')[0], // Get just the number/main statistic
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(metricColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Goal: $goalText",
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

