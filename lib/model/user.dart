import 'package:flutter/material.dart';

class User with ChangeNotifier {
  User({
    String? userId,
    String? phoneNo,
    String? name,
    int taskLimit = 500,
    bool isAppointmentEnabled = false,
    bool isTaskLimitReached = false,
    String? password,
    List? appointmentSlots,
    List<String>? blockedList,
  })  : _userId = userId,
        _phoneNo = phoneNo,
        _name = name,
        _taskLimit = taskLimit,
        _isAppointmentEnabled = isAppointmentEnabled,
        _isTaskLimitReached = isTaskLimitReached,
        _appointmentSlots = appointmentSlots,
        _blockedList = blockedList,
        _password = password;

  String? _userId;
  String? _token;
  String? _phoneNo;
  String? _name;
  String? _password;

  int _taskLimit = 500;
  bool _isAppointmentEnabled = false;
  bool _isTaskLimitReached = false;
  List? _appointmentSlots;
  List<String>? _blockedList;

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

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
        userId: data['_id'],
        name: data['name'],
        phoneNo: data['phoneNo'],
        blockedList: data['blockedList'].cast<String>(),
        taskLimit: data['taskLimit'],
        appointmentSlots: data['appointmentSlots'], // todo: update this
        isAppointmentEnabled: data['isAppointmentEnabled'],
        isTaskLimitReached: data['isTaskLimitReached'],
        password: data['password']);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _userId,
      'name': _name,
      'phoneNo': phoneNo,
      'blockedList': _blockedList ?? [],
      'taskLimit': _taskLimit,
      'appointmentSlots': _appointmentSlots ?? [],
      'isAppointmentEnabled': _isAppointmentEnabled,
      'isTaskLimitReached': _isTaskLimitReached,
      'password': _password ?? '12222',
    };
  }

  @override
  String toString() {
    return 'User{_userId: $_userId, _token: $_token, _phoneNo: $_phoneNo, _name: $_name, _password: $_password, _taskLimit: $_taskLimit, _isAppointmentEnabled: $_isAppointmentEnabled, _isTaskLimitReached: $_isTaskLimitReached, _appointmentSlots: $_appointmentSlots, _blockedList: $_blockedList}';
  }
}
