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
import 'package:flutbook/features/sync/data/datasources/conflict_resolver_ds.dart';
import 'package:flutbook/features/sync/data/models/conflict_model.dart';
import 'package:flutbook/features/sync/domain/repositories/library_sync_repository.dart';
import 'package:uuid/uuid.dart';

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
    ConflictResolverDatasource? conflictDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource,
       _conflictDs = conflictDatasource;

  final AudiobookLocalDatasource _localDatasource;
  final SupabaseLibraryDatasource _remoteDatasource;
  final ConflictResolverDatasource? _conflictDs;
  final _uuid = const Uuid();

  static const _lastSyncTimeKey = 'library_sync_last_sync_time';

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
              AudiobookModel.fromDomain(localBook),
            );
            uploadedCount++;
          } else {
            // Book exists in both — check for conflicts based on createdAt
            final localTime = localBook.createdAt;
            final remoteTime = remoteBook.createdAt;

            if (localTime != remoteTime) {
              // Consult any user resolution recorded for this entity in a
              // previous sync before falling back to last-write-wins (m2).
              // Otherwise we would silently overwrite the user's earlier
              // local/remote choice every time the book was re-synced.
              final prior = await _priorResolutionFor(
                ConflictEntityType.library,
                localBook.id,
              );

              if (prior == null) {
                await _recordConflict(
                  entityId: localBook.id,
                  entityTitle: localBook.title,
                  localData: {
                    'createdAt': localTime.toIso8601String(),
                    'title': localBook.title,
                  },
                  remoteData: {
                    'createdAt': remoteTime.toIso8601String(),
                    'title': remoteBook.title,
                  },
                  localTimestamp: localTime,
                  remoteTimestamp: remoteTime,
                );
              } else {
                // Honour the previously chosen side.
                conflictsResolved++;
              }

              // Decide which side wins: a user resolution takes priority,
              // otherwise fall back to last-write-wins.
              final localWins = switch (prior?.resolutionStrategy) {
                ConflictResolutionStrategy.localWins => true,
                ConflictResolutionStrategy.remoteWins => false,
                ConflictResolutionStrategy.manual || 
                ConflictResolutionStrategy.lastWriteWins || null =>
                  localTime.isAfter(remoteTime),
              };

              if (localWins) {
                // Local is newer (or user chose local) - upload to remote
                await _remoteDatasource.uploadAudiobookMetadata(
                  AudiobookModel.fromDomain(localBook),
                );
                uploadedCount++;
                if (prior == null) {
                  conflictsResolved++;
                }
              }
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
              // Remote is newer - check the user didn't already choose to keep
              // the local version for this entity (m2). If they did, leave the
              // local copy untouched rather than overwriting their choice.
              final prior = await _priorResolutionFor(
                ConflictEntityType.library,
                localBook.id,
              );
              if (prior?.resolutionStrategy ==
                  ConflictResolutionStrategy.localWins) {
                conflictsResolved++;
                continue;
              }

              // Remote wins - download to local. Preserve the locally cached
              // chapters and preferred speed: the remote sync payload does not
              // carry chapters, so a blind overwrite would drop them.
              final merged = localBook.copyWith(
                title: remoteBook.title,
                author: remoteBook.author,
                album: remoteBook.album,
                coverArtPath: remoteBook.coverArtPath,
                duration: remoteBook.duration,
                completed: remoteBook.completed,
                totalSize: remoteBook.totalSize,
                lastPlayedAt: remoteBook.lastPlayedAt,
                createdAt: remoteBook.createdAt,
              );
              await _localDatasource.saveAudiobooks([merged]);
              downloadedCount++;
              conflictsResolved++;
            }
          }
        } catch (e) {
          errors.add('Failed to download ${remoteBook.title}: $e');
        }
      }

      // Step 4: Track when the library last synced so the UI can reflect it
      // and so pending-change counts have a meaningful baseline.
      final now = DateTime.now();
      await _persistLastSyncTime(now);

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
        AudiobookModel.fromDomain(audiobook),
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
    try {
      final settings = await _localDatasource.getSettings();
      final stored = settings[_lastSyncTimeKey];
      if (stored is String) {
        return DateTime.tryParse(stored);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Persists the last successful library sync time using the existing
  /// JSON settings storage (no new dependency or schema required).
  Future<void> _persistLastSyncTime(DateTime time) async {
    try {
      final settings = await _localDatasource.getSettings();
      settings[_lastSyncTimeKey] = time.toIso8601String();
      await _localDatasource.saveSettings(settings);
    } catch (e) {
      // Non-fatal: failing to persist the timestamp should never block sync.
    }
  }

  @override
  Future<void> clearSyncQueue() async {
    // The library sync is a stateless full reconciliation driven by created_at
    // timestamps rather than an outbox queue, so there is no queue to drain.
    // Clearing is a no-op by design.
  }

  @override
  Future<int> getPendingSyncCount() async {
    // Approximate the number of local changes not yet pushed to remote since
    // the last successful sync. Local-only books (no remote counterpart) are
    // considered pending.
    try {
      final localAudiobooks = await _localDatasource.getAudiobooks();
      final remoteMetadata = await getRemoteMetadataSafe();
      final remotePaths = remoteMetadata.map((m) => m.filePath).toSet();

      var pending = 0;
      for (final book in localAudiobooks) {
        if (!remotePaths.contains(book.filePath)) {
          pending++;
        }
      }
      return pending;
    } catch (e) {
      return 0;
    }
  }

  /// Fetches remote audiobook metadata, yielding an empty list on failure so
  /// callers (e.g. pending-count UI) degrade gracefully instead of throwing.
  Future<List<AudiobookModel>> getRemoteMetadataSafe() async {
    try {
      return await _remoteDatasource.getAudiobookMetadata();
    } catch (e) {
      return const <AudiobookModel>[];
    }
  }

  /// Returns a previously recorded user resolution for an entity, or null if
  /// none exists. Guards against a null conflict datasource.
  Future<SyncConflict?> _priorResolutionFor(
    ConflictEntityType entityType,
    String entityId,
  ) async {
    final ds = _conflictDs;
    if (ds == null) return null;
    try {
      return await ds.getResolvedConflict(
        entityType: entityType,
        entityId: entityId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _recordConflict({
    required String entityId,
    required String entityTitle,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  }) async {
    if (_conflictDs == null) return;
    final conflict = SyncConflict(
      id: _uuid.v4(),
      entityType: ConflictEntityType.library,
      entityId: entityId,
      entityTitle: entityTitle,
      localData: localData,
      remoteData: remoteData,
      localTimestamp: localTimestamp,
      remoteTimestamp: remoteTimestamp,
    );
    await _conflictDs.saveConflict(conflict);
  }
}
