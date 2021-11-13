import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/model/app_theme.dart';
import 'package:virtual_pa/model/registered_contact.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/view/component/custom_scroll_behavior.dart';
import 'package:virtual_pa/view/screen/welcome_screen.dart';

void main() {
  runApp(const VirtualPA());
}

class VirtualPA extends StatelessWidget {
  const VirtualPA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppTheme()),
        ChangeNotifierProvider(create: (context) => User()),
        ChangeNotifierProvider(create: (context) => RegisteredContacts()),
      ],
      child: Consumer<AppTheme>(
        builder: (context, appTheme, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'VirtualPA',
            darkTheme: appTheme.getDarkTheme(context),
            themeMode: appTheme.themeMode,
            home: child,
            scrollBehavior: const CustomScrollBehavior(),
          );
        },
        child: const WelcomeScreen(),
      ),
    );
  }
}
