import 'package:flutter/material.dart';

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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon), SizedBox(width: 8), Text(text)]),
            SizedBox(height: 4),
            Text(value),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: progressValue, // Use the passed progress value
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 10,
            ),
            SizedBox(height: 5),
            Text("Goal: $goalText"),
          ],
        ),
      ),
    );
  }
}
