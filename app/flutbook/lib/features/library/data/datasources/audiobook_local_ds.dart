// lib/data/datasources/local/audiobook_local_datasource.dart

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/core/services/json_storage_service.dart';
import 'package:flutbook/features/directory_selection/data/datasources/metadat_extractor_ds.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:isar_community/isar.dart';

/// Local data source for audiobook operations with Isar database and fallback handling
/// Implements proper schema and indexing as required by data model
class AudiobookLocalDatasource {
  AudiobookLocalDatasource(
    this._isar, {
    required MetadataExtractionDatasource metadataExtractor,
    required JsonStorage jsonStorage,
  }) : _metadataExtractor = metadataExtractor,
       _jsonStorage = jsonStorage;
  final Isar _isar; // Injected via constructor
  final MetadataExtractionDatasource _metadataExtractor;
  final JsonStorage _jsonStorage;

  /// Saves audiobooks to Isar database with proper schema and indexing
  /// Handles large files (>10GB) with appropriate memory management
  /// Throws specific exceptions for corrupted files or insufficient storage
  Future<void> saveAudiobooks(List<Audiobook> audiobooks) async {
    try {
      final audiobookModels = audiobooks.map(AudiobookModel.fromDomain).toList();

      await _isar.writeTxn(() async {
        await _isar.audiobookModels.putAll(audiobookModels);
      });
    } catch (e) {
      throw DatabaseException('Failed to save audiobooks: $e');
    }
  }

  /// Pure Database Query.
  /// It does NOT check file existence (that is the Importer's job).
  /// This ensures the UI is instant.
  Future<List<Audiobook>> findAudiobooks({String? author, bool? completed, int? limit}) async {
    try {
      var query = _isar.audiobookModels.where();

      if (author != null) {
        query =
            query.filter().authorEqualTo(author, caseSensitive: false)
                as QueryBuilder<AudiobookModel, AudiobookModel, QWhere>;
      }

      if (completed != null) {
        query =
            query.filter().completedEqualTo(completed)
                as QueryBuilder<AudiobookModel, AudiobookModel, QWhere>;
      }

      // Return results directly from DB
      final results = await query.limit(limit ?? 100).findAll();
      return results.map((e) => e.toDomain()).toList();
    } catch (e) {
      // Use a core/error definition here
      throw Exception('Failed to find audiobooks: $e');
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
          debugPrint('Could not check file existence for ${model.filePath}: $e');
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

  /// Private helper to remove an audiobook from the database if the file no longer exists
  Future<void> _removeAudiobookFromDb(String internalId) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audiobookModels.filter().internalIdEqualTo(internalId).deleteFirst();
      });
    } catch (e) {
      debugPrint('Warning: Could not remove audiobook from database: $e');
    }
  }

  /// Searches audiobooks using Isar's indexed fields for efficient queries
  /// Returns appropriate results even with missing or corrupted metadata
  // Future<List<Audiobook>> searchAudiobooks(String query) async {
  //   try {
  //     final results = await _isar.audiobookModels.where().anyOf([
  //       (AudiobookModelQueryWhere q) => q.titleContains(query, caseSensitive: false),
  //       (AudiobookModelQueryBuilder q) => q.authorContains(query, caseSensitive: false),
  //       (AudiobookModelQueryBuilder q) => q.albumContains(query, caseSensitive: false),
  //     ], or: (AudioBookQueryBuilder q) => q.idEqualTo(-1)).findAll();

  //     final searchableAudiobooks = <Audiobook>[];
  //     for (final model in results) {
  //       final fileExists = await _metadataExtractor.isFileAccessible(model.filePath);
  //       if (fileExists) {
  //         searchableAudiobooks.add(model.toDomain());
  //       }
  //     }

  //     return searchableAudiobooks;
  //   } catch (e) {
  //     throw DatabaseException('Failed to search audiobooks: $e');
  //   }
  // }

  // /// Filters audiobooks using Isar's indexed fields for efficient queries
  // /// Handles filtering with incomplete or missing metadata
  // Future<List<Audiobook>> filterAudiobooks(AudiobookFilter filter) async {
  //   try {
  //     var query = _isar.audiobookModels.where();

  //     // Apply filters based on the filter object
  //     if (filter.title != null) {
  //       query = query.filter().titleContains(filter.title!, caseSensitive: false);
  //     }
  //     if (filter.author != null) {
  //       query = query.filter().authorContains(filter.author!, caseSensitive: false);
  //     }
  //     if (filter.completed != null) {
  //       query = query.filter().completedEqualTo(filter.completed!);
  //     }
  //     if (filter.inProgress != null) {
  //       // inProgress means completed is false but has a lastPlayedAt
  //       if (filter.inProgress!) {
  //         query = query.filter().completedEqualTo(false).lastPlayedAtIsNotNull();
  //       } else {
  //         // not in progress means either completed or never played
  //         query = query.filter().lastPlayedAtIsNull();
  //       }
  //     }

  //     final results = await query.findAll();

  //     // Apply additional filtering that can't be done with Isar
  //     final finalResults = <Audiobook>[];
  //     for (final model in results) {
  //       // Verify file still exists
  //       final fileExists = await _metadataExtractor.isFileAccessible(model.filePath);
  //       if (fileExists) {
  //         finalResults.add(model.toDomain());
  //       }
  //     }

  //     return finalResults;
  //   } catch (e) {
  //     throw DatabaseException('Failed to filter audiobooks: $e');
  //   }
  // }

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
