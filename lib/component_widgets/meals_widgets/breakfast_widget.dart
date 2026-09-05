import 'package:flutter/material.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/core/theme/app_theme.dart';
import 'package:healthmate/models/meals_model.dart';

class MealSectionWidget extends StatelessWidget {
  final String txt;
  final String subtxt;
  final IconData icon;
  final List<Meal> meals;

  const MealSectionWidget({
    super.key,
    required this.txt,
    required this.subtxt,
    required this.icon,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    Color headerColor = AppColors.primary;
    final lowerTxt = txt.toLowerCase();
    if (lowerTxt.contains("break")) {
      headerColor = AppColors.breakfast;
    } else if (lowerTxt.contains("lunch")) {
      headerColor = AppColors.lunch;
    } else if (lowerTxt.contains("dinner")) {
      headerColor = AppColors.dinner;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: AppTheme.cardShadow(context),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: headerColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: headerColor, size: 20),
            ),
            title: Text(
              txt,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            subtitle: Text(
              subtxt,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...meals.map((meal) => _mealItemCard(context, meal)),
        ],
      ),
    );
  }

  Widget _mealItemCard(BuildContext context, Meal meal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final innerBg = isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: innerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(meal.icon, color: AppColors.primary, size: 18),
        ),
        title: Text(
          meal.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        subtitle: Text(
          meal.subtitle,
          style: TextStyle(
            fontSize: 11,
            color: textSecondary,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${meal.calories} kcal",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.calories,
              ),
            ),
            Text(
              "${meal.protein}g protein",
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.protein,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
