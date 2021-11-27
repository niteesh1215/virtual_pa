import 'package:hive_flutter/hive_flutter.dart';
import 'package:virtual_pa/model/user.dart';

class HiveController {
  Box? _box;
  Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box> openBox({String? boxName}) async {
    Hive.close();
    _box = await Hive.openBox(boxName ?? 'vpa');
    return _box!;
  }

  Future<void> addUser(User user) async {
    _checkAndOpenBox();
    await _box!.put('user', user.toJson());
  }

  Future<void> deleteUser() async {
    _checkAndOpenBox();
    await _box!.delete('user');
  }

  Future<User?> getUser() async {
    _checkAndOpenBox();
    final userMap = _box!.get('user');
    return userMap == null
        ? null
        : User.fromJson(Map<String, dynamic>.from(userMap));
  }

  Future<void> _checkAndOpenBox() async {
    if (_box == null) {
      await openBox();
    }
  }

  closeBoxes() {
    Hive.close();
  }
}
