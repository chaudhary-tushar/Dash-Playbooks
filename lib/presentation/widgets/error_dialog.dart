// lib/presentation/widgets/error_dialog.dart
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? retryActionLabel;
  final VoidCallback? onRetry;
  final String? dismissActionLabel;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.retryActionLabel = 'Try Again',
    this.onRetry,
    this.dismissActionLabel = 'OK',
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (onRetry != null) ...[
          TextButton(
            onPressed: onRetry,
            child: Text(retryActionLabel!),
          ),
        ],
        TextButton(
          onPressed: onDismiss ?? () => Navigator.of(context).pop(),
          child: Text(dismissActionLabel!),
        ),
      ],
    );
  }

  /// Convenience method to show a simple error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title,
          message: message,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  /// Convenience method to show an error dialog with retry option
  static Future<bool> showErrorDialogWithRetry(
    BuildContext context,
    String title,
    String message,
  ) async {
    bool shouldRetry = false;
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ErrorDialog(
              title: title,
              message: message,
              retryActionLabel: 'Retry',
              onRetry: () {
                shouldRetry = true;
                Navigator.of(context).pop();
              },
              dismissActionLabel: 'Cancel',
              onDismiss: () {
                shouldRetry = false;
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
    
    return shouldRetry;
  }
}