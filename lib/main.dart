import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:virtual_pa/controller/firebase_auth_controller.dart';
import 'package:virtual_pa/controller/hive_controller.dart';
import 'package:virtual_pa/model/app_theme.dart';
import 'package:virtual_pa/model/registered_contact.dart';
import 'package:virtual_pa/model/tasks.dart';
import 'package:virtual_pa/model/user.dart';
import 'package:virtual_pa/utilities/permission_handler.dart';
import 'package:virtual_pa/view/component/custom_scroll_behavior.dart';
import 'package:virtual_pa/view/screen/home/home_screen.dart';
import 'package:virtual_pa/view/screen/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VirtualPA());
}

class VirtualPA extends StatefulWidget {
  const VirtualPA({Key? key}) : super(key: key);

  @override
  State<VirtualPA> createState() => _VirtualPAState();
}

class _VirtualPAState extends State<VirtualPA> {
  bool _isInitializationCompleted = false;
  FirebaseAuthController? firebaseAuthController;
  final appTheme = AppTheme();
  User? user;
  final registeredContacts = RegisteredContacts();
  final tasks = Tasks();
  final hiveController = HiveController();

  Future<void> _initialize() async {
    if (_isInitializationCompleted) return;
    _isInitializationCompleted = true;
    try {
      await Firebase.initializeApp();
      await hiveController.init();
      await hiveController.openBox();
      final hiveUser = await hiveController.getUser();
      user = hiveUser ?? User();
    } catch (e) {
      _isInitializationCompleted = false;
      print('#001 main.dart Error while initializing' + e.toString());
    }
  }

  @override
  void dispose() {
    hiveController.closeBoxes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const MaterialApp(home: Scaffold());
          }
          firebaseAuthController ??= FirebaseAuthController();
          user ??= User();
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: appTheme),
              ChangeNotifierProvider.value(value: user),
              ChangeNotifierProvider.value(value: registeredContacts),
              ChangeNotifierProvider.value(value: tasks),
              ChangeNotifierProvider.value(value: firebaseAuthController),
              Provider.value(value: hiveController),
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
              child: firebaseAuthController!.getFirebaseUser() == null ||
                      user?.userId == null
                  ? const WelcomeScreen()
                  : const HomeScreen(),
            ),
          );
        });
  }
}
