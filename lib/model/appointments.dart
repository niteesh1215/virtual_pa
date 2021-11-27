import 'package:flutter/foundation.dart';
import 'package:virtual_pa/controller/api_end_points/appointment_api_controller.dart';
import 'package:virtual_pa/model/appointment.dart';
import 'package:virtual_pa/model/l_response.dart';

class Appointments with ChangeNotifier {
  List<Appointment> _list = [];
  List<Appointment> _copyList = [];
  List<Appointment> get list => _list;
  bool _isAppointmentLoading = false;
  bool _showForMeAppointment = true;
  bool _isAscendingOrder = true;

  String? userId;

  bool get isAppointmentLoading => _isAppointmentLoading;

  set isAppointmentLoading(bool loading) {
    _isAppointmentLoading = loading;
    notifyListeners();
  }

  bool get showForMeAppointment => _showForMeAppointment;

  set showForMeAppointment(bool value) {
    _showForMeAppointment = value;
    notifyListeners();
    loadAppointments();
  }

  bool get isAscendingOrder => _isAscendingOrder;

  set isAscendingOrder(bool value) {
    _isAscendingOrder = value;
    getSortByDateAppointment(isAsec: value);
    notifyListeners();
  }

  /*bool get showOnlyUrgent => _showOnlyUrgent;

  set showOnlyUrgent(bool value) {
    if (_isAppointmentLoading) return;
    _showOnlyUrgent = value;
    if (_showOnlyUrgent) {
      _copyList = List<Appointment>.from(_list);
      _filterUrgent();
    } else {
      _list = List<Appointment>.from(_copyList);
      _copyList = [];
    }
    notifyListeners();
  }*/

  /*void _filterUrgent() {
    final tempList = List<Appointment>.from(_list);
    for (Appointment task in tempList) {
      if (!task.urgent) {
        _list.remove(task);
      }
    }
  }*/

  void addAppointments(List<Appointment> appointments,
      {bool shouldNotify = true}) {
    _list = appointments;
    if (shouldNotify) notifyListeners();
  }

  void addAppointment(Appointment appointment, {bool shouldNotify = true}) {
    _list.add(appointment);
    if (shouldNotify) notifyListeners();
  }

  void deleteAppointment(Appointment appointment, {bool shouldNotify = true}) {
    _list.remove(appointment);
    if (shouldNotify) notifyListeners();
  }

  List<Appointment> getSortByDateAppointment(
      {List<Appointment>? tasks, bool isAsec = true}) {
    _list.sort((Appointment a, Appointment b) {
      return isAsec ? a.compareTo(b) : b.compareTo(a);
    });
    return _list;
  }

  /*List<Appointment> getUrgentAppointment({bool isAsec = true}) {
    final list = _list.where((task) => task.urgent).toList();
    return getSortByDateAppointment(tasks: list);
  }*/

  void loadAppointments({bool shouldNotifyListeners = true}) async {
    //_showOnlyUrgent = false;
    _list = [];
    if (shouldNotifyListeners) {
      _isAscendingOrder = true;
      isAppointmentLoading = true;
    } else {
      _isAscendingOrder = true;
      _isAppointmentLoading = true;
    }
    final AppointmentApiController appointmentApiController =
        AppointmentApiController();
    LResponse<List<Appointment>?> lResponse =
        await appointmentApiController.retrieveAppointment(userId!,
            getForMeAppointment: showForMeAppointment);

    if (lResponse.data != null && lResponse.data!.isNotEmpty) {
      addAppointments(lResponse.data!);
    }

    isAppointmentLoading = false;
  }
}
