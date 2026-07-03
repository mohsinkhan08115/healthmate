import 'package:flutter/material.dart';
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
    return Card(
      elevation: 10,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          // gradient: AppColors.ButtonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon),
              title: Text(txt),
              subtitle: Text(subtxt),
            ),

            // 🔥 dynamic list
            ...meals.map((meal) => breakfastcard(meal)),
          ],
        ),
      ),
    );
  }

  Widget breakfastcard(Meal meal) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(meal.icon, size: 30),
        title: Text(meal.title),
        subtitle: Text(meal.subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${meal.calories} cal"),
            Text("${meal.protein}g protein"),
          ],
        ),
      ),
    );
  }
}
