import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart'; // New import
import 'package:healthmate/controller/home_screen_controller/home_screen_controller.dart';
import 'package:healthmate/screens/bottom_navigation/dashboard_screen.dart';
import 'package:healthmate/screens/bottom_navigation/food_screen.dart';
import 'package:healthmate/screens/bottom_navigation/meals_screen.dart';
import 'package:healthmate/screens/bottom_navigation/profile_screen.dart';
import 'package:healthmate/screens/bottom_navigation/steps_screen.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final BottomNavController controller = Get.put(BottomNavController());

  DateTime currentDate = DateTime.now();

  final List<Widget> _pages = [
    DashboardScreen(),
    StepsScreen(),
    FoodScreen(),
    MealsScreen(),
    ProfileScreen(),
  ];

  // Changed: removed FirebaseAuth user + getUserData() (was reading from
  // Firestore, but the name is actually saved in Hive's profileBox)
  Box get _profileBox => Hive.box('profileBox');

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: ListTile(
            contentPadding: EdgeInsets.zero,

            leading: SizedBox(
              height: 30,
              width: 30,
              child: Image.asset("assets/images/lifeline.png"),
            ),

            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 214, 242, 3),
                  Color.fromARGB(255, 5, 237, 5),
                ],
              ).createShader(bounds),

              // Changed: read name directly from Hive instead of FutureBuilder + Firestore
              child: Text(
                "Hello, ${_profileBox.get('name') ?? 'User'}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            subtitle: Text(
              "Your Health Companion",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),

            trailing: Column(
              children: [
                Text(
                  "Today",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),

                Text(
                  "${currentDate.day}/${currentDate.month}/${currentDate.year}",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),

        body: _pages[controller.selectedIndex.value],

        bottomNavigationBar: BottomNavigationBar(
          fixedColor: Colors.blue,
          unselectedItemColor: Colors.amber,

          currentIndex: controller.selectedIndex.value,

          onTap: controller.changeIndex,

          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: "Dashboard",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.directions_walk_rounded),
              label: "Steps",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_rounded),
              label: "Food",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.lunch_dining_rounded),
              label: "Meals",
            ),

            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
