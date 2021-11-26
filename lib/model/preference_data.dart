import 'package:flutter/foundation.dart';
import 'package:virtual_pa/model/appointment_slot.dart';

class PreferencesData with ChangeNotifier {
  bool _isChanged = false;
  bool _isAppointmentEnabled = false;
  int _taskLimit;
  List<AppointmentSlot> _appointmentSlots;
  PreferencesData(
      {required bool isAppointmentEnabled,
      required int taskLimit,
      required List<AppointmentSlot> appointmentSlot})
      : _isAppointmentEnabled = isAppointmentEnabled,
        _taskLimit = taskLimit,
        _appointmentSlots = appointmentSlot;

  bool get isChanged => _isChanged;

  set isChanged(bool value) {
    _isChanged = value;
    notifyListeners();
  }

  List<AppointmentSlot> get appointmentSlots => _appointmentSlots;

  void addAppointmentSlot(AppointmentSlot appointmentSlot) {
    _appointmentSlots.add(appointmentSlot);
    if (!isChanged) isChanged = true;
  }

  void removeAppointmentSlot(AppointmentSlot appointmentSlot) {
    _appointmentSlots.remove(appointmentSlot);
    if (_appointmentSlots.isEmpty) {
      _isAppointmentEnabled = false;
    }
    if (!isChanged) isChanged = true;
  }

  set appointmentSlot(List<AppointmentSlot> value) {
    _appointmentSlots = value;
    if (!isChanged) isChanged = true;
  }

  int get taskLimit => _taskLimit;

  set taskLimit(int value) {
    _taskLimit = value;
    if (!isChanged) isChanged = true;
  }

  bool get isAppointmentEnabled => _isAppointmentEnabled;

  set isAppointmentEnabled(bool value) {
    _isAppointmentEnabled = value;
    if (!isChanged) isChanged = true;
  }
}
