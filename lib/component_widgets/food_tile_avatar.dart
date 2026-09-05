import 'package:flutter/material.dart';
import 'package:healthmate/core/theme/app_colors.dart';

class FoodTileAvatar extends StatelessWidget {
  final String foodName;
  final double size;

  const FoodTileAvatar({
    super.key,
    required this.foodName,
    this.size = 40.0,
  });

  String? _getAssetPath(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('burger')) return 'assets/images/Burger.png';
    if (lower.contains('banana')) return 'assets/images/banana.png';
    if (lower.contains('egg')) return 'assets/images/fried-egg.png';
    if (lower.contains('milk')) return 'assets/images/milk.png';
    if (lower.contains('rice')) return 'assets/images/rice.png';
    if (lower.contains('bread')) return 'assets/images/white-bread.png';
    if (lower.contains('water')) return 'assets/images/water.png';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getAssetPath(foodName);

    return Container(
      height: size,
      width: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.caloriesTrack,
        borderRadius: BorderRadius.circular(10),
      ),
      child: assetPath != null
          ? Image.asset(assetPath, fit: BoxFit.contain)
          : const Icon(
              Icons.restaurant_rounded,
              color: AppColors.calories,
              size: 20,
            ),
    );
  }
}
