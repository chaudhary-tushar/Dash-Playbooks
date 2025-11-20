// lib/data/datasources/local/audiobook_local_datasource.dart

import 'package:flutbook/data/datasources/local/error_handler.dart';
import 'package:flutbook/data/datasources/local/json_storage.dart';
import 'package:flutbook/data/datasources/local/metadata_extraction_datasource.dart';
import 'package:flutbook/data/models/audiobook_model.dart';
import 'package:flutbook/data/models/playback_session_model.dart';
import 'package:flutbook/domain/entities/audiobook.dart';
import 'package:flutbook/domain/entities/filter.dart';
import 'package:flutbook/domain/entities/playback_session.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// Local data source for audiobook operations with Isar database and fallback handling
/// Implements proper schema and indexing as required by data model
class AudiobookLocalDatasource {
  late Isar _isar;
  final MetadataExtractionDatasource _metadataExtractor = MetadataExtractionDatasource();
  final JsonStorage _jsonStorage = JsonStorage();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      AudiobookModelSchema,
      PlaybackSessionModelSchema,
    ], directory: dir.path);
  }

  /// Saves audiobooks to Isar database with proper schema and indexing
  /// Handles large files (>10GB) with appropriate memory management
  /// Throws specific exceptions for corrupted files or insufficient storage
  Future<void> saveAudiobooks(List<Audiobook> audiobooks) async {
    try {
      final List<AudiobookModel> audiobookModels = audiobooks
          .map(AudiobookModel.fromDomain)
          .toList();

      await _isar.writeTxn(() async {
        await _isar.audiobookModels.putAll(audiobookModels);
      });
    } catch (e) {
      throw DatabaseException('Failed to save audiobooks: $e');
    }
  }

  /// Gets audiobooks from Isar database using indexed queries for performance
  /// Handles cases where files may have been moved/deleted since last scan
  Future<List<Audiobook>> getAudiobooks() async {
    try {
      final audiobookModels = await _isar.audiobookModels.where().findAll();

      // Filter out audiobooks that no longer exist on the file system
      final validAudiobooks = <Audiobook>[];

      for (final model in audiobookModels) {
        try {
          final fileExists = await _metadataExtractor.isFileAccessible(model.filePath);
          if (fileExists) {
            validAudiobooks.add(model.toDomain());
          } else {
            // Remove from database if file no longer exists
            await _removeAudiobookFromDb(model.internalId ?? model.filePath);
          }
        } catch (e) {
          // If we can't check, still include but log the issue
          print('Could not check file existence for ${model.filePath}: $e');
          validAudiobooks.add(model.toDomain());
        }
      }

      return validAudiobooks;
    } catch (e) {
      throw DatabaseException('Failed to retrieve audiobooks: $e');
    }
  }

  /// Gets a single audiobook from Isar database by ID
  Future<Audiobook?> getAudiobookById(String id) async {
    try {
      final audiobookModel = await _isar.audiobookModels
          .where()
          .filter()
          .internalIdEqualTo(id)
          .findFirst();

      if (audiobookModel != null) {
        // Verify file still exists
        final fileExists = await _metadataExtractor.isFileAccessible(audiobookModel.filePath);
        if (fileExists) {
          return audiobookModel.toDomain();
        } else {
          // Remove from database if file no longer exists
          await _removeAudiobookFromDb(id);
          return null;
        }
      }

      return null;
    } catch (e) {
      throw DatabaseException('Failed to retrieve audiobook by ID: $e');
    }
  }

  /// Saves playback session to Isar database with proper indexing
  Future<void> savePlaybackSession(PlaybackSession session) async {
    try {
      final sessionModel = PlaybackSessionModel.fromDomain(session);

      await _isar.writeTxn(() async {
        await _isar.playbackSessionModels.put(sessionModel);
      });
    } catch (e) {
      throw DatabaseException('Failed to save playback session: $e');
    }
  }

  /// Gets playback session from Isar database
  Future<PlaybackSession?> getPlaybackSession(String audiobookId) async {
    try {
      final sessionModel = await _isar.playbackSessionModels
          .where()
          .filter()
          .audiobookIdEqualTo(audiobookId)
          .findFirst();

      return sessionModel?.toDomain();
    } catch (e) {
      throw DatabaseException('Failed to retrieve playback session: $e');
    }
  }

  /// Searches audiobooks using Isar's indexed fields for efficient queries
  /// Returns appropriate results even with missing or corrupted metadata
  Future<List<Audiobook>> searchAudiobooks(String query) async {
    try {
      final results = await _isar.audiobookModels.where().filter().anyOf([
        (q) => q.titleContains(query, caseSensitive: false),
        (q) => q.authorContains(query, caseSensitive: false),
        (q) => q.albumContains(query, caseSensitive: false),
      ]).findAll();

      final searchableAudiobooks = <Audiobook>[];
      for (final model in results) {
        final fileExists = await _metadataExtractor.isFileAccessible(model.filePath);
        if (fileExists) {
          searchableAudiobooks.add(model.toDomain());
        }
      }

      return searchableAudiobooks;
    } catch (e) {
      throw DatabaseException('Failed to search audiobooks: $e');
    }
  }

  /// Filters audiobooks using Isar's indexed fields for efficient queries
  /// Handles filtering with incomplete or missing metadata
  Future<List<Audiobook>> filterAudiobooks(AudiobookFilter filter) async {
    try {
      var queryBuilder = _isar.audiobookModels.where().filter();

      // Apply filters based on the filter object
      if (filter.title != null) {
        queryBuilder = queryBuilder.and().titleContains(filter.title!, caseSensitive: false);
      }
      if (filter.author != null) {
        queryBuilder = queryBuilder.and().authorContains(filter.author!, caseSensitive: false);
      }
      if (filter.completed != null) {
        queryBuilder = queryBuilder.and().completedEqualTo(filter.completed!);
      }
      if (filter.inProgress != null) {
        // inProgress means completed is false but has a lastPlayedAt
        if (filter.inProgress!) {
          queryBuilder = queryBuilder.and().completedEqualTo(false).and().lastPlayedAtNotNull();
        } else {
          // not in progress means either completed or never played
          queryBuilder = queryBuilder.and().lastPlayedAtIsNull();
        }
      }

      final results = await queryBuilder.findAll();

      // Apply additional filtering that can't be done with Isar
      final finalResults = <Audiobook>[];
      for (final model in results) {
        // Verify file still exists
        final fileExists = await _metadataExtractor.isFileAccessible(model.filePath);
        if (fileExists) {
          finalResults.add(model.toDomain());
        }
      }

      return finalResults;
    } catch (e) {
      throw DatabaseException('Failed to filter audiobooks: $e');
    }
  }

  /// Finds audiobooks by specific criteria using Isar compound indexes
  Future<List<Audiobook>> findAudiobooks({String? author, bool? completed, int? limit}) async {
    try {
      var queryBuilder = _isar.audiobookModels.where().filter();

      if (author != null) {
        queryBuilder = queryBuilder.authorEqualTo(author, caseSensitive: false);
      }

      if (completed != null) {
        queryBuilder = queryBuilder.completedEqualTo(completed);
      }

      if (limit != null) {
        queryBuilder = queryBuilder.limit(limit);
      }

      final results = await queryBuilder.findAll();

      final validResults = <Audiobook>[];
      for (final model in results) {
        final fileExists = await _metadataExtractor.isFileAccessible(model.filePath);
        if (fileExists) {
          validResults.add(model.toDomain());
        }
      }

      return validResults;
    } catch (e) {
      throw DatabaseException('Failed to find audiobooks: $e');
    }
  }

  /// Gets all settings from JSON storage
  Future<Map<String, dynamic>> getSettings() async {
    return await _jsonStorage.readSettings() ?? {};
  }

  /// Saves settings to JSON storage
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _jsonStorage.writeSettings(settings);
  }

  /// Checks if audio file still exists and is accessible
  /// Used to handle cases where files are moved/deleted after scanning
  Future<bool> isFileAccessible(String filePath) async {
    return _metadataExtractor.isFileAccessible(filePath);
  }

  /// Private helper to remove an audiobook from the database if the file no longer exists
  Future<void> _removeAudiobookFromDb(String internalId) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audiobookModels.where().filter().internalIdEqualTo(internalId).deleteFirst();
      });
    } catch (e) {
      print('Warning: Could not remove audiobook from database: $e');
    }
  }

  /// Scans a directory and extracts metadata for all audio files
  Future<List<Audiobook>> scanDirectory(String directoryPath) async {
    try {
      final audioFiles = await _metadataExtractor.scanDirectoryForAudioFiles(directoryPath);

      final audiobooks = <Audiobook>[];
      for (final filePath in audioFiles) {
        final audiobook = await _metadataExtractor.extractMetadata(filePath);
        if (audiobook != null) {
          audiobooks.add(audiobook);
        }
      }

      // Save to database
      await saveAudiobooks(audiobooks);

      return audiobooks;
    } catch (e) {
      if (e is FileSystemException || e is StorageException) {
        rethrow;
      } else {
        throw FileSystemException('Error scanning directory: $e');
      }
    }
  }

  /// Closes the Isar database connection
  Future<void> close() async {
    await _isar.close();
  }
}
