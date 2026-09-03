import 'package:flutter/material.dart';
import 'package:healthmate/models/meals_model.dart';
import 'package:healthmate/core/theme/app_colors.dart';

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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: headerColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: headerColor, size: 20),
            ),
            title: Text(
              txt,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              subtxt,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...meals.map((meal) => _mealItemCard(meal)),
        ],
      ),
    );
  }

  Widget _mealItemCard(Meal meal) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(meal.icon, color: AppColors.primary, size: 18),
        ),
        title: Text(
          meal.title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          meal.subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
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
