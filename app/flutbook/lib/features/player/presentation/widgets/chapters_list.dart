// lib/features/player/presentation/widgets/chapters_list.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/chapter.dart';
import 'package:flutbook/features/player/domain/entities/bookmark.dart';
import 'package:flutbook/features/player/presentation/providers/bookmark_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChaptersList extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Load bookmarks for this audiobook
    final bookmarkNotifier = ref.read(bookmarkProvider.notifier);
    bookmarkNotifier.loadBookmarks(audiobook.id);

    // Get current bookmark state
    final bookmarkState = ref.watch(bookmarkProvider);

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
      physics:
          const NeverScrollableScrollPhysics(), // Allow embedding in other scroll views
      itemCount: audiobook.chapters.length,
      itemBuilder: (context, index) {
        final chapter = audiobook.chapters[index];
        final isCurrentChapter = _isChapterCurrent(chapter, currentPosition);

        final chapterBookmarks = _getBookmarksForChapter(
          chapter.id,
          bookmarkState.bookmarks,
        );
        final hasBookmarks = chapterBookmarks.isNotEmpty;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(
              chapter.title,
              style: TextStyle(
                fontWeight: isCurrentChapter
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isCurrentChapter
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatDuration(chapter.startTime)} - ${_formatDuration(chapter.endTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCurrentChapter
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                if (hasBookmarks) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${chapterBookmarks.length} bookmark${chapterBookmarks.length > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            leading: Stack(
              children: [
                CircleAvatar(
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
                if (hasBookmarks)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${chapterBookmarks.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrentChapter)
                  Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                if (isCurrentChapter && hasBookmarks) const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    hasBookmarks ? Icons.bookmark : Icons.bookmark_border,
                    color: hasBookmarks
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey,
                  ),
                  onPressed: () => _showBookmarkManagementDialog(
                    context,
                    ref,
                    chapter,
                    chapterBookmarks,
                    audiobook.id,
                  ),
                ),
              ],
            ),
            onTap: () => onChapterTap(chapter),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isCurrentChapter
                    ? Theme.of(context).colorScheme.primary
                    : hasBookmarks
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
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
    return currentPosition >= chapter.startTime &&
        currentPosition < chapter.endTime;
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

  List<Bookmark> _getBookmarksForChapter(
    String chapterId,
    List<Bookmark> allBookmarks,
  ) {
    return allBookmarks
        .where((bookmark) => bookmark.chapterId == chapterId)
        .toList();
  }

  void _showBookmarkManagementDialog(
    BuildContext context,
    WidgetRef ref,
    Chapter chapter,
    List<Bookmark> chapterBookmarks,
    String audiobookId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Bookmarks for ${chapter.title}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (chapterBookmarks.isEmpty)
                  const Text('No bookmarks for this chapter yet.')
                else
                  ...chapterBookmarks.map(
                    (bookmark) => ListTile(
                      title: Text(_formatDuration(bookmark.timestamp)),
                      subtitle: bookmark.note != null
                          ? Text(bookmark.note!)
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          ref
                              .read(bookmarkProvider.notifier)
                              .deleteBookmark(bookmark.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add new bookmark'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAddBookmarkDialog(
                      context,
                      ref,
                      chapter,
                      audiobookId,
                    );
                  },
                ),
                if (chapterBookmarks.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete_sweep),
                    title: const Text('Delete all bookmarks'),
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () {
                      ref
                          .read(bookmarkProvider.notifier)
                          .deleteAllBookmarksForChapter(chapter.id);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddBookmarkDialog(
    BuildContext context,
    WidgetRef ref,
    Chapter chapter,
    String audiobookId,
  ) {
    final timestampController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Bookmark'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timestampController,
                decoration: const InputDecoration(
                  labelText: 'Timestamp (HH:MM:SS)',
                  hintText: 'e.g., 00:15:30',
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Add a note about this bookmark',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final timestampText = timestampController.text.trim();
                final note = noteController.text.trim();

                if (timestampText.isNotEmpty) {
                  try {
                    final parts = timestampText.split(':');
                    final hours = int.parse(parts[0]);
                    final minutes = int.parse(parts[1]);
                    final seconds = parts.length > 2 ? int.parse(parts[2]) : 0;

                    final timestamp = Duration(
                      hours: hours,
                      minutes: minutes,
                      seconds: seconds,
                    );

                    ref
                        .read(bookmarkProvider.notifier)
                        .createBookmarkForChapter(
                          audiobookId: audiobookId,
                          chapterId: chapter.id,
                          timestamp: timestamp,
                          note: note.isNotEmpty ? note : null,
                        );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid timestamp format. Use HH:MM:SS'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
