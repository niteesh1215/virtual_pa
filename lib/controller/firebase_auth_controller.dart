import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:virtual_pa/utilities/common_functions.dart';

enum AuthErrorType { invalidPhoneNumber, unknownError }

class FirebaseAuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int? resendToken;
  String? verificationId;

  bool _isLoadingIndicatorVisible = false;

  Stream<User?> get authStateStream => _auth.authStateChanges();

  /*void addAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        onLogout();
      } else {
        onLogin();
      }
    });
  }*/

  User? getFirebaseUser() {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> verifyPhoneNumber(BuildContext context,
      {required String phoneNumber,
      int? resendToken,
      Function(AuthErrorType)? onError,
      Function(String verificatinId)? onAutoCodeRetrievalTimeout,
      Function(String verificationId)? onCodeSent}) async {
    _isLoadingIndicatorVisible = true;
    CommonFunctions.showCircularLoadingIndicatorDialog(context);
    print('dialog open');
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Verification completed');
          await _auth.signInWithCredential(credential);
          hideLoadingIndicator(context);
        },
        verificationFailed: (FirebaseAuthException e) {
          AuthErrorType errorType = AuthErrorType.unknownError;
          if (e.code == 'invalid-phone-number') {
            errorType = AuthErrorType.invalidPhoneNumber;
            CommonFunctions.showSnackBar(context, 'Verification');
          } else {
            CommonFunctions.showSnackBar(context, 'An error occurred');
          }
          hideLoadingIndicator(context);

          if (onError != null) {
            onError(errorType);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          this.resendToken = resendToken;
          CommonFunctions.showSnackBar(context, 'OTP sent on the phone number');
          hideLoadingIndicator(context);
          if (onCodeSent != null) {
            onCodeSent(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          hideLoadingIndicator(context);
          print('code auto retrieval tiemout');
          if (onAutoCodeRetrievalTimeout != null) {
            onAutoCodeRetrievalTimeout(verificationId);
          }
        },
        timeout: const Duration(seconds: 30),
        forceResendingToken: resendToken,
      );
    } catch (e) {
      showGeneralErrorMessage(context);
      hideLoadingIndicator(context);
    }
  }

  Future<void> signInWithOtp(BuildContext context,
      {required String verificationId, required String otp}) async {
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);

      // Sign the user in (or link) with the credential
      await _auth.signInWithCredential(credential);
      print('signed in with otp');
    } on FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      showGeneralErrorMessage(context);
    }
  }

  void showGeneralErrorMessage(BuildContext context) {
    CommonFunctions.showSnackBar(
        context, 'An error occurred, please check your internet connection ');
  }

  void hideLoadingIndicator(BuildContext context) {
    if (_isLoadingIndicatorVisible) {
      _isLoadingIndicatorVisible = false;
      Navigator.pop(context);
    }
  }
}
