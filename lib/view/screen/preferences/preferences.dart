import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/api_end_points/user_api_controller.dart';
import 'package:virtual_pa/controller/hive_controller.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';
import 'package:virtual_pa/model/app_theme.dart';
import 'package:virtual_pa/model/appointment_slot.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/preference_data.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/utilities/common_functions.dart';
import 'package:virtual_pa/view/component/buttons/custom_icon_button.dart';
import 'package:virtual_pa/view/component/buttons/custom_text_button.dart';
import 'package:virtual_pa/view/component/input_field/custom_text_field.dart';

final RegExp numberOnlyRegExp = RegExp(r"^0*[1-9]\d*$");

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  final CustomValidationController _customValidationController =
      CustomValidationController(
    regExp: numberOnlyRegExp,
    invalidMessage: 'Number should be greater than 0',
  );

  User? user;
  late PreferencesData preferencesData;
  final _formKey = GlobalKey<FormState>();

  Future<bool> showBottomSheet() async {
    final AppointmentSlot? appointmentSlot =
        await CommonFunctions.showBottomSheet(context,
            child: const CreateAppointmentSlot());
    if (appointmentSlot != null) {
      if (!preferencesData.appointmentSlots.contains(appointmentSlot)) {
        preferencesData.addAppointmentSlot(appointmentSlot);
      } else {
        CommonFunctions.showSnackBar(context, 'Slot already exists');
        return false;
      }

      return true;
    }
    return false;
  }

  void updatePreferences(BuildContext context) async {
    final UserAPIController userAPIController = UserAPIController();
    CommonFunctions.showCircularLoadingIndicatorDialog(context);
    final LResponse<User?> lResponse =
        await userAPIController.updatePreferences(
            userId: user!.userId!, preferencesData: preferencesData);
    if (lResponse.responseStatus == ResponseStatus.failed ||
        lResponse.data == null) {
      Navigator.pop(context);
      print(lResponse.message);
      CommonFunctions.showSnackBar(context, 'Failed to update');
    } else {
      final lUser = lResponse.data!;
      user!.isAppointmentEnabled = lUser.isAppointmentEnabled;
      user!.taskLimit = lUser.taskLimit;
      user!.appointmentSlots = lUser.appointmentSlots;
      final HiveController hiveController =
          Provider.of<HiveController>(context, listen: false);
      hiveController.addUser(user!);
      Navigator.pop(context);
      CommonFunctions.showSnackBar(context, 'Updated Successfully');
      setState(() {
        preferencesData.isChanged = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      user = Provider.of<User>(context);
      print(user!.userId);
      preferencesData = PreferencesData(
        isAppointmentEnabled: user!.isAppointmentEnabled,
        taskLimit: user!.taskLimit,
        appointmentSlot: user!.appointmentSlots!
            .map<AppointmentSlot>((slot) => slot.copyWith())
            .toList(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: CustomIconButton(
          onPressed: () => Navigator.pop(context),
          iconData: Icons.arrow_back_ios_rounded,
        ),
        title: const Text('Preferences'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Task Limit: '),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 150,
                          child: CustomTextField(
                            initialValue: preferencesData.taskLimit.toString(),
                            validationController: _customValidationController,
                            hintText: 'Task Limit',
                            inputType: TextInputType.number,
                            contentPadding: 10,
                            borderRadius: 5,
                            onChange: (v) {
                              print(v);
                              final int? parsed = int.tryParse(v);
                              if (parsed != null) {
                                preferencesData.taskLimit = parsed;
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Text('Appointment Enabled'),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Center(
                    child: FlutterSwitch(
                      height: 25,
                      width: 50,
                      padding: 2,
                      borderRadius: 25,
                      toggleSize: 20.0,
                      activeColor: context.read<AppTheme>().successColor,
                      value: preferencesData.isAppointmentEnabled,
                      onToggle: (value) async {
                        if (preferencesData.appointmentSlots.isEmpty) {
                          if (await showBottomSheet()) {
                            setState(() {
                              preferencesData.isAppointmentEnabled = value;
                            });
                          }
                        } else {
                          setState(() {
                            preferencesData.isAppointmentEnabled = value;
                          });
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 15.0,
            ),
            if (preferencesData.appointmentSlots.isNotEmpty)
              const Text('Appointment Slots'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: preferencesData.appointmentSlots.length,
              itemBuilder: (context, index) {
                final appointmentSlot = preferencesData.appointmentSlots[index];
                return ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Row(
                    children: [
                      Text(appointmentSlot.timing!),
                      Expanded(
                        child: Center(
                            child: Text(appointmentSlot.maxLimit.toString())),
                      )
                    ],
                  ),
                  trailing: CustomIconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      preferencesData.removeAppointmentSlot(appointmentSlot);
                      setState(() {});
                    },
                  ),
                );
              },
            ),
            if (preferencesData.appointmentSlots.isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: CustomIconButton(
                  onPressed: () async {
                    if (await showBottomSheet()) {
                      setState(() {});
                    }
                  },
                  iconData: Icons.add,
                ),
              ),
            const Spacer(),
            if (preferencesData.isChanged)
              CustomTextButton(
                buttonName: 'Update Preferences',
                onTap: () => updatePreferences(context),
                bgColor: Theme.of(context).colorScheme.primary,
                textColor: Colors.black,
              )
          ],
        ),
      ),
    );
  }
}

class CreateAppointmentSlot extends StatefulWidget {
  const CreateAppointmentSlot({Key? key}) : super(key: key);

  @override
  State<CreateAppointmentSlot> createState() => _CreateAppointmentSlotState();
}

class _CreateAppointmentSlotState extends State<CreateAppointmentSlot> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentSlot _appointmentSlot =
      AppointmentSlot(timing: '08:00 AM - 09:00 AM');
  final timeFormat = 'hh:mm a';
  bool _showTimeErrorMessage = false;
  String message = '';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Create Appointment Slot'),
              CustomIconButton(
                iconData: Icons.close,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('Select start time'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  InkWell(
                    onTap: () {
                      final currentDT = Jiffy(
                              _appointmentSlot.timing!.split('-').first.trim(),
                              timeFormat)
                          .dateTime;
                      DatePicker.showTime12hPicker(
                        context,
                        currentTime: currentDT,
                        onConfirm: (DateTime? dateTime) {
                          if (dateTime != null) {
                            _appointmentSlot.timing = Jiffy(dateTime)
                                    .format(timeFormat) +
                                ' - ' +
                                _appointmentSlot.timing!.split('-').last.trim();
                            setState(() {});
                          }
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: context.read<AppTheme>().borderColor),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Row(
                        children: [
                          Text(
                              _appointmentSlot.timing!.split('-').first.trim()),
                          const SizedBox(
                            width: 10.0,
                          ),
                          const Icon(Icons.schedule)
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  const Text('Select end time'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  InkWell(
                    onTap: () {
                      final currentDT = Jiffy(
                              _appointmentSlot.timing!.split('-').last.trim(),
                              timeFormat)
                          .dateTime;
                      DatePicker.showTime12hPicker(
                        context,
                        currentTime: currentDT,
                        onConfirm: (DateTime? dateTime) {
                          if (dateTime != null) {
                            _appointmentSlot.timing = _appointmentSlot.timing!
                                    .split('-')
                                    .first
                                    .trim() +
                                ' - ' +
                                Jiffy(dateTime).format(timeFormat);
                            setState(() {});
                          }
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: context.read<AppTheme>().borderColor),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Row(
                        children: [
                          Text(_appointmentSlot.timing!.split('-').last.trim()),
                          const SizedBox(
                            width: 10.0,
                          ),
                          const Icon(Icons.schedule)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          if (_showTimeErrorMessage)
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Theme.of(context).errorColor),
            ),
          SizedBox(
            width: 150,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    validationController: CustomValidationController(
                        regExp: numberOnlyRegExp,
                        invalidMessage: 'Number only'),
                    hintText: 'Max Limit',
                    inputType: TextInputType.number,
                    contentPadding: 10,
                    borderRadius: 5,
                    textAlign: TextAlign.center,
                    onChange: (v) {
                      final int? parsed = int.tryParse(v);
                      if (parsed != null) {
                        _appointmentSlot.maxLimit = parsed;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          MaterialButton(
            color: Theme.of(context).colorScheme.primary,
            height: 60,
            minWidth: 60,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            onPressed: () {
              final startTime = Jiffy(
                      _appointmentSlot.timing!.split('-').first.trim(),
                      timeFormat)
                  .dateTime;
              final endTime = Jiffy(
                      _appointmentSlot.timing!.split('-').last.trim(),
                      timeFormat)
                  .dateTime;

              if (_formKey.currentState!.validate()) {
                if (startTime.difference(endTime).inMinutes == 0) {
                  _showTimeErrorMessage = true;
                  message = 'Duration cannot be 0';
                  setState(() {});
                } else if (endTime.isBefore(startTime)) {
                  _showTimeErrorMessage = true;
                  message = 'End time cannot be before start time';
                  setState(() {});
                } else {
                  _showTimeErrorMessage = false;
                  setState(() {});
                  Navigator.pop(context, _appointmentSlot);
                }
              }
            },
            child: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
