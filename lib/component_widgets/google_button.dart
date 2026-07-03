import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final Image image;
  final VoidCallback onPressed;
  const GoogleButton({super.key, required this.image, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // gradient: AppColors.screenGradient,
          // shape: BoxShape.circle,
        ),
        child: image,
      ),
    );
  }
}
