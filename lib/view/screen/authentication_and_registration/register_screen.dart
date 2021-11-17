import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/constants.dart';
import 'package:virtual_pa/controller/firebase_auth_controller.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/utilities/common_functions.dart';
import 'package:virtual_pa/utilities/custom_navigator.dart';
import 'package:virtual_pa/view/component/input_field/custom_password_field.dart';
import 'package:virtual_pa/view/component/buttons/custom_text_button.dart';
import 'package:virtual_pa/view/component/input_field/custom_text_field.dart';
import 'package:virtual_pa/view/screen/authentication_and_registration/otp.dart';
import 'package:virtual_pa/view/screen/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _passwordVisibility = true;
  String? countryCode = '+91';
  final _formKey = GlobalKey<FormState>();

  late User _user;
  late FirebaseAuthController _firebaseAuthController;

  void _register(BuildContext context) {
    CommonFunctions.showBottomSheet(
      context,
      child: OTP(
        onTapResend: () {},
      ),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.8,
      ),
    );
    return;
    if (_formKey.currentState!.validate()) {
      if (countryCode != null) {
        _user.phoneNo = countryCode! + _user.phoneNo!;
      } else {
        CommonFunctions.showSnackBar(context, 'Please select country');
      }

      _firebaseAuthController.verifyPhoneNumber(context,
          phoneNumber: _user.phoneNo!);

      /*Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );*/
    }
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
                            onChanged: (CountryCode c) => countryCode = c.code,
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
                        onTap: () {
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
