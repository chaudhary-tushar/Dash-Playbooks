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

class UninitializedDatasourceException implements Exception {
  UninitializedDatasourceException(this.message);
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

class NotFoundException implements Exception {
  NotFoundException(this.message);
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
    } else if (exception is UninitializedDatasourceException) {
      return 'Data source not initialized. Please wait and try again.';
    } else if (exception is AudioException) {
      return 'Audio playback issue. Please check your file.';
    } else {
      // Generic message without raw stack trace per constitution
      return fallbackMessage;
    }
  }

  /// Handles playback-specific exceptions with more detailed user-friendly messages
  static String handlePlaybackException(
    dynamic exception, {
    String fallbackMessage = 'Playback failed. Please try again.',
  }) {
    if (exception is UninitializedDatasourceException) {
      return 'Playback service is not ready. Please wait a moment and try again.';
    } else if (exception is FileSystemException) {
      return 'Audio file not found or inaccessible. Please check your files and permissions.';
    } else if (exception is AudioException) {
      return 'Audio file is corrupted or unsupported. Please try another file or convert this one.';
    } else if (exception is DatabaseException) {
      return 'Could not load playback history. Some features may be limited. Please restart the app.';
    } else if (exception is PermissionException) {
      return 'Storage permission required. Please grant access to your files in app settings.';
    } else if (exception is NetworkException) {
      return 'Network required for this feature. Please check your connection and try again.';
    } else if (exception is TimeoutException) {
      return 'Playback initialization timed out. Please check your network and try again.';
    } else if (exception.toString().contains('Isar database is not open')) {
      return 'Database not ready. Please wait a few seconds and try again.';
    } else if (exception.toString().contains('PlaybackRepository')) {
      return 'Playback service unavailable. Please restart the app to fix this issue.';
    } else if (exception.toString().contains('null')) {
      return 'Playback service not properly initialized. Please restart the app.';
    } else if (exception.toString().contains('failed to initialize')) {
      return 'Playback initialization failed. Please check your device storage and restart the app.';
    } else {
      // More specific fallback for playback issues
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

  /// Shows playback-specific error dialog with retry option
  static Future<bool> showPlaybackErrorDialog(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Playback Error'),
              content: Text(message),
              actions: [
                if (onRetry != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onRetry();
                    },
                    child: const Text('Retry'),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Shows notification for unavailable playback features
  static void showPlaybackUnavailableNotification(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Shows success notification for retry attempts
  static void showRetryAttemptNotification(
    BuildContext context,
    int attemptNumber,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Retrying playback... (Attempt $attemptNumber)'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Checks playback feature availability and shows appropriate notifications
  /// Returns true if playback features are available, false otherwise
  static Future<bool> checkPlaybackFeaturesAndNotify(
    BuildContext context,
    Map<String, dynamic> featureStatus,
  ) async {
    if (featureStatus['available'] as bool) {
      return true;
    } else {
      // Show specific notification based on the reason
      final reason = featureStatus['reason'] as String?;
      final message = featureStatus['message'] as String?;
      final suggestion = featureStatus['suggestion'] as String?;

      if (reason != null && message != null) {
        showFeatureUnavailableNotification(
          context,
          'Playback',
          '$message. $suggestion',
        );
      } else {
        showFeatureUnavailableNotification(
          context,
          'Playback',
          'Playback features are currently unavailable. Please try again later.',
        );
      }
      return false;
    }
  }

  /// Shows error notification with retry option
  static void showPlaybackErrorWithRetry(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(child: Text(message)),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('RETRY'),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Shows feature unavailable notification with action button
  static void showFeatureUnavailableNotification(
    BuildContext context,
    String featureName,
    String reason,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName unavailable: $reason'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  /// Logs errors for debugging (not displayed to user)
  static void logError(dynamic error, StackTrace stackTrace) {
    // Log for development but don't show to user
    print('Error: $error');
    print('Stack trace: $stackTrace');
  }
}
