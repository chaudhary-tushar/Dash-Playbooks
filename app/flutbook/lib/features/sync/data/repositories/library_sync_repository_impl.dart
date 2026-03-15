/// Implementation of library synchronization repository.
///
/// Handles bidirectional sync between local Isar database
/// and remote Supabase database with conflict resolution.
library;

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/library/data/datasources/audiobook_local_ds.dart';
import 'package:flutbook/features/library/data/datasources/remote/supabase_library_sync.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/sync/domain/repositories/library_sync_repository.dart';

/// Implementation of [LibrarySyncRepository].
///
/// Provides bidirectional sync with conflict resolution using
/// last-write-wins strategy based on updated_at timestamps.
class LibrarySyncRepositoryImpl implements LibrarySyncRepository {
  /// Create a new LibrarySyncRepositoryImpl.
  ///
  /// [localDatasource] - Local Isar database datasource
  /// [remoteDatasource] - Remote Supabase datasource
  LibrarySyncRepositoryImpl({
    required AudiobookLocalDatasource localDatasource,
    required SupabaseLibraryDatasource remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource;

  final AudiobookLocalDatasource _localDatasource;
  final SupabaseLibraryDatasource _remoteDatasource;

  @override
  Future<SyncResult> syncLibrary() async {
    try {
      final errors = <String>[];
      int uploadedCount = 0;
      int downloadedCount = 0;
      int conflictsResolved = 0;

      // Step 1: Get local and remote audiobooks
      final localAudiobooks = await _localDatasource.getAudiobooks();
      final remoteAudiobooks = await getAllRemoteAudiobooks();

      // Create maps for quick lookup
      final localMap = {for (final audiobook in localAudiobooks) audiobook.filePath: audiobook};
      final remoteMap = {for (final audiobook in remoteAudiobooks) audiobook.filePath: audiobook};

      // Step 2: Upload local changes to remote
      for (final localBook in localAudiobooks) {
        try {
          final remoteBook = remoteMap[localBook.filePath];

          if (remoteBook == null) {
            // New local book - upload to remote
            await _remoteDatasource.uploadAudiobookMetadata(
              localBook as AudiobookModel,
            );
            uploadedCount++;
          } else {
            // Book exists in both - check for conflicts based on createdAt timestamp
            final localTime = localBook.createdAt;
            final remoteTime = remoteBook.createdAt;

            if (localTime.isAfter(remoteTime)) {
              // Local is newer - upload to remote
              await _remoteDatasource.uploadAudiobookMetadata(
                AudiobookModel.fromDomain(localBook),
              );
              uploadedCount++;
              conflictsResolved++;
            }
          }
        } catch (e) {
          errors.add('Failed to upload ${localBook.title}: $e');
        }
      }

      // Step 3: Download remote changes to local
      for (final remoteBook in remoteAudiobooks) {
        try {
          final localBook = localMap[remoteBook.filePath];

          if (localBook == null) {
            // New remote book - download to local
            await _localDatasource.saveAudiobooks([remoteBook]);
            downloadedCount++;
          } else {
            // Book exists in both - check for conflicts based on createdAt timestamp
            final localTime = localBook.createdAt;
            final remoteTime = remoteBook.createdAt;

            if (remoteTime.isAfter(localTime)) {
              // Remote is newer - download to local
              await _localDatasource.saveAudiobooks([remoteBook]);
              downloadedCount++;
              conflictsResolved++;
            }
          }
        } catch (e) {
          errors.add('Failed to download ${remoteBook.title}: $e');
        }
      }

      // Determine sync status
      SyncStatus status;
      if (errors.isEmpty && (uploadedCount > 0 || downloadedCount > 0)) {
        status = SyncStatus.success;
      } else if (errors.isEmpty) {
        status = SyncStatus.idle; // No changes to sync
      } else if (uploadedCount > 0 || downloadedCount > 0) {
        status = SyncStatus.partial;
      } else {
        status = SyncStatus.failed;
      }

      return SyncResult(
        status: status,
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictsResolved: conflictsResolved,
        errors: errors,
      );
    } catch (e) {
      throw DatabaseException('Library sync failed: $e');
    }
  }

  @override
  Future<void> uploadAudiobook(Audiobook audiobook) async {
    try {
      await _remoteDatasource.uploadAudiobookMetadata(
        audiobook as AudiobookModel,
      );
    } catch (e) {
      throw DatabaseException('Failed to upload audiobook: $e');
    }
  }

  @override
  Future<Audiobook?> downloadAudiobook(String audiobookId) async {
    try {
      final audiobooks = await getAllRemoteAudiobooks();
      try {
        return audiobooks.firstWhere(
          (a) => a.id == audiobookId,
        );
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw DatabaseException('Failed to download audiobook: $e');
    }
  }

  @override
  Future<void> deleteAudiobook(String audiobookId) async {
    try {
      await _remoteDatasource.deleteAudiobookMetadata(audiobookId);
    } catch (e) {
      throw DatabaseException('Failed to delete audiobook: $e');
    }
  }

  @override
  Future<List<Audiobook>> getAllRemoteAudiobooks() async {
    try {
      final metadata = await _remoteDatasource.getAudiobookMetadata();
      // Convert AudiobookModel to Audiobook domain entity
      return metadata.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw DatabaseException('Failed to get remote audiobooks: $e');
    }
  }

  @override
  Future<bool> canSync() async {
    try {
      // Check if remote datasource is authenticated
      return await _remoteDatasource.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    // TODO: Implement sync timestamp tracking
    return null;
  }

  @override
  Future<void> clearSyncQueue() async {
    // TODO: Implement sync queue management
  }

  @override
  Future<int> getPendingSyncCount() async {
    // TODO: Implement sync queue management
    return 0;
  }
}
