class Appointment {
  String? atUserId;
  String? requesterId;
  String? phoneNo;
  String? appointmentString;
  //in millisecondSinceEpoch
  String? date;
  String? slot;
  DateTime? timeStamp;

  Appointment({
    this.atUserId,
    required this.requesterId,
    required this.phoneNo,
    required this.appointmentString,
    this.date,
    this.slot,
  });

  @override
  String toString() {
    return 'Appointment{atUserId: $atUserId, requesterId: $requesterId, phoneNo: $phoneNo, appointmentString: $appointmentString, date: $date, slot: $slot, timeStamp: $timeStamp}';
  }
}
