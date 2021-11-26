import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';
import 'package:virtual_pa/model/app_theme.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {Key? key,
      this.initialValue,
      required this.hintText,
      required this.inputType,
      this.borderRadius = 18,
      this.contentPadding = 20,
      this.textAlign = TextAlign.start,
      ValidationController? validationController,
      this.onSubmitted,
      this.onChange})
      : _validationController = validationController ??
            LengthValidationController(minimumLength: 0),
        super(key: key);
  final String? initialValue;
  final String hintText;
  final TextInputType inputType;
  final ValidationController? _validationController;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChange;
  final double borderRadius;
  final double contentPadding;
  final TextAlign textAlign;

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
            print(showErrorBorder);
            return TextFormField(
              initialValue: initialValue,
              textAlign: textAlign,
              onChanged: (String text) {
                print(text);
                validationController.validate(text);
                if (onChange != null) onChange!(text);
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
                contentPadding: EdgeInsets.all(contentPadding),
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
                          ? Colors.grey
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
        borderRadius: BorderRadius.circular(borderRadius),
      );
}
