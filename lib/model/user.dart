import 'package:flutter/cupertino.dart';

class User with ChangeNotifier {
  String? _userId;
  String? _token;
  String? _phoneNo;
  String? _name;
  String? _password;

  String? get userId => _userId;

  set userId(String? userId) {
    _userId = userId;
    notifyListeners();
  }

  String? get token => _token;

  set token(String? value) {
    _token = value;
    notifyListeners();
  }

  String? get phoneNo => _phoneNo;

  set phoneNo(String? value) {
    _phoneNo = value;
    notifyListeners();
  }

  String? get name => _name;

  set name(String? value) {
    _name = value;
    notifyListeners();
  }

  String? get password => _password;

  set password(String? value) {
    _password = value;
    notifyListeners();
  }
}
