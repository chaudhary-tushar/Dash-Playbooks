// lib/features/player/presentation/widgets/sleep_timer_dialog.dart
import 'package:flutter/material.dart';

class SleepTimerDialog extends StatelessWidget {
  const SleepTimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Sleep Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Choose when to stop playback:'),
          const SizedBox(height: 16),
          _buildTimerOption(context, '5 minutes', const Duration(minutes: 5)),
          _buildTimerOption(context, '10 minutes', const Duration(minutes: 10)),
          _buildTimerOption(context, '15 minutes', const Duration(minutes: 15)),
          _buildTimerOption(context, '30 minutes', const Duration(minutes: 30)),
          _buildTimerOption(
            context,
            'End of chapter',
            null,
            isEndOfChapter: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildTimerOption(
    BuildContext context,
    String label,
    Duration? duration, {
    bool isEndOfChapter = false,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(
        SleepTimerSelection(
          duration: duration,
          endOfChapter: isEndOfChapter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isEndOfChapter ? Icons.segment_rounded : Icons.timer_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class SleepTimerSelection {
  const SleepTimerSelection({
    this.duration,
    this.endOfChapter = false,
  });
  final Duration? duration;
  final bool endOfChapter;
}
