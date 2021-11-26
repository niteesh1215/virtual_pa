import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class CommonFunctions {
  static Future<T?> showBottomSheet<T>(context,
      {required Widget child,
      bool isDismissible = true,
      BoxConstraints? constraints}) async {
    return await showModalBottomSheet<T>(
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

  static String cutString(String text, int maxCharacters) {
    if (text.length <= maxCharacters) return text;
    return text.substring(0, maxCharacters - 1) + '...';
  }
}
