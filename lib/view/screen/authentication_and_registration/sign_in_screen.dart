import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/constants.dart';
import 'package:virtual_pa/controller/textfield_validation_controller.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/utilities/custom_navigator.dart';
import 'package:virtual_pa/view/component/custom_password_field.dart';
import 'package:virtual_pa/view/component/custom_text_button.dart';
import 'package:virtual_pa/view/component/custom_text_field.dart';
import 'package:virtual_pa/view/screen/authentication_and_registration/register_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isPasswordVisible = true;
  final _formKey = GlobalKey<FormState>();
  late User _user;
  void _signIn() {
    if (_formKey.currentState!.validate()) {
      print('Form valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of(context, listen: false);
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
                      CustomTextField(
                        hintText: 'Phone',
                        inputType: TextInputType.text,
                        validationController: PhoneNumberValidationController(),
                        onChange: (phone) => _user.phoneNo = phone,
                      ),
                      CustomPasswordField(
                        isPasswordVisible: isPasswordVisible,
                        onTap: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        onChange: (password) => _user.password,
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
