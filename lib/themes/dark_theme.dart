import 'package:flutter/material.dart';

final colorScheme = ColorScheme.fromSeed(
  seedColor: Colors.indigoAccent,
  brightness: Brightness.dark,
);
final darkTheme = ThemeData.dark().copyWith(
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
  iconTheme: IconThemeData(color: Colors.red),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.red,
    displayColor: Colors.red,
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.red),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
  ),
);
