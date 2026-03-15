// lib/features/player/data/datasources/bookmark_local_ds.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/models/bookmark_model.dart';
import 'package:isar_community/isar.dart';

class BookmarkLocalDatasource {
  BookmarkLocalDatasource(this._isar) {
    validateInitialization();
  }
  final Isar _isar;

  void validateInitialization() {
    if (!_isar.isOpen) {
      throw UninitializedDatasourceException('Isar database is not open');
    }
  }

  /// Checks if the datasource is initialized and ready for use
  bool get isInitialized => _isar.isOpen;

  /// Creates a new bookmark
  Future<BookmarkModel> createBookmark(BookmarkModel bookmark) async {
    validateInitialization();

    return _isar.writeTxn(() async {
      // Set the ID to auto-increment (0 means let Isar assign it)
      bookmark.id = Isar.autoIncrement;
      await _isar.bookmarkModels.put(bookmark);
      return bookmark;
    });
  }

  /// Gets all bookmarks for a specific audiobook
  Future<List<BookmarkModel>> getBookmarksForAudiobook(
    String audiobookId,
  ) async {
    validateInitialization();
    return _isar.bookmarkModels
        .filter()
        .audiobookIdEqualTo(audiobookId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Deletes a specific bookmark
  Future<bool> deleteBookmark(int bookmarkId) async {
    validateInitialization();
    return _isar.writeTxn(() async {
      final result = await _isar.bookmarkModels.delete(bookmarkId);
      return result;
    });
  }

  /// Deletes all bookmarks for a specific audiobook
  Future<bool> deleteAllBookmarksForAudiobook(String audiobookId) async {
    validateInitialization();
    return _isar.writeTxn(() async {
      final count = await _isar.bookmarkModels
          .filter()
          .audiobookIdEqualTo(audiobookId)
          .deleteAll();
      return count > 0;
    });
  }

  /// Updates an existing bookmark
  Future<BookmarkModel> updateBookmark(BookmarkModel bookmark) async {
    validateInitialization();

    return _isar.writeTxn(() async {
      await _isar.bookmarkModels.put(bookmark);
      return bookmark;
    });
  }

  /// Gets all bookmarks for a specific chapter
  Future<List<BookmarkModel>> getBookmarksForChapter(String chapterId) async {
    validateInitialization();
    return _isar.bookmarkModels
        .filter()
        .chapterIdIsNotNull()
        .and()
        .chapterIdEqualTo(chapterId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Gets all bookmarks for a specific audiobook and chapter
  Future<List<BookmarkModel>> getBookmarksForAudiobookChapter({
    required String audiobookId,
    required String chapterId,
  }) async {
    validateInitialization();
    return _isar.bookmarkModels
        .filter()
        .audiobookIdEqualTo(audiobookId)
        .chapterIdEqualTo(chapterId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Deletes all bookmarks for a specific chapter
  Future<bool> deleteAllBookmarksForChapter(String chapterId) async {
    validateInitialization();
    return _isar.writeTxn(() async {
      final count = await _isar.bookmarkModels
          .filter()
          .chapterIdEqualTo(chapterId)
          .deleteAll();
      return count > 0;
    });
  }

  /// Deletes all bookmarks for a specific audiobook and chapter
  Future<bool> deleteAllBookmarksForAudiobookChapter({
    required String audiobookId,
    required String chapterId,
  }) async {
    validateInitialization();
    return _isar.writeTxn(() async {
      final count = await _isar.bookmarkModels
          .filter()
          .audiobookIdEqualTo(audiobookId)
          .chapterIdEqualTo(chapterId)
          .deleteAll();
      return count > 0;
    });
  }
}
