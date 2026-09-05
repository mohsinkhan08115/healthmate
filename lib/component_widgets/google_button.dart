import 'package:flutter/material.dart';
import 'package:healthmate/core/theme/app_colors.dart';

class GoogleButton extends StatelessWidget {
  final Image image;
  final VoidCallback onPressed;
  const GoogleButton({super.key, required this.image, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.15) : AppColors.lightBorder;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: image,
      ),
    );
  }
}
