import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class CommonFunctions {
  static Future<void> showBottomSheet(context,
      {required Widget child,
      bool isDismissible = true,
      BoxConstraints? constraints}) async {
    await showModalBottomSheet(
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

  static String getddMMyyyyhmmssa(DateTime dateTime) {
    return Jiffy(dateTime).format('dd-MM-yyyy h:mm:ss a');
  }

  static DateTime getDateFromddMMyyyyhmmssa(String dateTimeString) {
    return Jiffy(dateTimeString, 'dd-MM-yyyy h:mm:ss a').dateTime;
  }

  static String getddMMyyyy(DateTime dateTime) {
    return Jiffy(dateTime).format('dd-MM-yyyy');
  }

  static DateTime getDateFromddMMyyyy(String dateTimeString) {
    return Jiffy(dateTimeString, 'dd-MM-yyyy').dateTime;
  }
}
