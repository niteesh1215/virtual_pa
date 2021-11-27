import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/api_end_points/user_api_controller.dart';
import 'package:virtual_pa/model/appointment.dart';
import 'package:virtual_pa/model/appointment_slot.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/registered_contact.dart';
import 'package:virtual_pa/model/task.dart';
import 'package:virtual_pa/utilities/common_functions.dart';
import 'package:virtual_pa/view/component/buttons/custom_icon_button.dart';
import 'package:virtual_pa/view/component/custom_chip.dart';

enum CreateOption { mainOptions, taskOptions, appointmentOptions }

const Map<CreateOption, List<String>> _kCreateKeywords = {
  CreateOption.mainOptions: ['#task', '#appointment'],
  CreateOption.taskOptions: ['@', '#completeBy', '#urgent'],
  CreateOption.appointmentOptions: ['@', '#date', '#slot'],
};

class CreateTaskOrAppointmentController with ChangeNotifier {
  CreateTaskOrAppointmentController({
    required this.context,
    required this.textEditingController,
  });

  List<RegisteredContact> selectedContactForTask = [];
  Task? _task;
  Appointment? _appointment;

  final BuildContext context;
  final TextEditingController textEditingController;
  List<String> _removedList = [];
  CreateOption _selectedCreateOption = CreateOption.mainOptions;
  bool _showDateTimePicker = false;
  bool _showDatePicker = false;
  bool _showContactsPicker = false;
  bool _showSlotPicker = false;
  bool _showMessageText = false;

  void reset() {
    _task = null;
    _appointment = null;
    textEditingController.clear();
    _selectedCreateOption = CreateOption.mainOptions;
    _showDateTimePicker = false;
    _showDatePicker = false;
    _showContactsPicker = false;
    _showSlotPicker = false;
    _showMessageText = false;
    _removedList = [];
  }

  Task? get task => _task;
  Appointment? get appointment => _appointment;

