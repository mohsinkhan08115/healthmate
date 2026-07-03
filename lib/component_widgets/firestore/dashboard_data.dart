import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardDataSave {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> saveDailyStats({
    required int steps,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    await firestore
        .collection("users")
        .doc(user.uid)
        .collection("dailyStats")
        .doc(DateTime.now().toIso8601String().split("T")[0]) // today date
        .set({
          "steps": steps,
          "calories": calories,
          "protein": protein,
          "carbs": carbs,
          "fat": fat,
          "fiber": fiber,
          "timestamp": FieldValue.serverTimestamp(),
        });
  }
}
