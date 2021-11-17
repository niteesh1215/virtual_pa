import 'package:flutter/material.dart';

class CommonFunctions {
  static void showBottomSheet(context,
      {required Widget child,
      bool isDismissible = true,
      BoxConstraints? constraints}) {
    showModalBottomSheet(
      isDismissible: isDismissible,
      constraints: constraints,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      backgroundColor: Colors.black,
      context: context,
      builder: (context) {
        return child;
      },
    );
  }

  static void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showCircularLoadingIndicatorDialog(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}