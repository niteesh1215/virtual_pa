import 'package:jiffy/jiffy.dart';
import 'package:virtual_pa/model/registered_contact.dart';
import 'package:virtual_pa/utilities/common_functions.dart';

enum AppointmentStatus { pending, completed, rejected }

class Appointment with Comparable<Appointment> {
  String? appointmentId;
  String? atUserId;
  String? byUserId;
  String? phoneNo;
  String? appointmentString;
  DateTime? date;
  String? slot;
  DateTime? timeStamp;
  AppointmentStatus status;
  RegisteredContact? byRegisteredContact;

  Appointment({
    this.appointmentId,
    this.atUserId,
    this.byUserId,
    this.phoneNo,
    this.appointmentString,
    this.date,
    this.slot,
    this.timeStamp,
    this.status = AppointmentStatus.pending,
    this.byRegisteredContact,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Appointment &&
          runtimeType == other.runtimeType &&
          appointmentId == other.appointmentId;

  @override
  int get hashCode => appointmentId.hashCode;

  @override
  String toString() {
    return 'Appointment{atUserId: $atUserId, byUserId: $byUserId, phoneNo: $phoneNo, appointmentString: $appointmentString, date: $date, slot: $slot, timeStamp: $timeStamp}';
  }

  @override
  int compareTo(Appointment other) {
    if (date == null || other.date == null) {
      return -1;
    }
    if (date!.isBefore(other.date!)) {
      return -1;
    } else if (date!.isAfter(other.date!)) {
      return 1;
    } else {
      return 0;
    }
  }

  factory Appointment.fromJson(Map<String, dynamic> data) {
    print('hi');
    return Appointment(
        byUserId: data['byuserId'],
        atUserId: data['atuserId'],
        phoneNo: data['contactNo'],
        appointmentId: data['_id'],
        appointmentString: data['message'],
        slot: data['appointmentSlot'],
        date: CommonFunctions.getDateFromddMMyyyy(data['appointmentDate']),
        timeStamp: data['addedOn'] != null
            ? CommonFunctions.getDateFromddMMyyyyhmmssa(data['addedOn'])
            : null,
        status: data['status'] != null
            ? getTaskStatus(data['status'])
            : AppointmentStatus.pending);
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": appointmentId ?? '',
      "byuserId": byUserId,
      "atuserId": atUserId,
      "contactNo": phoneNo,
      "addedOn": timeStamp != null
          ? CommonFunctions.getddMMyyyyhmmssa(timeStamp!)
          : null,
      "message": appointmentString,
      "appointmentDate":
          date != null ? CommonFunctions.getddMMyyyy(date!) : null,
      "appointmentSlot": slot,
    };
  }

  static AppointmentStatus getTaskStatus(String status) {
    switch (status) {
      case 'AppointmentStatus.completed':
        return AppointmentStatus.completed;
      case 'AppointmentStatus.pending':
        return AppointmentStatus.pending;
      case 'AppointmentStatus.rejected':
        return AppointmentStatus.rejected;
    }
    return AppointmentStatus.pending;
  }
}
