// lib/domain/repositories/audiobook_repository.dart
import '../entities/audiobook.dart';

abstract class AudiobookRepository {
  /// Retrieves all audiobooks in the user's library using Isar database
  /// Handles cases where files may have been moved/deleted since last scan
  Future<List<Audiobook>> getAllAudiobooks();

  /// Gets a specific audiobook by ID using Isar database
  Future<Audiobook?> getAudiobookById(String id);

  /// Scans a directory and saves audiobooks to Isar database with proper schema
  /// Handles large files (>10GB) with appropriate memory management
  /// Throws specific exceptions for corrupted files or insufficient storage
  Future<List<Audiobook>> scanDirectory(String directoryPath);

  /// Updates an audiobook record in Isar database with proper indexing
  Future<void> updateAudiobook(Audiobook audiobook);

  /// Deletes an audiobook record (does not delete file) from Isar database
  Future<void> deleteAudiobook(String id);

  /// Searches audiobooks by title, author, etc. using Isar indexed queries
  /// Returns appropriate results even with missing or corrupted metadata
  Future<List<Audiobook>> searchAudiobooks(String query);

  /// Filters audiobooks by status (in_progress, completed, etc.) using Isar indexed queries
  /// Handles filtering with incomplete or missing metadata
  Future<List<Audiobook>> filterAudiobooks(AudiobookFilter filter);
  
  /// Finds audiobooks by specific criteria using Isar compound indexes
  Future<List<Audiobook>> findAudiobooks({String? author, bool? completed, int? limit});
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