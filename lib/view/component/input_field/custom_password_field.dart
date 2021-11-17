import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';
import 'package:virtual_pa/model/app_theme.dart';

class CustomPasswordField extends StatelessWidget {
  CustomPasswordField(
      {Key? key,
      this.hintText,
      required this.isPasswordVisible,
      required this.onTap,
      ValidationController? validationController,
      this.onSubmitted,
      this.onChange})
      : _validationController = validationController ??
            LengthValidationController(minimumLength: 6),
        super(key: key);
  final String? hintText;

  final ValidationController? _validationController;
  final bool isPasswordVisible;
  final VoidCallback onTap;
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
          print(showErrorBorder);
          return TextFormField(
            obscureText: isPasswordVisible,
            onChanged: (String text) {
              print(text);
              final status = validationController.validate(text);
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
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: onTap,
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.all(20),
              hintText: hintText ?? 'Password',
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
              errorBorder: border(context,
                  color: showErrorBorder
                      ? Theme.of(context).errorColor
                      : context.read<AppTheme>().successColor),
              focusedErrorBorder: border(context,
                  color: showErrorBorder
                      ? Theme.of(context).errorColor
                      : context.read<AppTheme>().successColor),
            ),
          );
        }),
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
