import 'package:country_code_picker/country_code_picker.dart';
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
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:virtual_pa/view/screen/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _passwordVisibility = true;
  String? _countryCode = '+91';
  final _formKey = GlobalKey<FormState>();

  late User _user;
  late FirebaseAuthController _firebaseAuthController;
  bool requestSent = false;

  void _register(BuildContext context) async {
    try {
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
        _firebaseAuthController.authStateStream.listen((fb.User? user) async {
          if (user != null && !requestSent) {
            requestSent = true;
            CommonFunctions.showCircularLoadingIndicatorDialog(context);
            final userAPIController = UserAPIController();
            final LResponse<User?> response =
                await userAPIController.addUser(_user);
            print(context.widget.runtimeType);
            if (response.responseStatus == ResponseStatus.success) {
              _user.userId = response.data!.userId;
              await Provider.of<HiveController>(context, listen: false)
                  .addUser(_user);
              Navigator.of(context);
              CustomNavigator.navigateTo(
                  context, (context) => const HomeScreen());
            } else {
              CommonFunctions.showSnackBar(context, response.message);
              requestSent = false;
              Navigator.of(context);
            }
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

        /*Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );*/
      }
    } catch (e) {
      requestSent = false;
      print('#001 An error occurred while registering');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context, listen: false);
    _firebaseAuthController =
        Provider.of<FirebaseAuthController>(context, listen: false);
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Register",
                  style: Theme.of(context).textTheme.headline2,
                ),
                Text(
                  "Create new account to get started.",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        hintText: 'Name',
                        inputType: TextInputType.name,
                        validationController:
                            LengthValidationController(minimumLength: 2),
                        onChange: (name) => _user.name = name,
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
                      CustomPasswordField(
                        isPasswordVisible: _passwordVisibility,
                        onTapEye: () {
                          setState(() {
                            _passwordVisibility = !_passwordVisibility;
                          });
                        },
                        onChange: (pass) => _user.password = pass,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    GestureDetector(
                      onTap: () => CustomNavigator.navigateTo(
                        context,
                        (context) => const RegisterScreen(),
                      ),
                      child: Text(
                        "Sign In",
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextButton(
                  buttonName: 'Register',
                  onTap: () => _register(context),
                  bgColor: Colors.white,
                  textColor: Colors.black87,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
