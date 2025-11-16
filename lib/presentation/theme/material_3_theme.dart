// lib/presentation/theme/material_3_theme.dart
import 'package:flutter/material.dart';

// Material 3 theme implementation for cross-platform consistency
final ThemeData material3LightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue, // text color
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    filled: true,
    fillColor: Colors.grey.shade100,
  ),
  appBarTheme: AppBarTheme(
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
);

final ThemeData material3DarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue.shade300, // text color
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    filled: true,
    fillColor: Colors.grey.shade800,
  ),
  appBarTheme: AppBarTheme(
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
);

// Specific UI components following Material 3 design principles
class Material3Components {
  // Playback controls using Material 3 design
  static Widget playbackButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isPlaying = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        iconSize: 32,
        color: Colors.white,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }

  // Progress bar using Material 3 design with buffer indication
  static Widget progressBar({
    required BuildContext context,
    required double value,
    required double bufferedValue,
    required ValueChanged<double>? onChanged,
    Color? activeColor,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);
    final primaryColor = activeColor ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceVariant;

    return CustomPaint(
      painter: _BufferedSliderTrackPainter(
        value: value,
        bufferedValue: bufferedValue,
        activeColor: primaryColor,
        inactiveColor: bgColor,
      ),
      child: Slider(
        value: value,
        max: 1.0,
        onChanged: onChanged,
        activeColor: Colors.transparent, // Hide default track
        inactiveColor: Colors.transparent, // Hide default track
      ),
    );
  }
}

// Custom painter to draw a slider with buffered progress indication
class _BufferedSliderTrackPainter extends CustomPainter {
  final double value;
  final double bufferedValue;
  final Color activeColor;
  final Color inactiveColor;

  _BufferedSliderTrackPainter({
    required this.value,
    required this.bufferedValue,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Draw the buffered portion (lighter shade)
    if (bufferedValue > 0) {
      paint.color = activeColor.withOpacity(0.3);
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width * bufferedValue, size.height / 2),
        paint,
      );
    }

    // Draw the played portion (full color)
    if (value > 0) {
      paint.color = activeColor;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width * value, size.height / 2),
        paint,
      );
    }

    // Draw the remaining portion (inactive)
    if (value < 1.0) {
      paint.color = inactiveColor;
      canvas.drawLine(
        Offset(size.width * value, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}