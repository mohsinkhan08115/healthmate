import 'package:flutter/material.dart';

class Custombutton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const Custombutton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,

      child: Container(
        height: 45,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [Colors.yellow, Colors.red]),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }
}
