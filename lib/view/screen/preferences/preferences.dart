import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';
import 'package:virtual_pa/view/component/buttons/custom_icon_button.dart';
import 'package:virtual_pa/view/component/input_field/custom_text_field.dart';

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  final CustomValidationController _customValidationController =
      CustomValidationController(
          regExp: RegExp(r" [1-9][0-9]*$"),
          invalidMessage: 'Number should be greater than 0');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
          children: [
            Row(
              children: [
                const Text('Task Limit'),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        validationController: _customValidationController,
                        hintText: 'Task Limit',
                        inputType: TextInputType.number,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: [
                const Text('Appointment'),
                FlutterSwitch(
                  value: false,
                  onToggle: (value) {},
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
