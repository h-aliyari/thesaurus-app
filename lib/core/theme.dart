import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primarySwatch: Colors.green,
  fontFamily: 'IranSans',
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2F7831),
    secondary: Color.fromARGB(255, 64, 127, 66),
    background: Colors.white,
    surface: Colors.white,
    onPrimary: Colors.white,
    onBackground: Color(0xFF323232),
    onSurface: Color(0xFF323232),
  ),
  cardTheme: const CardThemeData(
    color: Colors.white,
    elevation: 2,
    shadowColor: Colors.black12,
    margin: EdgeInsets.all(8),
    surfaceTintColor: Colors.transparent,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primarySwatch: Colors.green,
  fontFamily: 'IranSans',
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF7AD97F),
    secondary: Color.fromARGB(255, 66, 133, 68),
    background: Color(0xFF2C2C2C),
    surface: Color(0xFF121212),
    onPrimary: Colors.white,
    onBackground: Colors.white70,
    onSurface: Colors.white70,
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF121212),
    elevation: 2,
    shadowColor: Colors.black45,
    margin: EdgeInsets.all(8),
    surfaceTintColor: Colors.transparent,
  ),
);