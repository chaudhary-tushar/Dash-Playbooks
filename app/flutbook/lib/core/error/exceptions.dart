/// Error handling utilities for local data sources in Flutbook.
/// Defines custom exception classes (NetworkException, StorageException, etc.)
/// and [ErrorHandler] for converting technical errors to user-friendly messages.
library;

// lib/data/datasources/local/error_handler.dart
import 'package:flutter/material.dart';

// Custom exception types for specific error scenarios
class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;
}

class StorageException implements Exception {
  StorageException(this.message);
  final String message;
}

class PermissionException implements Exception {
  PermissionException(this.message);
  final String message;
}

class AuthenticationException implements Exception {
  AuthenticationException(this.message);
  final String message;
}

class DatabaseException implements Exception {
  DatabaseException(this.message);
  final String message;
}

class AudioException implements Exception {
  AudioException(this.message);
  final String message;
}

class FileSystemException implements Exception {
  FileSystemException(this.message);
  final String message;
}

class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;
}

/// Error handling infrastructure per constitution requirements (no raw stack traces)
class ErrorHandler {
  /// Handles exceptions and creates user-friendly error messages
  /// No raw stack traces in UI as required by constitution
  static String handleException(
    dynamic exception, {
    String fallbackMessage = 'An error occurred',
  }) {
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
  static Future<void> showErrorDialog(
    BuildContext context,
    String message,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error Occurred'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
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
