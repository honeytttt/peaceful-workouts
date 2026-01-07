import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  );
}