import 'package:flutter/material.dart';

class Meal {
  final IconData icon;
  final String title;
  final String subtitle;
  final int calories;
  final int protein;

  Meal({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.protein,
  });
}
