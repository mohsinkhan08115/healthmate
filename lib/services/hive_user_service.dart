import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class HiveUserService {
  static Box? _box;

  static Future<Box> openUserBox() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    _box = await Hive.openBox('user_$uid');
    return _box!;
  }

  static Box get box {
    if (_box == null) {
      throw Exception("Hive box not initialized");
    }
    return _box!;
  }

  static Future<void> closeBox() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && Hive.isBoxOpen('user_$uid')) {
      await Hive.box('user_$uid').close();
    }
    _box = null;
  }
}
