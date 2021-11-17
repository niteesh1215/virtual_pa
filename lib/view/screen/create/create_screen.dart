import 'package:flutter/material.dart';
import 'package:virtual_pa/controller/create_task_or_appointment_controller.dart';
import 'package:virtual_pa/model/app_theme.dart';
import 'package:virtual_pa/model/registered_contact.dart';
import 'package:virtual_pa/view/component/buttons/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/view/component/custom_chip.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final CreateTaskOrAppointmentController
      _createTaskOrAppointmentController;

  @override
  void initState() {
    _createTaskOrAppointmentController = CreateTaskOrAppointmentController(
        context: context, textEditingController: _textEditingController);
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _createTaskOrAppointmentController,
      child: Scaffold(
        appBar: AppBar(
          leading: CustomIconButton(
            onPressed: () => Navigator.pop(context),
            iconData: Icons.arrow_back_ios_rounded,
          ),
          title: const Text('Create'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: context.read<AppTheme>().borderColor,
                    ),
                    borderRadius: BorderRadius.circular(18.0)),
                padding: const EdgeInsets.all(8.0),
                child: Scrollbar(
                  controller: _scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          scrollController: _scrollController,
                          focusNode: _focusNode,
                          controller: _textEditingController,
                          onChanged:
                              _createTaskOrAppointmentController.onChange,
                          validator:
                              _createTaskOrAppointmentController.validate,
                          autofocus: true,
                          scrollPadding: const EdgeInsets.all(8.0),
                          style: Theme.of(context).textTheme.bodyText2,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: '#task',
                            hintStyle:
                                Theme.of(context).textTheme.caption!.copyWith(
                                      color: Colors.grey,
                                    ),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Consumer<CreateTaskOrAppointmentController>(
                    builder: (context, createTaskOrAppointmentController, _) {
                  return createTaskOrAppointmentController.showMessageText
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Add a message e.g. \n' +
                                (createTaskOrAppointmentController
                                            .selectedCreateOption ==
                                        CreateOption.taskOptions
                                    ? '#task Complete the presentation.'
                                    : '#appointment Requesting appointment for a checkup.'),
                            // style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                        )
                      : Wrap(
                          children: [
                            ...createTaskOrAppointmentController.keywords
                                .map(
                                  (keyword) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: CustomChip(
                                      label: Text(keyword),
                                      onPressed: () =>
                                          createTaskOrAppointmentController
                                              .addKeywordToText(keyword),
                                    ),
                                  ),
                                )
                                .toList()
                          ],
                        );
                }),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onSubmit,
          child: const Icon(Icons.send_outlined),
        ),
      ),
    );
  }

  OutlineInputBorder border() => OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(18),
      );

  void onSubmit() {
    if (_formKey.currentState!.validate()) {
      print('valid');
    }
  }
}
