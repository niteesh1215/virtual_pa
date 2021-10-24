import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';

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
            LengthValidationController(minimumLength: 0),
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
          return TextFormField(
            obscureText: isPasswordVisible,
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
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: showErrorBorder
                      ? Theme.of(context).errorColor
                      : Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: showErrorBorder
                      ? Theme.of(context).errorColor
                      : Colors.white,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).errorColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          );
        }),
      ),
    );
  }
}
