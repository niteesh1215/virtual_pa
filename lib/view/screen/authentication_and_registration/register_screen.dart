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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _passwordVisibility = true;
  final _formKey = GlobalKey<FormState>();
  late User _user;

  void _register() {
    if (_formKey.currentState!.validate()) {
      print('form is valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);
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
                      CustomTextField(
                        hintText: 'Phone',
                        inputType: TextInputType.phone,
                        validationController: PhoneNumberValidationController(),
                        onChange: (phone) => _user.phoneNo = phone,
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
                  onTap: _register,
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
