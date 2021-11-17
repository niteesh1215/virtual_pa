import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme with ChangeNotifier {
  final Color _backgroundColor = Colors.black;
  final Color successColor = Colors.greenAccent;
  final Color borderColor = const Color(0xff454545);
  ThemeMode _themeMode = ThemeMode.dark;

  Color get backgroundColor => _backgroundColor;

  final h6Style = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  final body2Style = const TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  ThemeData getDarkTheme(context) {
    return ThemeData(
      scaffoldBackgroundColor: _backgroundColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme.dark(primary: Colors.white),
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
              headline6: h6Style,
              subtitle1: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              bodyText1: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
              bodyText2: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              caption: const TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
              button: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      appBarTheme:
          AppBarTheme(backgroundColor: _backgroundColor, centerTitle: true),
      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(backgroundColor: Colors.white),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xff1B1B1B),
        disabledColor: const Color(0xff1B1B1B),
        selectedColor: Colors.white,
        secondarySelectedColor: Colors.white,
        padding: const EdgeInsets.all(4.0),
        labelStyle:
            GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme.copyWith(
                  bodyText2: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                )).bodyText2!,
        secondaryLabelStyle:
            GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme.copyWith(
                  bodyText2: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                )).bodyText2!,
        brightness: Brightness.dark,
      ),
      /*dialogTheme: DialogTheme(
        backgroundColor: const Color(0xff1B1B1B),
        titleTextStyle: h6Style,
        contentTextStyle: body2Style.copyWith(color: Colors.white),
      ),*/
    );
  }

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
}
