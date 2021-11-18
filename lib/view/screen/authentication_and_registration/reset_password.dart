import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/firebase_auth_controller.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/utilities/common_functions.dart';
import 'package:virtual_pa/view/component/buttons/custom_icon_button.dart';
import 'package:virtual_pa/view/component/buttons/custom_text_button.dart';
import 'package:virtual_pa/view/component/input_field/custom_password_field.dart';
import 'package:virtual_pa/view/component/input_field/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:virtual_pa/view/screen/authentication_and_registration/otp.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  late FirebaseAuthController _firebaseAuthController;
  late User _user;
  String? _countryCode = '+91';
  bool _showPasswordFields = false;

  bool _isOtpBottomSheetVisible = false;

  void _onTapNext() async {
    if (_formKey.currentState!.validate()) {
      if (_countryCode != null) {
        if (!_user.phoneNo!.contains(_countryCode!)) {
          _user.phoneNo = _countryCode! + _user.phoneNo!;
          print(_user.phoneNo);
        }
      } else {
        CommonFunctions.showSnackBar(context, 'Please select country');
        return;
      }

      await _firebaseAuthController.signOut();
      _firebaseAuthController.authStateStream.listen((fb.User? user) {
        if (user != null) {
          if (_isOtpBottomSheetVisible) Navigator.pop(context);
          _showPasswordFields = true;
          if (mounted) setState(() {});
        }
      });

      _firebaseAuthController.verifyPhoneNumber(context,
          phoneNumber: _user.phoneNo!, onCodeSent: (verificationId) async {
        _isOtpBottomSheetVisible = true;
        await CommonFunctions.showBottomSheet(
          context,
          child: OTP(
            onTapResend: () {
              _firebaseAuthController.verifyPhoneNumber(context,
                  phoneNumber: _user.phoneNo!);
            },
            onSubmitted: (String otp) {
              _firebaseAuthController.signInWithOtp(context,
                  verificationId: verificationId, otp: otp);
            },
          ),
        );
        _isOtpBottomSheetVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _firebaseAuthController =
        Provider.of<FirebaseAuthController>(context, listen: false);
    _user = Provider.of<User>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: CustomIconButton(
          iconData: Icons.arrow_back_ios_new_rounded,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          await _firebaseAuthController.signOut();
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _showPasswordFields
              ? const PasswordFields()
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        children: [
                          CountryCodePicker(
                            padding: const EdgeInsets.all(0.0),
                            onChanged: (CountryCode c) => _countryCode = c.code,
                            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                            initialSelection: 'IN',
                            // optional. Shows only country name and flag
                            showCountryOnly: false,
                            // optional. Shows only country name and flag when popup is closed.
                            showOnlyCountryWhenClosed: false,
                            // optional. aligns the flag and the Text left
                            alignLeft: false,
                            barrierColor: Colors.transparent,
                            boxDecoration:
                                const BoxDecoration(color: Colors.black),
                            flagDecoration: BoxDecoration(
                              border: Border.all(color: Colors.white54),
                            ),
                            textStyle: Theme.of(context).textTheme.bodyText2,
                          ),
                          Expanded(
                            child: CustomTextField(
                              hintText: 'Phone',
                              inputType: TextInputType.phone,
                              validationController:
                                  PhoneNumberValidationController(),
                              onChange: (phone) => _user.phoneNo = phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      CustomTextButton(
                        buttonName: 'Next',
                        onTap: _onTapNext,
                        bgColor: Colors.white,
                        textColor: Colors.black87,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class PasswordFields extends StatefulWidget {
  const PasswordFields({Key? key}) : super(key: key);

  @override
  State<PasswordFields> createState() => _PasswordFieldsState();
}

class _PasswordFieldsState extends State<PasswordFields> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfPassVisible = true;

  void onTapSubmit() {
    if (_formKey.currentState!.validate()) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 30,
          ),
          CustomPasswordField(
            validationController: LengthValidationController(minimumLength: 6),
            hintText: 'Password',
            onChange: (pass) => user.password = pass,
            onTapEye: () => setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            }),
            isPasswordVisible: _isPasswordVisible,
          ),
          const SizedBox(
            height: 30,
          ),
          CustomPasswordField(
            validationController: CustomValidationController(
                regExp: RegExp(user.password ?? ''),
                invalidMessage: 'Password doesn\'t match'),
            hintText: 'Confirm Password',
            onTapEye: () => setState(() {
              _isConfPassVisible = !_isConfPassVisible;
            }),
            isPasswordVisible: _isConfPassVisible,
          ),
          const SizedBox(
            height: 50,
          ),
          CustomTextButton(
            buttonName: 'Submit',
            onTap: onTapSubmit,
            bgColor: Colors.white,
            textColor: Colors.black87,
          ),
        ],
      ),
    );
  }
}
