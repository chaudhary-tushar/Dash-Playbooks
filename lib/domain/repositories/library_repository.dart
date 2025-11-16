// lib/domain/repositories/library_repository.dart
import '../entities/library.dart';
import '../entities/audiobook.dart';

abstract class LibraryRepository {
  /// Gets the user's library
  Future<Library> getLibrary();

  /// Scans a directory and updates the library
  Future<Library> scanDirectory(String directoryPath);

  /// Updates library information
  Future<Library> updateLibrary(Library library);

  /// Deletes an audiobook from the library
  Future<void> deleteAudiobookFromLibrary(String audiobookId);

  /// Gets the library path
  Future<String?> getLibraryPath();

  /// Sets the library path
  Future<void> setLibraryPath(String path);

  /// Gets statistics about the library
  Future<LibraryStats> getLibraryStats();

  /// Searches for audiobooks in the library
  Future<List<Audiobook>> searchInLibrary(String query);

  /// Filters audiobooks in the library
  Future<List<Audiobook>> filterInLibrary(AudiobookFilter filter);

  /// Checks if library path is accessible
  Future<bool> isLibraryPathAccessible();
}

class LibraryStats {
  final int totalBooks;
  final int inProgress;
  final int completed;
  final int notStarted;
  final Duration totalDuration;

  const LibraryStats({
    required this.totalBooks,
    required this.inProgress,
    required this.completed,
    required this.notStarted,
    required this.totalDuration,
  });
}

class AudiobookFilter {
  final String? title;
  final String? author;
  final bool? completed;
  final bool? inProgress;
  final String? sortBy; // 'title', 'author', 'lastPlayed', 'dateAdded'
  final bool sortAscending;
  final int? limit;

  const AudiobookFilter({
    this.title,
    this.author,
    this.completed,
    this.inProgress,
    this.sortBy,
    this.sortAscending = true,
    this.limit,
  });
}