/// Use case for synchronizing playback position with remote database.
///
/// Orchestrates the sync process for playback positions between local
/// and remote storage with conflict resolution.
library;

import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/sync/domain/repositories/playback_sync_repository.dart';

/// Use case for playback position synchronization.
///
/// Executes the playback position sync process and returns sync results.
class SyncPlaybackPositionUseCase {
  /// Create a new SyncPlaybackPositionUseCase.
  ///
  /// [repository] - The playback sync repository
  const SyncPlaybackPositionUseCase({
    required PlaybackSyncRepository repository,
  }) : _repository = repository;

  final PlaybackSyncRepository _repository;

  /// Execute playback position sync.
  ///
  /// Performs bidirectional sync between local and remote playback positions.
  /// Returns [PlaybackSyncResult] with sync statistics and status.
  ///
  /// Usage:
  /// ```dart
  /// final syncUseCase = SyncPlaybackPositionUseCase(repository: repo);
  /// final result = await syncUseCase.execute();
  ///
  /// if (result.isSuccess) {
  ///   print('Synced ${result.uploadedCount} uploads, ${result.downloadedCount} downloads');
  /// } else {
  ///   print('Sync failed: ${result.errors}');
  /// }
  /// ```
  Future<PlaybackSyncResult> execute() async {
    // Check if sync is possible
    final canSync = await _repository.canSync();
    if (!canSync) {
      return const PlaybackSyncResult(
        status: PlaybackSyncStatus.idle,
        errors: ['Cannot sync: User not authenticated or offline'],
      );
    }

    // Perform the sync
    return _repository.syncPlaybackPositions();
  }

  /// Upload a single playback position.
  ///
  /// Use this for real-time sync when position changes.
  Future<void> uploadPosition(PlaybackSession session) async {
    final canSync = await _repository.canSync();
    if (canSync) {
      await _repository.uploadWithConflictResolution(session);
    }
  }

  /// Download playback position for a specific audiobook.
  ///
  /// Returns null if no position exists.
  Future<PlaybackSession?> getPositionForAudiobook(String audiobookId) async {
    return _repository.downloadPlaybackPosition(audiobookId);
  }

  /// Check if sync is available.
  ///
  /// Returns true if user is authenticated and online.
  Future<bool> canSync() => _repository.canSync();

  /// Get last sync timestamp.
  ///
  /// Returns null if no sync has been performed.
  Future<DateTime?> getLastSyncTime() => _repository.getLastSyncTime();
}
