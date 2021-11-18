import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<void> requestContactsPermission() async {
    if (!await Permission.contacts.request().isGranted) {
      requestContactsPermission();
    }
  }
}
