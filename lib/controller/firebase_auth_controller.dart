import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:virtual_pa/utilities/common_functions.dart';

enum AuthErrorType { invalidPhoneNumber, unknownError }

class FirebaseAuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int? resendToken;
  String? verificationId;

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

  Future<void> verifyPhoneNumber(BuildContext context,
      {required String phoneNumber,
      int? resendToken,
      Function(AuthErrorType)? onError}) async {
    bool isLoadingIndicatorVisible = true;
    CommonFunctions.showCircularLoadingIndicatorDialog(context);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          hideLoadingIndicator(context);
          isLoadingIndicatorVisible = false;
        },
        verificationFailed: (FirebaseAuthException e) {
          AuthErrorType errorType = AuthErrorType.unknownError;
          if (e.code == 'invalid-phone-number') {
            errorType = AuthErrorType.unknownError;
            print('The provided phone number is not valid.');
          }
          hideLoadingIndicator(context);
          isLoadingIndicatorVisible = false;
          if (onError != null) {
            onError(errorType);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          this.resendToken = resendToken;

          CommonFunctions.showSnackBar(context, 'Otp sent on the phone number');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isLoadingIndicatorVisible = false;
          hideLoadingIndicator(context);
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
      );
    } catch (e) {
      showGeneralErrorMessage(context);
    }
    if (isLoadingIndicatorVisible) hideLoadingIndicator(context);
  }

  Future<void> signInWithOtp(BuildContext context,
      {required String verificationId, required String otp}) async {
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);

      // Sign the user in (or link) with the credential
      await _auth.signInWithCredential(credential);
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
    Navigator.pop(context);
  }
}
