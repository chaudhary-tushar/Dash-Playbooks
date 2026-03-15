// lib/features/player/presentation/providers/bookmark_provider.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/core/provider/providers.dart'
    show bookmarkRepositoryProvider, createBookmarkUsecaseProvider, getBookmarksUsecaseProvider;
import 'package:flutbook/features/player/domain/entities/bookmark.dart';
import 'package:flutbook/features/player/domain/repositories/bookmark_repository.dart';
import 'package:flutbook/features/player/domain/usecases/create_bookmark_usecase.dart';
import 'package:flutbook/features/player/domain/usecases/get_bookmarks_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class representing the current bookmark state.
class BookmarkState {
  const BookmarkState({
    required this.bookmarks,
    required this.isLoading,
    this.errorMessage,
  });

  /// Creates an initial bookmark state with default values.
  factory BookmarkState.initial() {
    return const BookmarkState(
      bookmarks: [],
      isLoading: false,
    );
  }

  final List<Bookmark> bookmarks;
  final bool isLoading;
  final String? errorMessage;

  BookmarkState copyWith({
    List<Bookmark>? bookmarks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Main bookmark provider that manages the state and logic for bookmark operations.
final bookmarkProvider = NotifierProvider<BookmarkNotifier, BookmarkState>(
  BookmarkNotifier.new,
);

/// Notifier class that manages the bookmark state and business logic.
class BookmarkNotifier extends Notifier<BookmarkState> {
  // Dependencies
  late CreateBookmarkUsecase _createBookmarkUsecase;
  late GetBookmarksUsecase _getBookmarksUsecase;
  late BookmarkRepository _bookmarkRepository;

  @override
  BookmarkState build() {
    try {
      // Initialize use cases directly from providers
      _createBookmarkUsecase = ref.read(createBookmarkUsecaseProvider);
      _getBookmarksUsecase = ref.read(getBookmarksUsecaseProvider);
      final bookmarkRepoAsync = ref.read(bookmarkRepositoryProvider);
      _bookmarkRepository =
          bookmarkRepoAsync.value ??
          (throw UninitializedDatasourceException(
            'Bookmark repository not initialized',
          ));

      return BookmarkState.initial();
    } catch (e) {
      // Handle initialization errors - avoid using state.copyWith() here
      // because state is not yet available during build
      return BookmarkState(
        bookmarks: [],
        isLoading: false,
        errorMessage: ErrorHandler.handlePlaybackException(e),
      );
    }
  }

  /// Load bookmarks for the specified audiobook
  Future<void> loadBookmarks(String audiobookId) async {
    state = state.copyWith(isLoading: true);

    try {
      final bookmarks = await _getBookmarksUsecase(audiobookId);
      state = state.copyWith(
        bookmarks: bookmarks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load bookmarks: $e',
      );
    }
  }

  /// Create a new bookmark
  Future<void> createBookmark({
    required String audiobookId,
    required Duration timestamp,
    String? note,
    String? chapterId,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final bookmark = await _createBookmarkUsecase(
        audiobookId: audiobookId,
        timestamp: timestamp,
        note: note,
        chapterId: chapterId,
      );

      // Add the new bookmark to the list
      final updatedBookmarks = [...state.bookmarks, bookmark];
      state = state.copyWith(
        bookmarks: updatedBookmarks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create bookmark: $e',
      );
    }
  }

  /// Create a new bookmark for a specific chapter
  Future<void> createBookmarkForChapter({
    required String audiobookId,
    required String chapterId,
    required Duration timestamp,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final bookmark = await _bookmarkRepository.createBookmarkForChapter(
        audiobookId: audiobookId,
        chapterId: chapterId,
        timestamp: timestamp,
        note: note,
      );

      // Add the new bookmark to the list
      final updatedBookmarks = [...state.bookmarks, bookmark];
      state = state.copyWith(
        bookmarks: updatedBookmarks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create chapter bookmark: $e',
      );
    }
  }

  /// Load bookmarks for a specific chapter
  Future<void> loadBookmarksForChapter(String chapterId) async {
    state = state.copyWith(isLoading: true);

    try {
      final bookmarks = await _bookmarkRepository.getBookmarksForChapter(
        chapterId,
      );
      state = state.copyWith(
        bookmarks: bookmarks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load chapter bookmarks: $e',
      );
    }
  }

  /// Load bookmarks for a specific audiobook and chapter
  Future<void> loadBookmarksForAudiobookChapter({
    required String audiobookId,
    required String chapterId,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final bookmarks = await _bookmarkRepository.getBookmarksForAudiobookChapter(
        audiobookId: audiobookId,
        chapterId: chapterId,
      );
      state = state.copyWith(
        bookmarks: bookmarks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load audiobook chapter bookmarks: $e',
      );
    }
  }

  /// Filter bookmarks by chapter
  List<Bookmark> getBookmarksByChapter(String chapterId) {
    return state.bookmarks.where((bookmark) => bookmark.chapterId == chapterId).toList();
  }

  /// Delete a bookmark
  Future<void> deleteBookmark(int bookmarkId) async {
    // This would need to be implemented in the repository and use case
    // For now, we'll just remove it from the local state
    final updatedBookmarks = state.bookmarks
        .where((bookmark) => bookmark.id != bookmarkId)
        .toList();

    state = state.copyWith(bookmarks: updatedBookmarks);
  }

  /// Clear all bookmarks for the current audiobook
  void clearBookmarks() {
    state = state.copyWith(bookmarks: []);
  }

  /// Delete all bookmarks for a specific chapter
  Future<void> deleteAllBookmarksForChapter(String chapterId) async {
    try {
      await _bookmarkRepository.deleteAllBookmarksForChapter(chapterId);

      // Remove chapter bookmarks from local state
      final updatedBookmarks = state.bookmarks
          .where((bookmark) => bookmark.chapterId != chapterId)
          .toList();

      state = state.copyWith(bookmarks: updatedBookmarks);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete chapter bookmarks: $e',
      );
    }
  }

  /// Delete all bookmarks for a specific audiobook and chapter
  Future<void> deleteAllBookmarksForAudiobookChapter({
    required String audiobookId,
    required String chapterId,
  }) async {
    try {
      await _bookmarkRepository.deleteAllBookmarksForAudiobookChapter(
        audiobookId: audiobookId,
        chapterId: chapterId,
      );

      // Remove audiobook+chapter bookmarks from local state
      final updatedBookmarks = state.bookmarks
          .where(
            (bookmark) => bookmark.audiobookId != audiobookId || bookmark.chapterId != chapterId,
          )
          .toList();

      state = state.copyWith(bookmarks: updatedBookmarks);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete audiobook chapter bookmarks: $e',
      );
    }
  }
}
