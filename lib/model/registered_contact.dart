import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:virtual_pa/utilities/local_contacts.dart';

class RegisteredContact {
  String phoneNo;
  String fullName;
  String id;
  RegisteredContact(
      {required this.id, required this.phoneNo, required this.fullName});

  @override
  bool operator ==(other) {
    return (other is RegisteredContact) && other.phoneNo == phoneNo;
  }

  @override
  String toString() {
    return 'RegisteredContact{phoneNo: $phoneNo, fullName: $fullName, id: $id}';
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
    _isSearchInProgress = true;
    notifyListeners();
    List<Contact> contacts = await LocalContacts.getContacts();
    //todo: call api to verify
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
            if (!_contacts.contains(registeredContact)) {
              addNewContact(registeredContact);
            }
          }
        }
      }
    }

    _isContactSearchCompleted = true;
    _isSearchInProgress = false;
    notifyListeners();
  }
}
