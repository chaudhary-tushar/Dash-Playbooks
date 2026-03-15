// lib/features/player/presentation/widgets/bookmark_widget.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/library/domain/entities/chapter.dart';
import 'package:flutbook/features/player/domain/entities/bookmark.dart';
import 'package:flutbook/features/player/presentation/providers/bookmark_provider.dart';
import 'package:flutbook/features/player/presentation/providers/playback_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkWidget extends ConsumerWidget {
  const BookmarkWidget({
    required this.audiobookId,
    required this.currentPosition,
    this.chapters = const [],
    super.key,
  });

  final String audiobookId;
  final Duration currentPosition;
  final List<Chapter> chapters;

  // Group bookmarks by chapter
  Map<String?, List<Bookmark>> _groupBookmarksByChapter(
    List<Bookmark> bookmarks,
  ) {
    final Map<String?, List<Bookmark>> groups = {};

    for (final bookmark in bookmarks) {
      final chapterId = bookmark.chapterId;
      if (!groups.containsKey(chapterId)) {
        groups[chapterId] = [];
      }
      groups[chapterId]!.add(bookmark);
    }

    return groups;
  }

  // Get chapter info by ID
  Chapter? _getChapterInfo(String? chapterId) {
    if (chapterId == null) return null;
    try {
      return chapters.firstWhere((chapter) => chapter.id == chapterId);
    } catch (e) {
      return null; // Chapter not found
    }
  }

  // Count bookmarks that have chapter information
  int _getChapterBookmarkCount(Map<String?, List<Bookmark>> chapterGroups) {
    return chapterGroups.entries
        .where((entry) => entry.key != null)
        .fold(0, (sum, entry) => sum + entry.value.length);
  }

  // Navigate to a bookmark position with error handling
  Future<void> _navigateToBookmark(
    BuildContext context,
    WidgetRef ref,
    Bookmark bookmark,
    Chapter? chapterInfo,
  ) async {
    try {
      final playbackNotifier = ref.read(playbackProvider.notifier);

      // Seek to the bookmark position
      await playbackNotifier.seekTo(bookmark.timestamp);

      // Show success message
      final chapterName = chapterInfo != null ? ' (${chapterInfo.title})' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumping to ${_formatDuration(bookmark.timestamp)}$chapterName',
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to navigate to bookmark: ${ErrorHandler.handlePlaybackException(e)}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Navigate to chapter start
  Future<void> _navigateToChapterStart(
    BuildContext context,
    WidgetRef ref,
    Chapter chapter,
  ) async {
    try {
      final playbackNotifier = ref.read(playbackProvider.notifier);

      // Seek to the start of the chapter (position 0)
      await playbackNotifier.seekTo(Duration.zero);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumping to start of ${chapter.title}',
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to navigate to chapter start: ${ErrorHandler.handlePlaybackException(e)}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Show chapter filter dialog
  void _showChapterFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Chapter'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (chapters.isEmpty)
                  const Text('No chapters available')
                else
                  ...chapters.map((chapter) {
                    final chapterBookmarks = ref
                        .read(bookmarkProvider.notifier)
                        .getBookmarksByChapter(chapter.id);

                    return ListTile(
                      title: Text(chapter.title),
                      subtitle: Text('${chapterBookmarks.length} bookmarks'),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        // Filter bookmarks by this chapter
                        ref
                            .read(bookmarkProvider.notifier)
                            .loadBookmarksForChapter(chapter.id);
                      },
                    );
                  }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reload all bookmarks
                ref.read(bookmarkProvider.notifier).loadBookmarks(audiobookId);
              },
              child: const Text('Show All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkState = ref.watch(bookmarkProvider);
    final bookmarkNotifier = ref.read(bookmarkProvider.notifier);

    // Group bookmarks by chapter
    final chapterGroups = _groupBookmarksByChapter(bookmarkState.bookmarks);
    final totalBookmarks = bookmarkState.bookmarks.length;

    return Column(
      children: [
        // Bookmark list header with chapter filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bookmarks ($totalBookmarks)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      if (chapters.isNotEmpty) ...[
                        IconButton(
                          icon: const Icon(Icons.filter_list, size: 24),
                          onPressed: () =>
                              _showChapterFilterDialog(context, ref),
                          tooltip: 'Filter by chapter',
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        icon: const Icon(Icons.add, size: 24),
                        onPressed: () async {
                          await bookmarkNotifier.createBookmark(
                            audiobookId: audiobookId,
                            timestamp: currentPosition,
                            note:
                                'Bookmarked at ${_formatDuration(currentPosition)}',
                          );
                        },
                        tooltip: 'Add bookmark at current position',
                      ),
                    ],
                  ),
                ],
              ),
              if (chapters.isNotEmpty && chapterGroups.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Text(
                        '${chapterGroups.length} chapter${chapterGroups.length > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_getChapterBookmarkCount(chapterGroups)} bookmarks with chapters',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Bookmark list
        if (bookmarkState.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          )
        else if (bookmarkState.bookmarks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No bookmarks yet. Add one using the + button above.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chapterGroups.length,
            itemBuilder: (context, groupIndex) {
              final chapterId = chapterGroups.keys.elementAt(groupIndex);
              final chapterBookmarks = chapterGroups[chapterId]!;
              final chapterInfo = _getChapterInfo(chapterId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter header
                  if (chapterId != null && chapterInfo != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  chapterInfo.title,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${chapterBookmarks.length}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          // Chapter navigation buttons
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ), // Align with chapter indicator
                              Expanded(
                                child: Row(
                                  children: [
                                    // Jump to chapter start button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.skip_previous,
                                        size: 18,
                                      ),
                                      onPressed: () => _navigateToChapterStart(
                                        context,
                                        ref,
                                        chapterInfo,
                                      ),
                                      tooltip: 'Jump to start of chapter',
                                      style: IconButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Chapter navigation',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Bookmarks in this chapter
                  ...chapterBookmarks.map(
                    (bookmark) => _BookmarkItem(
                      bookmark: bookmark,
                      chapterInfo: chapterInfo,
                      onTap: () => _navigateToBookmark(
                        context,
                        ref,
                        bookmark,
                        chapterInfo,
                      ),
                      onDelete: () async {
                        await bookmarkNotifier.deleteBookmark(bookmark.id);
                      },
                    ),
                  ),

                  if (groupIndex < chapterGroups.length - 1)
                    const Divider(indent: 20, endIndent: 20),
                ],
              );
            },
          ),

        // Error message if any
        if (bookmarkState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              bookmarkState.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    final twoDigitHours = twoDigits(duration.inHours);

    return duration.inHours > 0
        ? '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds'
        : '$twoDigitMinutes:$twoDigitSeconds';
  }
}

class _BookmarkItem extends StatelessWidget {
  const _BookmarkItem({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
    this.chapterInfo,
  });

  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Chapter? chapterInfo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          const Icon(Icons.bookmark_outline, size: 24),
          if (chapterInfo != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.layers,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Text(_formatDuration(bookmark.timestamp)),
          if (chapterInfo != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Chapter',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bookmark.note != null && bookmark.note!.isNotEmpty)
            Text(
              bookmark.note!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (chapterInfo != null)
            Text(
              chapterInfo!.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: onDelete,
        tooltip: 'Delete bookmark',
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    final twoDigitHours = twoDigits(duration.inHours);

    return duration.inHours > 0
        ? '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds'
        : '$twoDigitMinutes:$twoDigitSeconds';
  }
}
