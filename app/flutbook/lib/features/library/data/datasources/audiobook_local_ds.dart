// lib/data/datasources/local/audiobook_local_datasource.dart

import 'dart:io';

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/core/services/json_storage_service.dart';
import 'package:flutbook/features/directory_selection/data/datasources/metadat_extractor_ds.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:isar_community/isar.dart';

/// Local data source for audiobook operations with Isar database.
///
/// This datasource is responsible ONLY for:
/// - Storing and retrieving audiobooks from Isar
/// - Querying the database
/// - Managing JSON settings storage
///
/// It does NOT handle metadata extraction or depend on MetadataExtractionDatasource.
class AudiobookLocalDatasource {
  AudiobookLocalDatasource(
    this._isar, {
    required JsonStorage jsonStorage,
  }) : _jsonStorage = jsonStorage;

  final Isar _isar; // Injected via constructor
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
  Future<List<Audiobook>> getAudiobooks() async {
    try {
      final audiobookModels = await _isar.audiobookModels.where().findAll();
      return audiobookModels.map((model) => model.toDomain()).toList();
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
        return audiobookModel.toDomain();
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

  Future<void> deleteAudiobook(String audiobookId) async {
    await _removeAudiobookFromDb(audiobookId);
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
  /// NOTE: File existence validation should be done by the caller, not in the datasource
  Future<bool> isFileAccessible(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final fileStat = await file.stat();
      return fileStat.type == FileSystemEntityType.file;
    } catch (e) {
      debugPrint('File access check failed for $filePath: $e');
      return false;
    }
  }

  /// Scans a directory and extracts metadata for all audio files
  /// NOTE: This method is deprecated. Use ScanLibraryUseCase instead.
  Future<List<Audiobook>> scanDirectory(String directoryPath) async {
    try {
      final metadataExtractor = MetadataExtractionDatasource();

      // Scan directory for audio files
      final audioFiles = await metadataExtractor.scanDirectoryForAudioFiles(directoryPath);

      // Extract metadata for each file
      final audiobooks = <Audiobook>[];
      for (final filePath in audioFiles) {
        final audiobook = await metadataExtractor.extractMetadata(filePath);
        if (audiobook != null) {
          audiobooks.add(audiobook);
        }
      }

      return audiobooks;
    } catch (e) {
      throw FileSystemException('Failed to scan directory: $e');
    }
  }

  /// Closes the Isar database connection
  Future<void> close() async {
    await _isar.close();
  }
}
