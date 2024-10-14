import 'dart:ui';
import 'package:flutter/material.dart';

class Styles {
  static int _bluePrimaryValue = 0xff215aa9;
  static int _bluePrimaryValue1 = 0xffae75f9;
  static MaterialColor swatchLight = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
      50: Color(0xff94a8c6),
      100: Color(0xff8096b6),
      200: Color(0xff6b83a5),
      300: Color(0xff5e79a0),
      400: Color(0xff5473a0),
      500: Color(0xff476da3),
      600: Color(0xff3c67a5),
      700: Color(0xff3564a7),
      800: Color(0xff2b5fa7),
      900: Color(0xff215aa9),
    },
  );

  static MaterialColor swatchDart = MaterialColor(
    _bluePrimaryValue1,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primarySwatch: isDarkTheme ? swatchDart : swatchLight,
      primaryColor: isDarkTheme ? Colors.black : Colors.white,
      accentColor: isDarkTheme ? Color(0xFF2196F3) : Color(0xff215aa9),
      primaryColorLight: isDarkTheme ? Colors.white : Colors.black,
      // fontFamily: 'TimesNewRoman',
      fontFamily: 'Roboto',
      backgroundColor: isDarkTheme ? Colors.black : Color(0xffF1F5FB),
      indicatorColor: isDarkTheme ? Color(0xff08162d) : Color(0xffCBDCF8),
      buttonColor: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),
      hintColor: isDarkTheme ? Color(0xff4b4949) : Color(0xffc6c4c4),
      highlightColor: isDarkTheme ? Color(0xff3b3b3b) : Color(0x22215aa9),
      hoverColor: isDarkTheme ? Color(0xff3a3a3b) : Color(0xff4285F4),
      //focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      focusColor: isDarkTheme ? Color(0xffbbbbbb) : Colors.black,
      iconTheme: IconThemeData(color: isDarkTheme ? Colors.white : Colors.black),

      cardColor: isDarkTheme ? Color(0xFF222222) : Colors.white,
      secondaryHeaderColor: isDarkTheme ? Color(0xff4285F4) : Colors.white,
      canvasColor: isDarkTheme ? Color(0xFF1A1A1A) : Colors.grey[50],

      unselectedWidgetColor: Colors.grey,
      timePickerTheme: TimePickerThemeData(),

      //App Bar text Color
      primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
      primaryIconTheme: IconThemeData(
        color: Colors.white, //change your color here
      ),
      dialogBackgroundColor: isDarkTheme ? Color(0xFF151515) : Colors.white,
      // popupMenuTheme: PopupMenuThemeData(
      //   color: isDarkTheme ? Color(0xFF151515) : Colors.white,
      // ),

      inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          labelStyle: TextStyle(color: isDarkTheme ? Color(0xff4b4949) : Color(0xffc6c4c4)),
          hintStyle: TextStyle(color: Colors.grey)),

      shadowColor: isDarkTheme ? Color(0xffd5d5d5) : Colors.black,
     //textTheme: isDarkTheme ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      textTheme: TextTheme(
        headline1: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        headline2: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        headline3: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        headline4: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        headline5: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        headline6: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        caption: TextStyle(
          color: isDarkTheme ? Color(0xFFA8A6A6) : Color(0xFF4E4D4D),
        ),
        bodyText1: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        bodyText2: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        button: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
      buttonTheme:
          Theme.of(context).buttonTheme.copyWith(colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
      appBarTheme: AppBarTheme(
        elevation: 0.5,
      ),
    );
  }

  static TextStyle h1 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static TextStyle h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static TextStyle h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static TextStyle h4 = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  static TextStyle h5 = TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  static TextStyle subtitle1 = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey);
  static TextStyle subtitle2 = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey);

  static TextStyle caption1 = TextStyle(fontSize: 14, color: Colors.grey);
  static TextStyle caption2 = TextStyle(fontSize: 12, color: Colors.grey);
}
