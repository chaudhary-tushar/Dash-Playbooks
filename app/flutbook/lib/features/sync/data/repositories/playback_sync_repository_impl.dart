/// Implementation of playback position synchronization repository.
///
/// Handles bidirectional sync between local Isar database
/// and remote Supabase database with conflict resolution.
library;

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/datasources/playback_local_ds.dart';
import 'package:flutbook/features/player/data/datasources/remote/supabase_playback_sync.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/sync/domain/repositories/playback_sync_repository.dart';

/// Implementation of [PlaybackSyncRepository].
///
/// Provides bidirectional sync with conflict resolution using
/// last-write-wins strategy based on last_played_at timestamps.
class PlaybackSyncRepositoryImpl implements PlaybackSyncRepository {
  /// Create a new PlaybackSyncRepositoryImpl.
  ///
  /// [localDatasource] - Local Isar database datasource
  /// [remoteDatasource] - Remote Supabase datasource
  PlaybackSyncRepositoryImpl({
    required PlaybackLocalDatasource localDatasource,
    required SupabasePlaybackDatasource remoteDatasource,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource;

  final PlaybackLocalDatasource _localDatasource;
  final SupabasePlaybackDatasource _remoteDatasource;

  @override
  Future<PlaybackSyncResult> syncPlaybackPositions() async {
    try {
      final errors = <String>[];
      int uploadedCount = 0;
      int downloadedCount = 0;
      int conflictsResolved = 0;

      // Step 1: Get local and remote playback sessions
      final localSessions = await _localDatasource.getPlaybackSessions();
      final remoteSessions = await getAllRemotePlaybackSessions();

      // Create maps for quick lookup by audiobook_id
      final localMap = {
        for (final session in localSessions) session.audiobookId: session
      };
      final remoteMap = {
        for (final session in remoteSessions) session.audiobookId: session
      };

      // Step 2: Upload local changes to remote
      for (final localSession in localSessions) {
        try {
          final remoteSession = remoteMap[localSession.audiobookId];

          if (remoteSession == null) {
            // New local session - upload to remote
            await _remoteDatasource.uploadPlaybackSession(localSession);
            uploadedCount++;
          } else {
            // Session exists in both - check for conflicts
            if (localSession.lastPlayedAt.isAfter(remoteSession.lastPlayedAt)) {
              // Local is newer - upload to remote with conflict resolution
              await uploadWithConflictResolution(localSession);
              uploadedCount++;
              conflictsResolved++;
            }
          }
        } catch (e) {
          errors.add('Failed to upload position for ${localSession.audiobookId}: $e');
        }
      }

      // Step 3: Download remote changes to local
      for (final remoteSession in remoteSessions) {
        try {
          final localSession = localMap[remoteSession.audiobookId];

          if (localSession == null) {
            // New remote session - download to local
            await _localDatasource.savePlaybackSession(remoteSession);
            downloadedCount++;
          } else {
            // Session exists in both - check for conflicts
            if (remoteSession.lastPlayedAt.isAfter(localSession.lastPlayedAt)) {
              // Remote is newer - download to local
              await _localDatasource.savePlaybackSession(remoteSession);
              downloadedCount++;
              conflictsResolved++;
            }
          }
        } catch (e) {
          errors.add('Failed to download position for ${remoteSession.audiobookId}: $e');
        }
      }

      // Determine sync status
      PlaybackSyncStatus status;
      if (errors.isEmpty && (uploadedCount > 0 || downloadedCount > 0)) {
        status = PlaybackSyncStatus.success;
      } else if (errors.isEmpty) {
        status = PlaybackSyncStatus.idle; // No changes to sync
      } else if (uploadedCount > 0 || downloadedCount > 0) {
        status = PlaybackSyncStatus.partial;
      } else {
        status = PlaybackSyncStatus.failed;
      }

      return PlaybackSyncResult(
        status: status,
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictsResolved: conflictsResolved,
        errors: errors,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      throw DatabaseException('Playback position sync failed: $e');
    }
  }

  @override
  Future<void> uploadPlaybackPosition(PlaybackSession session) async {
    try {
      await _remoteDatasource.uploadPlaybackSession(session);
    } catch (e) {
      throw DatabaseException('Failed to upload playback position: $e');
    }
  }

  @override
  Future<PlaybackSession?> downloadPlaybackPosition(String audiobookId) async {
    try {
      return await _remoteDatasource.getPlaybackSession(audiobookId);
    } catch (e) {
      throw DatabaseException('Failed to download playback position: $e');
    }
  }

  @override
  Future<List<PlaybackSession>> getAllRemotePlaybackSessions() async {
    try {
      return await _remoteDatasource.getPlaybackSessions();
    } catch (e) {
      throw DatabaseException('Failed to get remote playback sessions: $e');
    }
  }

  @override
  Future<void> deletePlaybackPosition(String audiobookId) async {
    try {
      await _remoteDatasource.deletePlaybackSession(audiobookId);
    } catch (e) {
      throw DatabaseException('Failed to delete playback position: $e');
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
  Future<void> uploadWithConflictResolution(PlaybackSession session, {bool force = false}) async {
    try {
      if (force) {
        // Force upload without checking conflicts
        await _remoteDatasource.uploadPlaybackSession(session);
      } else {
        // Check for conflicts
        final remoteSession = await _remoteDatasource.getPlaybackSession(session.audiobookId);
        
        if (remoteSession == null || session.lastPlayedAt.isAfter(remoteSession.lastPlayedAt)) {
          // No conflict or local is newer - upload
          await _remoteDatasource.uploadPlaybackSession(session);
        }
        // else: Remote is newer, don't overwrite
      }
    } catch (e) {
      throw DatabaseException('Failed to upload with conflict resolution: $e');
    }
  }
}
