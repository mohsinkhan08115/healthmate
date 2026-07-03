// import 'package:flutter/material.dart';
// import 'package:pedometer/pedometer.dart';
// import 'package:permission_handler/permission_handler.dart';

// class StepCounterScreen extends StatefulWidget {
//   @override
//   _StepCounterScreenState createState() => _StepCounterScreenState();
// }

// class _StepCounterScreenState extends State<StepCounterScreen> {
//   int steps = 0;
//   int goal = 10000;
//   @override
//   void initState() {
//     super.initState();
//     initSteps();
//   }

//   Future<void> initSteps() async {
//     var status = await Permission.activityRecognition.request();

//     if (status.isGranted) {
//       Pedometer.stepCountStream.listen((event) {
//         setState(() {
//           steps = event.steps;
//         });
//       });
//     }
//   }

//   void startListening() {
//     Pedometer.stepCountStream
//         .listen((StepCount event) {
//           setState(() {
//             steps = event.steps;
//           });
//         })
//         .onError((error) {
//           print("Step Count Error: $error");
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Step Counter")),
//       body: Center(
//         child: Text(steps.toString(), style: const TextStyle(fontSize: 40)),
//       ),
//     );
//   }
// }
