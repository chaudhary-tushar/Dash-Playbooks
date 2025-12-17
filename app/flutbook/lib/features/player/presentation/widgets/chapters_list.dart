// lib/features/player/presentation/widgets/chapters_list.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/chapter.dart';
import 'package:flutter/material.dart';

class ChaptersList extends StatelessWidget {
  const ChaptersList({
    required this.audiobook,
    required this.onChapterTap,
    required this.currentPosition,
    super.key,
  });
  
  final Audiobook audiobook;
  final void Function(Chapter) onChapterTap;
  final Duration currentPosition;

  @override
  Widget build(BuildContext context) {
    if (audiobook.chapters.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No chapters available for this audiobook',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Allow embedding in other scroll views
      itemCount: audiobook.chapters.length,
      itemBuilder: (context, index) {
        final chapter = audiobook.chapters[index];
        final isCurrentChapter = _isChapterCurrent(chapter, currentPosition);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(
              chapter.title,
              style: TextStyle(
                fontWeight: isCurrentChapter ? FontWeight.bold : FontWeight.normal,
                color: isCurrentChapter 
                    ? Theme.of(context).colorScheme.primary 
                    : null,
              ),
            ),
            subtitle: Text(
              '${_formatDuration(chapter.startTime)} - ${_formatDuration(chapter.endTime)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isCurrentChapter 
                    ? Theme.of(context).colorScheme.primary 
                    : null,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: isCurrentChapter 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey[300],
              foregroundColor: isCurrentChapter 
                  ? Colors.white 
                  : Colors.black,
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            trailing: isCurrentChapter
                ? Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => onChapterTap(chapter),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isCurrentChapter 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isChapterCurrent(Chapter chapter, Duration currentPosition) {
    return currentPosition >= chapter.startTime && currentPosition < chapter.endTime;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitHours = twoDigits(duration.inHours);
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds'
        : '$twoDigitMinutes:$twoDigitSeconds';
  }
}