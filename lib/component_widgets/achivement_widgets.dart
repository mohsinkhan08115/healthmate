import 'package:flutter/material.dart';

class AchievementWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;
  final int day;
  const AchievementWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.subtext,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
        subtitle: Text(subtext),
        trailing: Text("$day Days Ago"),
      ),
    );
  }
}
