import 'package:flutter/cupertino.dart';

class CustomNavigator {
 static void navigateTo(BuildContext context, WidgetBuilder builder) => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: builder,
        ),
      );
}
