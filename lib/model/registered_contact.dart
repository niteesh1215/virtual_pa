import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:virtual_pa/controller/api_end_points/user_api_controller.dart';
import 'package:virtual_pa/model/appointment_slot.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/utilities/local_contacts.dart';
import 'package:virtual_pa/utilities/permission_handler.dart';

class RegisteredContact with ChangeNotifier {
  String? _phoneNo;
  String? _fullName;
  String? _id;
  bool? _isAppointmentEnabled;
  List<AppointmentSlot>? _appointmentSlots;

  RegisteredContact(
      {String? id,
      required String phoneNo,
      String? fullName,
      List<AppointmentSlot>? appointmentSlots})
      : _id = id,
        _phoneNo = phoneNo,
        _fullName = fullName,
        _appointmentSlots = appointmentSlots;

  String? get phoneNo => _phoneNo;

  void setPhoneNo(String value, {bool shouldNotifyListeners = true}) {
    _phoneNo = value;
    if (shouldNotifyListeners) notifyListeners();
  }

  String? get fullName => _fullName;

  void setFullName(String value, {bool shouldNotifyListeners = true}) {
    _fullName = value;
    if (shouldNotifyListeners) notifyListeners();
  }

  String? get id => _id;

  void setUserId(String value, {bool shouldNotifyListeners = true}) {
    _id = value;
    if (shouldNotifyListeners) notifyListeners();
  }

  bool? get isAppointmentEnabled => _isAppointmentEnabled;

  setIsAppointmentEnabled(bool value, {bool shouldNotifyListeners = true}) {
    _isAppointmentEnabled = value;
    if (shouldNotifyListeners) notifyListeners();
  }

  List<AppointmentSlot>? get appointmentSlot => _appointmentSlots;

  setAppointmentSlots(List<AppointmentSlot> slots,
      {bool shouldNotifyListeners = true}) {
    _appointmentSlots = slots;
    if (shouldNotifyListeners) notifyListeners();
  }

  @override
  bool operator ==(other) {
    return (other is RegisteredContact) && other.phoneNo == phoneNo;
  }

  @override
  String toString() {
    return 'RegisteredContact{_phoneNo: $_phoneNo, _fullName: $_fullName, _id: $_id, _isAppointmentEnabled: $_isAppointmentEnabled, _appointmentSlot: $_appointmentSlots}';
  }

  @override
  int get hashCode => phoneNo.hashCode;
}

class RegisteredContacts with ChangeNotifier {
  RegisteredContacts() {
    readAndFindRegisteredContacts();
  }

  final List<RegisteredContact> _contacts = [];
  bool _isSearchInProgress = false;
  bool _isContactSearchCompleted = false;

  List<RegisteredContact> get contacts => _contacts;

  bool get isSearchInProgress => _isSearchInProgress;
  bool get isContactSearchCompleted => _isContactSearchCompleted;

  void addNewContact(RegisteredContact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void readAndFindRegisteredContacts() async {
    await PermissionHandler.requestContactsPermission();
    _isSearchInProgress = true;
    notifyListeners();
    final List<RegisteredContact> contactList = [];
    final List<String> phoneNos = [];
    List<Contact> contacts = await LocalContacts.getContacts();
    for (Contact contact in contacts) {
      if (contact.phones != null && contact.phones!.isNotEmpty) {
        String? phone = contact.phones!.first.value;
        final fullName = contact.displayName;
        if (phone != null) {
          if (phone.length >= 10) {
            phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
            phone = '+91' + phone.substring(phone.length - 10);
            final registeredContact = RegisteredContact(
                id: phone, phoneNo: phone, fullName: fullName ?? phone);
            if (!contactList.contains(registeredContact)) {
              phoneNos.add(phone);
              contactList.add(registeredContact);
            }
          }
        }
      }
    }

    final userAPIController = UserAPIController();

    final LResponse<List<Map<String, dynamic>>?> lResponse =
        await userAPIController.retrieveRegisterUsers(phoneNos);
    if (lResponse.responseStatus == ResponseStatus.success) {
      if (lResponse.data != null) {
        for (Map<String, dynamic> userData in lResponse.data!) {
          final registeredContact =
              contactList.firstWhere((rc) => userData['phoneNo'] == rc.phoneNo);
          registeredContact.setUserId(userData['_id'],
              shouldNotifyListeners: false);
          registeredContact.setIsAppointmentEnabled(
              userData['isAppointmentEnabled'],
              shouldNotifyListeners: false);
          final appointmentSlotsMapArray = userData['appointmentSlots']
              .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>;
          final appointmentSlots =
              appointmentSlotsMapArray.map<AppointmentSlot>((slot) {
            return AppointmentSlot.fromJSON(slot);
          }).toList();
          registeredContact.setAppointmentSlots(appointmentSlots);
          addNewContact(registeredContact);
        }
      }
    }
    print(_contacts);
    _isContactSearchCompleted = true;
    _isSearchInProgress = false;
    notifyListeners();
  }

  void searchRegisteredContact(RegisteredContact registeredContact) {
    final RegisteredContact? foundRC = _contacts.firstWhere(
        (rc) =>
            rc.phoneNo == registeredContact.phoneNo ||
            rc.id == registeredContact.id,
        orElse: () => registeredContact);
    if (foundRC!.fullName != null) {
      registeredContact.setFullName(foundRC.fullName!);
    }
  }
}
