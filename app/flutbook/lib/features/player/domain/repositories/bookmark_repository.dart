// lib/features/player/domain/repositories/bookmark_repository.dart
import 'package:flutbook/features/player/domain/entities/bookmark.dart';

abstract class BookmarkRepository {
  /// Creates a new bookmark for the specified audiobook
  Future<Bookmark> createBookmark({
    required String audiobookId,
    required Duration timestamp,
    String? note,
    String? chapterId,
  });

  /// Creates a new bookmark for a specific chapter
  Future<Bookmark> createBookmarkForChapter({
    required String audiobookId,
    required String chapterId,
    required Duration timestamp,
    String? note,
  });

  /// Gets all bookmarks for a specific audiobook
  Future<List<Bookmark>> getBookmarksForAudiobook(String audiobookId);

  /// Gets all bookmarks for a specific chapter
  Future<List<Bookmark>> getBookmarksForChapter(String chapterId);

  /// Gets all bookmarks for a specific audiobook and chapter
  Future<List<Bookmark>> getBookmarksForAudiobookChapter({
    required String audiobookId,
    required String chapterId,
  });

  /// Deletes a specific bookmark
  Future<bool> deleteBookmark(int bookmarkId);

  /// Deletes all bookmarks for a specific audiobook
  Future<bool> deleteAllBookmarksForAudiobook(String audiobookId);

  /// Deletes all bookmarks for a specific chapter
  Future<bool> deleteAllBookmarksForChapter(String chapterId);

  /// Deletes all bookmarks for a specific audiobook and chapter
  Future<bool> deleteAllBookmarksForAudiobookChapter({
    required String audiobookId,
    required String chapterId,
  });

  /// Updates an existing bookmark
  Future<Bookmark> updateBookmark({
    required int bookmarkId,
    String? note,
    Duration? timestamp,
    String? chapterId,
  });
}
