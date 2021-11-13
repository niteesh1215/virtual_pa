import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/model/registered_contact.dart';
import 'package:virtual_pa/view/component/buttons/custom_icon_button.dart';

enum SelectedCreateOption { mainOptions, taskOptions, appointmentOptions }

const Map<SelectedCreateOption, List<String>> _kCreateKeywords = {
  SelectedCreateOption.mainOptions: ['#task', '#appointment'],
  SelectedCreateOption.taskOptions: ['@', '#completeBy', '#urgent'],
  SelectedCreateOption.appointmentOptions: ['@', '#date', '#slot'],
};

class CreateTaskOrAppointmentController with ChangeNotifier {
  CreateTaskOrAppointmentController({
    required this.context,
    required this.textEditingController,
  });

  final BuildContext context;
  final TextEditingController textEditingController;
  List<String> _removedList = [];
  SelectedCreateOption _selectedCreateOption = SelectedCreateOption.mainOptions;
  bool _showDateTimePicker = false;
  bool _showDatePicker = false;
  bool _showContactsPicker = false;
  bool _showSlotPicker = false;
  bool _showMessageText = false;

  SelectedCreateOption get selectedCreateOption => _selectedCreateOption;

  bool get showDateTimePicker => _showDateTimePicker;

  set showDateTimePicker(bool value) {
    if (_showDateTimePicker != value) {
      _showDateTimePicker = value;
      if (value) {
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          minTime: DateTime.now(),
          maxTime: Jiffy().add(days: 365).dateTime,
          onChanged: (date) {},
          onConfirm: (date) {
            addKeywordToText(Jiffy(date).yMMMMEEEEdjm);
          },
          onCancel: () {
            replaceText(
                textEditingController.text.replaceAll('#completeBy', ''));
          },
          currentTime: DateTime.now(),
        );
      }
      notifyListeners();
    }
  }

  bool get showDatePicker => _showDatePicker;

  set showDatePicker(bool value) {
    if (_showDatePicker != value) {
      _showDatePicker = value;
      if (value) {
        DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          minTime: DateTime.now(),
          maxTime: Jiffy().add(days: 365).dateTime,
          onChanged: (date) {},
          onConfirm: (date) {
            addKeywordToText(Jiffy(date).yMMMMd);
          },
          onCancel: () {
            replaceText(textEditingController.text.replaceAll('#date', ''));
          },
          currentTime: DateTime.now(),
        );
      }
      notifyListeners();
    }
  }

  bool get showContactsPicker => _showContactsPicker;

  set showContactsPicker(bool value) {
    if (_showDateTimePicker != value) {
      _showContactsPicker = value;
      notifyListeners();
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        backgroundColor: Colors.black,
        context: context,
        builder: (context) {
          return ContactPicker(
            onClose: () {
              replaceText(textEditingController.text.replaceAll('@', ''));
              Navigator.pop(context);
            },
            onSelected: (RegisteredContact contact) {
              replaceText(textEditingController.text.trim()+contact.fullName);
            },
          );
        },
      );
    }
  }

  bool get showSlotPicker => _showSlotPicker;

  set showSlotPicker(bool value) {
    if (_showSlotPicker != value) {
      _showSlotPicker = value;
      notifyListeners();
    }
  }

  bool get showMessageText => _showMessageText;

  set showMessageText(bool value) {
    if (_showMessageText != value) {
      _showMessageText = value;
      notifyListeners();
    }
  }

  void onChange(String text) {
    List<String> selectedKeywordList =
        _selectedCreateOption == SelectedCreateOption.mainOptions
            ? []
            : _kCreateKeywords[_selectedCreateOption]!;

    if (text.contains(_mainOptions.first)) {
      const option = SelectedCreateOption.taskOptions;
      //reset the _removedList only if the _selectedCreateOption changed
      if (_selectedCreateOption != option) {
        _removedList = [];
        _selectedCreateOption = option;
        selectedKeywordList = _kCreateKeywords[option]!;
      }
    } else if (text.contains(_mainOptions[1])) {
      const option = SelectedCreateOption.appointmentOptions;
      //reset the _removedList only if the _selectedCreateOption changed
      if (_selectedCreateOption != option) {
        _removedList = [];
        _selectedCreateOption = option;
        selectedKeywordList = _kCreateKeywords[option]!;
      }
    } else {
      if (_selectedCreateOption != SelectedCreateOption.mainOptions) {
        _selectedCreateOption = SelectedCreateOption.mainOptions;
        selectedKeywordList = [];
      }
    }

    //resetting
    _showMessageText = false;
    _showSlotPicker = false;
    _showDateTimePicker = false;
    _showDatePicker = false;
    _showContactsPicker = false;
    notifyListeners();

    int index = selectedCreateOption == SelectedCreateOption.taskOptions
        ? text.trim().length - '#task'.length
        : text.trim().length - '#appointment'.length;

    if (index >= 0) {
      String tempSubString = text.trim().substring(index);
      if (tempSubString == '#task' || tempSubString == '#appointment') {
        _showMessageText = true;
        notifyListeners();
        return;
      }
    }

    for (String keyword in selectedKeywordList) {
      if (text.contains(keyword)) {
        removeKeyword(keyword);
      } else {
        addKeyword(keyword);
      }

      final int startIndex = text.trim().length - keyword.length;
      if (startIndex > 0 && text.trim().substring(startIndex) == keyword) {
        switch (keyword) {
          case '#task':
          case '#appointment':
            showMessageText = true;
            break;
          case '@':
            showContactsPicker = true;
            break;
          case '#date':
            showDatePicker = true;
            break;
          case '#completeBy':
            showDateTimePicker = true;
            break;
          case '#slot':
            showSlotPicker = true;
            break;
        }
      }
    }
  }

  String? validate(String? text) {
    if (text == null || text.isEmpty) return 'Cannot be empty';

    if (!text.contains(_mainOptions.first) || !text.contains(_mainOptions[1])) {
      return 'Must contain #task or #appointment';
    } else if (text.contains(_mainOptions.first) &&
        text.contains(_mainOptions[1])) {
      return 'Cannot have #task and #appointment, specify only one';
    } else if (_selectedCreateOption == SelectedCreateOption.taskOptions) {
      // TODO: check for message
      for (String keyword
          in _kCreateKeywords[SelectedCreateOption.taskOptions]!) {
        if (keyword == '#urgent') continue;
        if (!text.contains(keyword)) {
          return '$keyword is required';
        }
      }
    } else if (_selectedCreateOption ==
        SelectedCreateOption.appointmentOptions) {
      for (String keyword
          in _kCreateKeywords[SelectedCreateOption.appointmentOptions]!) {
        if (!text.contains(keyword)) {
          return '$keyword is required';
        }
      }
    }
    return null;
  }

  String sanitize(String text) {
    final removeKeywords =
        _selectedCreateOption == SelectedCreateOption.taskOptions
            ? _kCreateKeywords[SelectedCreateOption.appointmentOptions]!
            : _kCreateKeywords[SelectedCreateOption.taskOptions];

    for (String keyword in removeKeywords!) {
      if (keyword == '@') continue;
      if (text.contains(keyword)) {
        text.replaceAll(keyword, '');
      }
    }

    return text;
  }

  List<String> get keywords {
    final List<String> list = [];
    final selectedKeywordList = _kCreateKeywords[_selectedCreateOption]!;
    for (String keyword in selectedKeywordList) {
      if (!_removedList.contains(keyword)) {
        list.add(keyword);
      }
    }

    return list;
  }

  void removeKeyword(String keyword) {
    if (!_removedList.contains(keyword)) {
      _removedList.add(keyword);
      notifyListeners();
    }
  }

  void addKeyword(String keyword) {
    _removedList.remove(keyword);
    notifyListeners();
  }

  void addKeywordToText(String keyword) {
    String newText = textEditingController.text;
    if (newText.isEmpty || newText[newText.length - 1] == ' ') {
      newText = newText + keyword + ' ';
    } else {
      newText = newText + ' ' + keyword + ' ';
    }
    textEditingController.text = newText;
    moveTheCaretPositionToEnd();

    //calling on change because it doesn't get called automatically if the text
    // is changed through text editing controller
    onChange(textEditingController.text);
  }

  void replaceText(String text) {
    textEditingController.text = text.trim();
    moveTheCaretPositionToEnd();
    onChange(textEditingController.text);
  }

  void moveTheCaretPositionToEnd() =>
      textEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));

  List<String> get _mainOptions =>
      _kCreateKeywords[SelectedCreateOption.mainOptions]!;
}

class ContactPicker extends StatelessWidget {
  const ContactPicker(
      {Key? key, required this.onClose, required this.onSelected})
      : super(key: key);
  final VoidCallback onClose;
  final void Function(RegisteredContact) onSelected;
  @override
  Widget build(BuildContext context) {
    final registeredContacts = Provider.of<RegisteredContacts>(context);
    final contacts = registeredContacts.contacts;
    return Padding(
      padding:
          const EdgeInsets.only(left: 15.0, right: 15.0, top: 5, bottom: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Choose Contact'),
              CustomIconButton(
                iconData: Icons.close,
                onPressed: onClose,
              ),
            ],
          ),
          Expanded(
              child: ListView.separated(
            itemCount: contacts.length,
            itemBuilder: (context, i) {
              final contact = contacts[i];
              return ListTile(
                onTap: () {
                  onSelected(contact);
                  Navigator.pop(context);
                },
                title: Text(contact.fullName),
                subtitle: Text(
                  contact.phoneNo,
                  style: Theme.of(context).textTheme.caption,
                ),
              );
            },
            separatorBuilder: (context, i) {
              return const Divider(
                color: Colors.white12,
                height: 2.0,
              );
            },
          ))
        ],
      ),
    );
  }
}
