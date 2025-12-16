// lib/shared/theme/material_3_theme.dart
import 'package:flutter/material.dart';

// Material 3 theme implementation for cross-platform consistency
final ThemeData material3LightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
    ),
  ),
);
