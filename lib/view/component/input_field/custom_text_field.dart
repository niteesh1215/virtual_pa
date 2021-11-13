import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';
import 'package:virtual_pa/model/app_theme.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {Key? key,
      required this.hintText,
      required this.inputType,
      ValidationController? validationController,
      this.onSubmitted,
      this.onChange})
      : _validationController = validationController ??
            LengthValidationController(minimumLength: 0),
        super(key: key);
  final String hintText;
  final TextInputType inputType;
  final ValidationController? _validationController;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChange;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _validationController!,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Consumer<ValidationController>(
          builder: (context, validationController, _) {
            bool showErrorBorder = validationController.isValid == null ||
                    validationController.isValid!
                ? false
                : true;
            return TextFormField(
              onChanged: (String text) {
                validationController.validate(text);
                if (onChange == null) onChange!(text);
              },
              onFieldSubmitted: onSubmitted,
              validator: (String? text) {
                if (text == null || !validationController.validate(text)) {
                  return validationController.invalidMessage;
                }
                return null;
              },
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white),
              keyboardType: inputType,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20),
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyText1,
                enabledBorder: border(
                  context,
                  color: showErrorBorder
                      ? Theme.of(context).errorColor
                      : Colors.grey,
                ),
                focusedBorder: border(
                  context,
                  color: showErrorBorder
                      ? Theme.of(context).errorColor
                      : validationController.isValid == null
                          ? Colors.white
                          : context.read<AppTheme>().successColor,
                ),
                errorBorder: border(
                  context,
                  color: showErrorBorder
                      ? Theme.of(context).errorColor
                      : context.read<AppTheme>().successColor,
                ),
                focusedErrorBorder: border(
                  context,
                  color: showErrorBorder
                      ? Theme.of(context).errorColor
                      : context.read<AppTheme>().successColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  OutlineInputBorder border(BuildContext context, {required Color color}) =>
      OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(18),
      );
}
