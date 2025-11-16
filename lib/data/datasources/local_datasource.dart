// lib/data/datasources/local_datasource.dart
import '../../domain/entities/audiobook.dart';
import '../../domain/entities/playback_session.dart';

abstract class LocalDataSource {
  /// Saves audiobook metadata to Isar database with proper schema and indexing
  /// Handles large files (>10GB) with appropriate memory management
  /// Throws specific exceptions for corrupted files or insufficient storage
  Future<void> saveAudiobooks(List<Audiobook> audiobooks);

  /// Gets audiobooks from Isar database using indexed queries for performance
  /// Handles cases where files may have been moved/deleted since last scan
  Future<List<Audiobook>> getAudiobooks();

  /// Gets a single audiobook from Isar database by ID
  Future<Audiobook?> getAudiobookById(String id);

  /// Saves playback session to Isar database with proper indexing
  Future<void> savePlaybackSession(PlaybackSession session);

  /// Gets playback session from Isar database
  Future<PlaybackSession?> getPlaybackSession(String audiobookId);

  /// Searches audiobooks using Isar's full-text search capabilities
  /// Returns appropriate results even with missing or corrupted metadata
  Future<List<Audiobook>> searchAudiobooks(String query);

  /// Filters audiobooks using Isar's indexed fields for efficient queries
  /// Handles filtering with incomplete or missing metadata
  Future<List<Audiobook>> filterAudiobooks(AudiobookFilter filter);

  /// Gets all settings from JSON storage
  Future<Map<String, dynamic>> getSettings();

  /// Saves settings to JSON storage
  Future<void> saveSettings(Map<String, dynamic> settings);

  /// Initializes Isar database with proper schema including all indexes
  /// Sets up proper error handling for database access issues
  Future<void> initializeDatabase();

  /// Performs database migrations if needed
  /// Handles migration failures gracefully
  Future<void> migrateDatabase();

  /// Clears Isar database (for testing or user request)
  Future<void> clearDatabase();

  /// Performs cleanup and closes Isar database connection
  Future<void> closeDatabase();

  /// Checks if audio file still exists and is accessible
  /// Used to handle cases where files are moved/deleted after scanning
  Future<bool> isFileAccessible(String filePath);
}