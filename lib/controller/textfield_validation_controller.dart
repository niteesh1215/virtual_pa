import 'package:flutter/foundation.dart';

class ValidationController with ChangeNotifier {
  ValidationController({required RegExp regExp, String? invalidMessage})
      : _regExp = regExp,
        invalidMessage = invalidMessage ?? 'Please enter a valid input.';
  final RegExp _regExp;
  bool? _isValid;
  final String invalidMessage;

  bool? get isValid => _isValid;

  set isValid(bool? isValid) {
    _isValid = isValid;
    notifyListeners();
  }

  bool validate(String text) {
    isValid = _regExp.hasMatch(text);
    return isValid!;
  }
}

class PhoneNumberValidationController extends ValidationController {
  PhoneNumberValidationController({String? invalidMessage})
      : super(regExp: RegExp(r"^[0-9]{10}$"), invalidMessage: invalidMessage);
}

class LengthValidationController extends ValidationController {
  LengthValidationController(
      {required int minimumLength, String? invalidMessage})
      : assert(minimumLength >= 0, 'minimum length cannot be negative'),
        super(
            regExp: RegExp(
              r"^[a-zA-Z]{" + minimumLength.toString() + ",}\$",
            ),
            invalidMessage: invalidMessage);
}
