import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme with ChangeNotifier {
  final Color _backgroundColor = const Color(0xff191720);
  final Color successColor = Colors.greenAccent;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeData getDarkThem(context) {
    return ThemeData(
      scaffoldBackgroundColor: _backgroundColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme.dark(),
      errorColor: Colors.red,
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme.copyWith(
              headline2: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
              headline4: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
              bodyText1: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
              bodyText2: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              button: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      appBarTheme: AppBarTheme(backgroundColor: _backgroundColor),

    );
  }

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
}
