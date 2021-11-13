import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:contacts_service/contacts_service.dart';

class LocalContacts {
  final BehaviorSubject<List<Contact>?> _localContactsController =
      BehaviorSubject<List<Contact>?>()..sink.add([]);

  LocalContacts() {
    readLocalContact();
  }

  Stream<List<Contact>?> get stream {
    return _localContactsController.stream;
  }

  void readLocalContact() async {
    // Load without thumbnails initially.
    List<Contact> contacts = await getContacts();
    if (contacts.isEmpty) {
      _addToSink(null);
      return;
    }


    // if return value is false that means stream is closed so don't proceed forward.
    if (!_addToSink(contacts)) return;

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        contact.avatar = avatar;
      });

      // if return value is false that means stream is closed so break the for loop.
      if (!_addToSink(contacts)) break;
    }
  }

  bool _addToSink(List<Contact>? contacts) {
    try {
      _localContactsController.sink.add(contacts);
      return true;
    } catch (e) {
      if (!_localContactsController.isClosed) {
        return false;
      } else {
        return true;
      }
    }
  }

  static Future<List<Contact>> getContacts() async {
    try {
      List<Contact> contacts = (await ContactsService.getContacts(
              photoHighResolution: false,
              withThumbnails: false,
              iOSLocalizedLabels: Platform.isIOS ? true : false))
          .toList();
      return contacts;
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _localContactsController.close();
  }
}
