import 'package:flutter/material.dart';

final colorScheme = ColorScheme.fromSeed(
  seedColor: Colors.lightGreenAccent,
  brightness: Brightness.light,
);
final lightTheme = ThemeData.light().copyWith(
  colorScheme: colorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.onPrimary,
      foregroundColor: colorScheme.primary,
    ),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.onPrimary,
    foregroundColor: colorScheme.primary,
  ),
  iconTheme: IconThemeData(color: Colors.teal),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.teal,
    displayColor: Colors.teal,
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.teal),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.teal),
    ),
  ),
);
