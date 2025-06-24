import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey[50],
    cardColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black87,
      background: Colors.grey[50]!,
      onBackground: Colors.black87,
    ),
    dividerColor: Colors.grey[300],
    indicatorColor: Colors.green,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'openSans',
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey[850],
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.white,
      surface: Colors.grey[850]!,
      onSurface: Colors.white,
      background: Colors.grey[900]!,
      onBackground: Colors.white,
    ),
    dividerColor: Colors.grey[700],
    indicatorColor: Colors.green,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'openSans',
      ),
    ),
  );
}
