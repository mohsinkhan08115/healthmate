import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // ADDED: to check profile data in Hive
import 'package:healthmate/onboarding_screen/steps_onboarding_screen.dart';
import 'package:healthmate/screens/Home_Screen/home_screen.dart';
import 'package:healthmate/screens/auth_screens/info_screen.dart';
// REMOVED: cloud_firestore import (no longer needed)

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // not logged in
        if (!snapshot.hasData) {
          return TrackYourStepsScreen();
        }

        // CHANGED: check Hive ('profileBox') instead of Firestore to
        // decide if the profile exists for this uid.
        final profileBox = Hive.box('profileBox');
        final savedUid = profileBox.get('uid');
        final profileExists = savedUid == snapshot.data!.uid;

        // profile missing
        if (!profileExists) {
          return InfoScreen();
        }

        // profile exists
        return HomeScreen();
      },
    );
  }
}
