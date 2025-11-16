// lib/data/datasources/local/error_handler.dart
import 'package:flutter/material.dart';

// Custom exception types for specific error scenarios
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}

class AudioException implements Exception {
  final String message;
  AudioException(this.message);
}

class FileSystemException implements Exception {
  final String message;
  FileSystemException(this.message);
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

/// Error handling infrastructure per constitution requirements (no raw stack traces)
class ErrorHandler {
  /// Handles exceptions and creates user-friendly error messages
  /// No raw stack traces in UI as required by constitution
  static String handleException(dynamic exception, {String fallbackMessage = 'An error occurred'}) {
    if (exception is ArgumentError) {
      return 'Invalid argument provided. Please check your input.';
    } else if (exception is FileSystemException) {
      return 'File system access issue. Please check file permissions.';
    } else if (exception is FormatException) {
      return 'Data format issue. Please check your input.';
    } else if (exception is TimeoutException) {
      return 'Operation timed out. Please try again.';
    } else if (exception is NetworkException) {
      return 'Network connection issue. Please check your internet connection.';
    } else if (exception is StorageException) {
      return 'Storage issue. Please check available space.';
    } else if (exception is PermissionException) {
      return 'Permission denied. Please grant necessary permissions.';
    } else if (exception is AuthenticationException) {
      return 'Authentication issue. Please verify your credentials.';
    } else if (exception is DatabaseException) {
      return 'Database error occurred. Please restart the app.';
    } else if (exception is AudioException) {
      return 'Audio playback issue. Please check your file.';
    } else {
      // Generic message without raw stack trace per constitution
      return fallbackMessage;
    }
  }

  /// Shows error dialog to user with clear, non-technical messaging
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error Occurred'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Logs errors for debugging (not displayed to user)
  static void logError(dynamic error, StackTrace stackTrace) {
    // Log for development but don't show to user
    print('Error: $error');
    print('Stack trace: $stackTrace');
  }
}