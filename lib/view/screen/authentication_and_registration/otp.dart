import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:virtual_pa/controller/timer_controller.dart';
import 'package:virtual_pa/view/component/buttons/custom_icon_button.dart';

class OTP extends StatefulWidget {
  const OTP({Key? key, required this.onTapResend}) : super(key: key);
  final VoidCallback onTapResend;

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  final TextEditingController _textEditingController = TextEditingController();
  final ValueNotifier<bool> _resendButtonEnabledNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<int> _otpResendCountDownNotifier = ValueNotifier<int>(60);
  late final TimerController _timerController;

  @override
  void initState() {
    _resendButtonEnabledNotifier.value = false;
    _timerController = TimerController(
        duration: const Duration(seconds: 1),
        timerCallback: () {
          _otpResendCountDownNotifier.value -= 1;
          if (_otpResendCountDownNotifier.value == 0) {
            _timerController.stop();
            _resendButtonEnabledNotifier.value = true;
          }
        });
    super.initState();
  }

  void _resendOTP() {
    _resendButtonEnabledNotifier.value = false;
    _otpResendCountDownNotifier.value = 60;
    _timerController.restart();
    widget.onTapResend();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _errorController.close();
    _resendButtonEnabledNotifier.dispose();
    // _textEditingController.dispose();
    _otpResendCountDownNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _resendButtonEnabledNotifier,
          builder: (context, isResendButtonEnabled, _) {
            return Row(
              children: [
                CustomIconButton(
                  iconData: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(
                  width: 20,
                ),
                const Text('Enter OTP'),
                const Spacer(),
                if (!isResendButtonEnabled)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _otpResendCountDownNotifier,
                      builder: (context, countDown, _) {
                        final temp = '0$countDown'; //for two digit
                        return Text(
                          'Resend OTP in 00:${temp.substring(temp.length - 2)}',
                        );
                      },
                    ),
                  )
                else
                  TextButton(
                      onPressed: _resendOTP, child: const Text('Resend')),
                const SizedBox(
                  width: 10,
                )
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: PinCodeTextField(
            appContext: context,
            pastedTextStyle: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.bold,
            ),
            autoFocus: true,
            length: 6,
            obscureText: false,
            obscuringCharacter: '*',
            animationType: AnimationType.fade,
            validator: (v) {
              /*if (!RegExp(r"^[0-9]{6}$").hasMatch(v ?? '')) {
                  return "Please enter a valid OTP";
                } else {
                  return null;
                }*/
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5),
              fieldHeight: 60,
              fieldWidth: 50,
              activeColor: Colors.white,
              inactiveColor: Colors.white,
              selectedColor: Colors.white,
            ),
            cursorColor: Colors.white,
            animationDuration: const Duration(milliseconds: 300),
            textStyle: const TextStyle(fontSize: 20, height: 1.6),
            errorAnimationController: _errorController,
            controller: _textEditingController,
            keyboardType: TextInputType.number,
            boxShadows: const [
              BoxShadow(
                offset: Offset(0, 1),
                color: Colors.black12,
                blurRadius: 10,
              )
            ],
            onCompleted: (v) {
              print("Completed");
            },
            // onTap: () {
            //   print("Pressed");
            // },
            onChanged: (value) {},
            beforeTextPaste: (text) {
              print("Allowing to paste $text");
              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
              //but you can show anything you want here, like your pop up saying wrong paste format or etc
              return RegExp(r"^[0-9]{6}$").hasMatch(text ?? '') ? true : false;
            },
          ),
        ),
      ],
    );
  }
}
