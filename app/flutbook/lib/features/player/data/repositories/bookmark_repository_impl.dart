// lib/features/player/data/repositories/bookmark_repository_impl.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/datasources/bookmark_local_ds.dart';
import 'package:flutbook/features/player/data/models/bookmark_model.dart';
import 'package:flutbook/features/player/domain/entities/bookmark.dart';
import 'package:flutbook/features/player/domain/repositories/bookmark_repository.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  BookmarkRepositoryImpl({required BookmarkLocalDatasource localDatasource})
    : _localDatasource = localDatasource {
    validateDependencies();
  }

  final BookmarkLocalDatasource _localDatasource;
  bool _isInitialized = false;

  /// Initialize the repository and validate dependencies
  void validateDependencies() {
    if (!_localDatasource.isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Local datasource not initialized',
      );
    }
    _isInitialized = true;
  }

  /// Checks if the repository is ready for use
  bool get isInitialized => _isInitialized;

  @override
  Future<Bookmark> createBookmark({
    required String audiobookId,
    required Duration timestamp,
    String? note,
    String? chapterId,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate audiobookId
    if (audiobookId.isEmpty) {
      throw ArgumentError('audiobookId cannot be an empty string');
    }

    // Validate chapterId if provided
    if (chapterId != null && chapterId.isEmpty) {
      throw ArgumentError('chapterId cannot be an empty string');
    }

    try {
      final bookmarkModel = BookmarkModel()
        ..audiobookId = audiobookId
        ..timestamp = timestamp.inMilliseconds
        ..createdAt = DateTime.now()
        ..note = note
        ..chapterId = chapterId;

      final createdModel = await _localDatasource.createBookmark(bookmarkModel);
      return createdModel.toDomain();
    } catch (e) {
      throw Exception('Failed to create bookmark: $e');
    }
  }

  @override
  Future<Bookmark> createBookmarkForChapter({
    required String audiobookId,
    required String chapterId,
    required Duration timestamp,
    String? note,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate chapterId
    if (chapterId.isEmpty) {
      throw ArgumentError('chapterId cannot be an empty string');
    }

    try {
      final bookmarkModel = BookmarkModel()
        ..audiobookId = audiobookId
        ..chapterId = chapterId
        ..timestamp = timestamp.inMilliseconds
        ..createdAt = DateTime.now()
        ..note = note;

      final createdModel = await _localDatasource.createBookmark(bookmarkModel);
      return createdModel.toDomain();
    } catch (e) {
      throw Exception('Failed to create chapter bookmark: $e');
    }
  }

  @override
  Future<List<Bookmark>> getBookmarksForAudiobook(String audiobookId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate audiobookId
    if (audiobookId.isEmpty) {
      throw ArgumentError('audiobookId cannot be an empty string');
    }

    try {
      final bookmarkModels = await _localDatasource.getBookmarksForAudiobook(
        audiobookId,
      );
      return bookmarkModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get bookmarks: $e');
    }
  }

  @override
  Future<List<Bookmark>> getBookmarksForChapter(String chapterId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate chapterId
    if (chapterId.isEmpty) {
      throw ArgumentError('chapterId cannot be an empty string');
    }

    try {
      final bookmarkModels = await _localDatasource.getBookmarksForChapter(
        chapterId,
      );
      return bookmarkModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get chapter bookmarks: $e');
    }
  }

  @override
  Future<List<Bookmark>> getBookmarksForAudiobookChapter({
    required String audiobookId,
    required String chapterId,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate chapterId
    if (chapterId.isEmpty) {
      throw ArgumentError('chapterId cannot be an empty string');
    }

    try {
      final bookmarkModels = await _localDatasource
          .getBookmarksForAudiobookChapter(
            audiobookId: audiobookId,
            chapterId: chapterId,
          );
      return bookmarkModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get audiobook chapter bookmarks: $e');
    }
  }

  @override
  Future<bool> deleteBookmark(int bookmarkId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      return await _localDatasource.deleteBookmark(bookmarkId);
    } catch (e) {
      throw Exception('Failed to delete bookmark: $e');
    }
  }

  @override
  Future<bool> deleteAllBookmarksForAudiobook(String audiobookId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate audiobookId
    if (audiobookId.isEmpty) {
      throw ArgumentError('audiobookId cannot be an empty string');
    }

    try {
      return await _localDatasource.deleteAllBookmarksForAudiobook(audiobookId);
    } catch (e) {
      throw Exception('Failed to delete all bookmarks: $e');
    }
  }

  @override
  Future<bool> deleteAllBookmarksForChapter(String chapterId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate chapterId
    if (chapterId.isEmpty) {
      throw ArgumentError('chapterId cannot be an empty string');
    }

    try {
      return await _localDatasource.deleteAllBookmarksForChapter(chapterId);
    } catch (e) {
      throw Exception('Failed to delete all chapter bookmarks: $e');
    }
  }

  @override
  Future<bool> deleteAllBookmarksForAudiobookChapter({
    required String audiobookId,
    required String chapterId,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate chapterId
    if (chapterId.isEmpty) {
      throw ArgumentError('chapterId cannot be an empty string');
    }

    try {
      return await _localDatasource.deleteAllBookmarksForAudiobookChapter(
        audiobookId: audiobookId,
        chapterId: chapterId,
      );
    } catch (e) {
      throw Exception('Failed to delete all audiobook chapter bookmarks: $e');
    }
  }

  @override
  Future<Bookmark> updateBookmark({
    required int bookmarkId,
    String? note,
    Duration? timestamp,
    String? chapterId,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'BookmarkRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      // First, get the existing bookmark
      final existingBookmarks = await _localDatasource.getBookmarksForAudiobook(
        '',
      );
      final existingBookmark = existingBookmarks.firstWhere(
        (bookmark) => bookmark.id == bookmarkId,
        orElse: () => throw Exception('Bookmark not found'),
      );

      // Update the fields
      if (note != null) {
        existingBookmark.note = note;
      }
      if (timestamp != null) {
        existingBookmark.timestamp = timestamp.inMilliseconds;
      }
      if (chapterId != null) {
        // Validate chapterId
        if (chapterId.isEmpty) {
          throw ArgumentError('chapterId cannot be an empty string');
        }
        existingBookmark.chapterId = chapterId;
      }

      final updatedModel = await _localDatasource.updateBookmark(
        existingBookmark,
      );
      return updatedModel.toDomain();
    } catch (e) {
      throw Exception('Failed to update bookmark: $e');
    }
  }
}
