/// Playback position synchronization repository interface.
///
/// Defines the contract for syncing playback position data
/// between local storage and remote Supabase database.
library;

import 'package:flutbook/features/player/domain/entities/playback_session.dart';

/// Result of a playback position sync operation.
class PlaybackSyncResult {
  const PlaybackSyncResult({
    required this.status,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictsResolved = 0,
    this.errors = const [],
    this.lastSyncTime,
  });

  final PlaybackSyncStatus status;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictsResolved;
  final List<String> errors;
  final DateTime? lastSyncTime;

  bool get isSuccess => status == PlaybackSyncStatus.success;
  bool get hasErrors => errors.isNotEmpty;

  PlaybackSyncResult copyWith({
    PlaybackSyncStatus? status,
    int? uploadedCount,
    int? downloadedCount,
    int? conflictsResolved,
    List<String>? errors,
    DateTime? lastSyncTime,
  }) {
    return PlaybackSyncResult(
      status: status ?? this.status,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      conflictsResolved: conflictsResolved ?? this.conflictsResolved,
      errors: errors ?? this.errors,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Playback sync status enumeration.
enum PlaybackSyncStatus {
  /// Sync completed successfully
  success,

  /// Sync completed with some errors
  partial,

  /// Sync failed completely
  failed,

  /// Sync is currently in progress
  syncing,

  /// No sync performed (offline or no changes)
  idle,
}

/// Repository interface for playback position synchronization.
///
/// This interface defines the contract for syncing playback position
/// data between local storage and remote Supabase database.
abstract class PlaybackSyncRepository {
  /// Sync local playback positions with remote Supabase database.
  ///
  /// Performs bidirectional sync:
  /// 1. Uploads local playback positions to remote
  /// 2. Downloads remote playback positions to local
  /// 3. Resolves conflicts using last-write-wins strategy
  ///
  /// Returns [PlaybackSyncResult] with sync statistics.
  Future<PlaybackSyncResult> syncPlaybackPositions();

  /// Upload local playback position to remote database.
  ///
  /// [session] - The playback session to upload
  Future<void> uploadPlaybackPosition(PlaybackSession session);

  /// Download playback position from remote database.
  ///
  /// [audiobookId] - The ID of the audiobook to get position for
  Future<PlaybackSession?> downloadPlaybackPosition(String audiobookId);

  /// Get all playback positions from remote database.
  ///
  /// Returns a list of all playback sessions for the current user.
  Future<List<PlaybackSession>> getAllRemotePlaybackSessions();

  /// Delete playback position from remote database.
  ///
  /// [audiobookId] - The ID of the audiobook to delete position for
  Future<void> deletePlaybackPosition(String audiobookId);

  /// Check if sync is available (user authenticated and online).
  ///
  /// Returns true if sync can be performed.
  Future<bool> canSync();

  /// Get last sync timestamp for playback positions.
  ///
  /// Returns the timestamp of the last successful sync.
  Future<DateTime?> getLastSyncTime();

  /// Upload playback position with conflict resolution.
  ///
  /// [session] - The playback session to upload
  /// [force] - If true, overwrite remote without checking conflicts
  Future<void> uploadWithConflictResolution(PlaybackSession session, {bool force = false});
}
