import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/constants.dart';
import 'package:virtual_pa/controller/api_end_points/user_api_controller.dart';
import 'package:virtual_pa/controller/firebase_auth_controller.dart';
import 'package:virtual_pa/controller/hive_controller.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/utilities/common_functions.dart';
import 'package:virtual_pa/utilities/custom_navigator.dart';
import 'package:virtual_pa/view/component/input_field/custom_password_field.dart';
import 'package:virtual_pa/view/component/buttons/custom_text_button.dart';
import 'package:virtual_pa/view/component/input_field/custom_text_field.dart';
import 'package:virtual_pa/view/screen/authentication_and_registration/otp.dart';
import 'package:virtual_pa/view/screen/authentication_and_registration/register_screen.dart';
import 'package:virtual_pa/view/screen/authentication_and_registration/reset_password.dart';
import 'package:virtual_pa/view/screen/home/home_screen.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isPasswordVisible = true;
  String? _countryCode = '+91';
  final _formKey = GlobalKey<FormState>();
  late User _user;
  late FirebaseAuthController _firebaseAuthController;
  bool requestSent = false;

  void _signIn() async {
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

      CommonFunctions.showCircularLoadingIndicatorDialog(context);
      final userAPIController = UserAPIController();
      final lResponse =
          await userAPIController.retrieveUser(phoneNo: _user.phoneNo);
      if (lResponse.responseStatus == ResponseStatus.success &&
          lResponse.data != null) {
        Navigator.pop(context);
      } else {
        CommonFunctions.showSnackBar(
          context,
          'Phone number is not registered, please register',
        );
        Navigator.pop(context);
        return;
      }

      _firebaseAuthController.authStateStream.listen((fb.User? user) async {
        if (user != null && !requestSent) {
          requestSent = true;
          CommonFunctions.showCircularLoadingIndicatorDialog(context);
          await Provider.of<HiveController>(context, listen: false)
              .addUser(lResponse.data!);
          _user.copyForm(lResponse.data!);
          Navigator.of(context);
          CustomNavigator.navigateTo(context, (context) => const HomeScreen());
        }
      });

      _firebaseAuthController.verifyPhoneNumber(context,
          phoneNumber: _user.phoneNo!, onCodeSent: (verificationId) {
        CommonFunctions.showBottomSheet(
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
      });
    }
  }

  /*void _onTapForgotPassword() =>
      CustomNavigator.navigateTo(context, (context) => const ResetPassword());*/

  @override
  Widget build(BuildContext context) {
    _user = Provider.of(context, listen: false);
    _firebaseAuthController = Provider.of<FirebaseAuthController>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            kBackIcon,
            height: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        //to make page scrollable
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome back.",
                  style: Theme.of(context).textTheme.headline2,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "You've been missed!",
                  style: Theme.of(context).textTheme.headline4,
                ),
                const SizedBox(
                  height: 60,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                              inputType: TextInputType.text,
                              validationController:
                                  PhoneNumberValidationController(),
                              onChange: (phone) => _user.phoneNo = phone,
                            ),
                          ),
                        ],
                      ),
                      /*CustomPasswordField(
                        isPasswordVisible: isPasswordVisible,
                        onTapEye: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        onChange: (password) => _user.password,
                      ),*/
                    ],
                  ),
                ),
                /*Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: _onTapForgotPassword,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Text('Forgot password ?',
                          style: Theme.of(context).textTheme.bodyText1),
                    ),
                  ),
                ),*/
                const SizedBox(
                  height: 50.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    GestureDetector(
                      onTap: () => CustomNavigator.navigateTo(
                          context, (context) => const RegisterScreen()),
                      child: Text(
                        'Register',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextButton(
                  buttonName: 'Sign In',
                  onTap: _signIn,
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
