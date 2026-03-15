// lib/domain/repositories/library_repository.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/library.dart';

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

  /// Gets audiobooks with optional sorting and filtering
  Future<List<Audiobook>> getAudiobooks({
    String? sortBy,
    bool sortAscending = true,
    bool? completed,
    bool? inProgress,
    String? title,
    String? author,
    int? limit,
  });

  /// Filters audiobooks in the library
  Future<List<Audiobook>> filterInLibrary(AudiobookFilter filter);

  /// Checks if library path is accessible
  Future<bool> isLibraryPathAccessible();

  /// Updates the preferred playback speed for an audiobook
  Future<void> updatePreferredSpeed(String audiobookId, double speed);

  /// Gets the preferred playback speed for an audiobook
  Future<double> getPreferredSpeed(String audiobookId);
}

class LibraryStats {
  const LibraryStats({
    required this.totalBooks,
    required this.inProgress,
    required this.completed,
    required this.notStarted,
    required this.totalDuration,
  });
  final int totalBooks;
  final int inProgress;
  final int completed;
  final int notStarted;
  final Duration totalDuration;
}

class AudiobookFilter {
  const AudiobookFilter({
    this.title,
    this.author,
    this.completed,
    this.inProgress,
    this.sortBy,
    this.sortAscending = true,
    this.limit,
  });
  final String? title;
  final String? author;
  final bool? completed;
  final bool? inProgress;
  final String? sortBy; // 'title', 'author', 'lastPlayed', 'dateAdded'
  final bool sortAscending;
  final int? limit;
}