  CreateOption get selectedCreateOption => _selectedCreateOption;

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
            _task?.completeBy = date;
          },
          onCancel: () {
            _task?.completeBy = null;
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
            _appointment?.date = date;
          },
          onCancel: () {
            _appointment?.date = null;
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
      CommonFunctions.showBottomSheet(context,
          child: ContactPicker(
            showOnlyAppointmentEnabled:
                selectedCreateOption == CreateOption.appointmentOptions,
            onClose: () {
              if (selectedCreateOption == CreateOption.appointmentOptions) {
                _appointment?.atUserId = null;
              }
            },
            onSelected: (RegisteredContact contact) {
              bool replace = true;
              if (selectedCreateOption == CreateOption.taskOptions) {
                _task?.atUserId = contact.id;
                if (!selectedContactForTask.contains(contact)) {
                  selectedContactForTask.add(contact);
                } else {
                  CommonFunctions.showSnackBar(
                      context, 'Contact already added');
                  replace = false;
                }
              } else if (selectedCreateOption ==
                  CreateOption.appointmentOptions) {
                _appointment?.atUserId = contact.id;
              }

              if (replace) {
                replaceText(
                    textEditingController.text.trim() + contact.fullName! + ' ',
                    trim: false);
              }
            },
          ),
          isDismissible: false);
    }
  }

  bool get showSlotPicker => _showSlotPicker;

  set showSlotPicker(bool value) {
    if (appointment == null || appointment!.atUserId == null) {
      CommonFunctions.showSnackBar(
          context, 'Please select @ before selecting slot');
      return;
    }
    if (_showSlotPicker != value) {
      _showSlotPicker = value;
      notifyListeners();
      CommonFunctions.showBottomSheet(context,
          child: SlotPicker(
            userId: appointment!.atUserId!,
            onClose: () {
              replaceText(textEditingController.text.replaceAll('#slot', ''));
            },
            onSelected: (String slot) {
              _appointment?.slot = slot;
              replaceText(textEditingController.text.trim() + ' ' + slot + ' ',
                  trim: false);
            },
          ),
          isDismissible: false);
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
        _selectedCreateOption == CreateOption.mainOptions
            ? []
            : _kCreateKeywords[_selectedCreateOption]!;

    if (text.contains(_mainOptions.first)) {
      const option = CreateOption.taskOptions;
      //reset the _removedList only if the _selectedCreateOption changed
      if (_selectedCreateOption != option) {
        _task = Task(
          taskString: '',
        );
        _removedList = [];
        _selectedCreateOption = option;
        selectedKeywordList = _kCreateKeywords[option]!;
      }
      _task!.taskString = text;
    } else if (text.contains(_mainOptions[1])) {
      const option = CreateOption.appointmentOptions;
      //reset the _removedList only if the _selectedCreateOption changed
      if (_selectedCreateOption != option) {
        _appointment =
            Appointment(byUserId: '', phoneNo: '', appointmentString: text);
        _removedList = [];
        _selectedCreateOption = option;
        selectedKeywordList = _kCreateKeywords[option]!;
      }
      _appointment?.appointmentString = text;
    } else {
      if (_selectedCreateOption != CreateOption.mainOptions) {
        _task = null;
        _appointment = null;
        _selectedCreateOption = CreateOption.mainOptions;
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

    int index = selectedCreateOption == CreateOption.taskOptions
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

    print(_task);
    print(_appointment);

    if (selectedCreateOption == CreateOption.taskOptions) {
      final registeredContacts = [...selectedContactForTask];
      for (RegisteredContact rc in registeredContacts) {
        if (!text.contains('@' + rc.fullName!)) {
          selectedContactForTask.remove(rc);
        }
      }
    }

    print("*********** selected contact");
    print(selectedContactForTask);
    print("*********** selected contact");

    for (String keyword in selectedKeywordList) {
      if (text.contains(keyword)) {
        if (keyword != '@' ||
            selectedCreateOption == CreateOption.appointmentOptions) {
          removeKeyword(keyword);
        }
      } else {
        //when keyword is removed from the taskString
        if (selectedCreateOption == CreateOption.taskOptions) {
          switch (keyword) {
            case '#completeBy':
              _task?.completeBy = null;
              break;
            case '#urgent':
              _task?.urgent = false;
              break;
          }
        } else {
          switch (keyword) {
            case '@':
              _appointment?.atUserId = null;
              break;
            case '#date':
              _appointment?.date = null;
              break;
            case '#slot':
              _appointment?.slot = null;
              break;
          }
        }
        addKeyword(keyword);
      }
    }

    //final int startIndex = text.trim().length - keyword.length;
    final String trimmedText = text.trimRight();

    if (trimmedText.isEmpty) return;

    final int startIndex = trimmedText[trimmedText.length - 1] == '@'
        ? trimmedText.length - 1
        : text.lastIndexOf('#');
    if (startIndex >= 0) {
      final String keyword = trimmedText.substring(startIndex);
      /*check if the keyword already exits if yes then don't allow more except for @ only when selectedCreateOption == CreateOption.appointmentOptions*/
      if (keyword != '@' ||
          selectedCreateOption == CreateOption.appointmentOptions) {
        if (text.indexOf(keyword) != startIndex) {
          replaceText(text.substring(0, startIndex), trim: false);
          return;
        }
      }
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

  String? validate(String? text) {
    if (text == null || text.isEmpty) return 'Cannot be empty';

    if (!text.contains(_mainOptions.first) && !text.contains(_mainOptions[1])) {
      return 'Must contain #task or #appointment';
    } else if (text.trim() == '#task' || text.trim() == '#appointment') {
      return 'Enter a message';
    } else if (text.contains(_mainOptions.first) &&
        text.contains(_mainOptions[1])) {
      return 'Cannot have #task and #appointment, specify only one';
    } else if (_selectedCreateOption == CreateOption.taskOptions) {
      // TODO: check for message
      for (String keyword in _kCreateKeywords[CreateOption.taskOptions]!) {
        //#urgent keyword is optional so don't go further
        if (keyword == '#urgent') continue;
        if (!text.contains(keyword)) {
          return '$keyword is required';
        }
      }
      if (selectedContactForTask.isEmpty) {
        return 'At least one recipient is required, use @ to add';
      }
    } else if (_selectedCreateOption == CreateOption.appointmentOptions) {
      for (String keyword
          in _kCreateKeywords[CreateOption.appointmentOptions]!) {
        if (!text.contains(keyword)) {
          return '$keyword is required';
        }
      }
    }
    replaceText(sanitize(text));
    return null;
  }

  String sanitize(String text) {
    final removeKeywords = _selectedCreateOption == CreateOption.taskOptions
        ? _kCreateKeywords[CreateOption.appointmentOptions]!
        : _kCreateKeywords[CreateOption.taskOptions];

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
    if (keyword == '#urgent') _task?.urgent = true;
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

  void replaceText(String text, {bool trim = true}) {
    textEditingController.text = trim ? text.trim() : text;
    moveTheCaretPositionToEnd();
    onChange(textEditingController.text);
  }

  void moveTheCaretPositionToEnd() =>
      textEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));

  List<String> get _mainOptions => _kCreateKeywords[CreateOption.mainOptions]!;
}

class ContactPicker extends StatelessWidget {
  const ContactPicker({
    Key? key,
    required this.onClose,
    required this.onSelected,
    this.showOnlyAppointmentEnabled = false,
  }) : super(key: key);
  final VoidCallback onClose;
  final void Function(RegisteredContact) onSelected;
  final bool showOnlyAppointmentEnabled;

  @override
  Widget build(BuildContext context) {
    final registeredContacts = Provider.of<RegisteredContacts>(context);
    late final List<RegisteredContact> contacts;
    if (showOnlyAppointmentEnabled) {
      contacts = registeredContacts.contacts
          .where((rc) => rc.isAppointmentEnabled ?? false)
          .toList();
    } else {
      contacts = registeredContacts.contacts;
    }
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
                onPressed: () {
                  onClose();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Expanded(
              child: contacts.isEmpty
                  ? const Center(
                      child:
                          Text('None of your contacts has enabled appointment'),
                    )
                  : ListView.separated(
                      itemCount: contacts.length,
                      itemBuilder: (context, i) {
                        final contact = contacts[i];
                        return ListTile(
                          onTap: () {
                            onSelected(contact);
                            Navigator.pop(context);
                          },
                          title: Text(contact.fullName!),
                          subtitle: Text(
                            contact.phoneNo!,
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

class SlotPicker extends StatelessWidget {
  const SlotPicker(
      {Key? key,
      required this.userId,
      required this.onClose,
      required this.onSelected})
      : super(key: key);
  final String userId;
  final VoidCallback onClose;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 15.0, right: 15.0, top: 5, bottom: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Choose Slot'),
              CustomIconButton(
                iconData: Icons.close,
                onPressed: () {
                  onClose();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<LResponse<List<AppointmentSlot>?>>(
                future: UserAPIController().retrieveAppointment(userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final lResponse = snapshot.data!;

                  if (lResponse.responseStatus == ResponseStatus.failed) {
                    return const Center(
                      child:
                          Text('Could not fetch the slots, an error occurred'),
                    );
                  } else if (lResponse.data != null &&
                      lResponse.data!.isEmpty) {
                    return const Center(
                      child: Text('Appointments are not enabled by this user'),
                    );
                  }

                  final appointmentSlots = lResponse.data!;

                  return SingleChildScrollView(
                    child: Wrap(
                      children: [
                        for (int i = 0; i < appointmentSlots.length; i++)
                          Padding(
                            padding:
                                EdgeInsets.only(right: i % 2 != 0 ? 0.0 : 15.0),
                            child: CustomChip(
                              label: Text(
                                  appointmentSlots[i].timing!.toUpperCase()),
                              onPressed: () {
                                onSelected(
                                  appointmentSlots[i].timing!.toUpperCase(),
                                );
                                Navigator.pop(context);
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
