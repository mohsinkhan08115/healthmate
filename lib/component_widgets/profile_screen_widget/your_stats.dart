import 'package:flutter/material.dart';

class YourStats extends StatelessWidget {
  YourStats({super.key});
  final List<Map<String, dynamic>> stats = [
    {"icon": Icons.trending_up, "value": 24, "text": "Days Active"},
    {"icon": Icons.military_tech, "value": 10, "text": "Achievements"},
    {"icon": Icons.local_fire_department, "value": 5, "text": "Goals Hit"},
    {"icon": Icons.notifications, "value": 8, "text": "Day Streak"},
  ];
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.military_tech),
              Text(
                "Your Stats",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: stats.map((item) {
              return Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item["icon"]),
                    Text(
                      "${item["value"]}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(item["text"]),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
