import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF08B5E5);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: primaryBlue,
        fontFamily: 'JetBrains Mono',
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: primaryBlue,
        fontFamily: 'JetBrains Mono',
      );
}
