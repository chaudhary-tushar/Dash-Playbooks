// lib/presentation/theme/app_theme.dart
import 'package:flutbook/core/theme/material_3_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => material3LightTheme;
  static ThemeData get darkTheme => material3DarkTheme;

  static ThemeData themeFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }
}
