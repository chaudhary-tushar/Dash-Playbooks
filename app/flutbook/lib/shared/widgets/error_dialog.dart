// lib/shared/widgets/error_dialog.dart
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    required this.title,
    required this.message,
    super.key,
    this.retryActionLabel = 'Try Again',
    this.onRetry,
    this.dismissActionLabel = 'OK',
    this.onDismiss,
  });

  final String title;
  final String message;
  final String? retryActionLabel;
  final VoidCallback? onRetry;
  final String? dismissActionLabel;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    // Determine the list of action buttons based on provided callbacks
    final List<Widget> actions = [];

    // 1. Dismiss Action (Always include, either with custom callback or default behavior)
    if (dismissActionLabel != null) {
      actions.add(
        TextButton(
          // If onDismiss is provided, use it. Otherwise, use Navigator.pop to close the dialog.
          onPressed: onDismiss ?? () => Navigator.of(context).pop(),
          child: Text(dismissActionLabel!),
        ),
      );
    }

    // 2. Retry Action (Only include if onRetry callback is provided)
    if (onRetry != null && retryActionLabel != null) {
      actions.add(
        TextButton(
          onPressed: () {
            // Dismiss the dialog first, then execute the retry callback
            Navigator.of(context).pop();
            onRetry!();
          },
          child: Text(retryActionLabel!),
        ),
      );
    }

    return AlertDialog(
      // The title section, including an error icon for visual emphasis
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            // Use the Theme's error color for the icon
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          // Use a flexible widget for the title text to prevent overflow
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      // The content of the dialog (the detailed error message)
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(message),
          ],
        ),
      ),

      // The action buttons for the user to interact with the error
      actions: actions,
    );
  }
}
