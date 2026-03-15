/// Library synchronization repository interface.
///
/// Defines the contract for library synchronization operations
/// between local storage and remote Supabase database.
library;

import 'package:flutbook/features/library/domain/entities/audiobook.dart';

/// Result of a sync operation.
enum SyncStatus {
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

/// Result of a library sync operation.
class SyncResult {
  const SyncResult({
    required this.status,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictsResolved = 0,
    this.errors = const [],
  });

  final SyncStatus status;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictsResolved;
  final List<String> errors;

  bool get isSuccess => status == SyncStatus.success;
  bool get hasErrors => errors.isNotEmpty;

  SyncResult copyWith({
    SyncStatus? status,
    int? uploadedCount,
    int? downloadedCount,
    int? conflictsResolved,
    List<String>? errors,
  }) {
    return SyncResult(
      status: status ?? this.status,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      conflictsResolved: conflictsResolved ?? this.conflictsResolved,
      errors: errors ?? this.errors,
    );
  }
}

/// Repository interface for library synchronization.
///
/// This interface defines the contract for syncing audiobook library
/// data between local storage and remote Supabase database.
abstract class LibrarySyncRepository {
  /// Sync local library with remote Supabase database.
  ///
  /// Performs bidirectional sync:
  /// 1. Uploads local changes to remote
  /// 2. Downloads remote changes to local
  /// 3. Resolves conflicts using last-write-wins strategy
  ///
  /// Returns [SyncResult] with sync statistics.
  Future<SyncResult> syncLibrary();

  /// Upload local audiobook to remote database.
  ///
  /// [audiobook] - The audiobook to upload
  Future<void> uploadAudiobook(Audiobook audiobook);

  /// Download audiobook from remote database.
  ///
  /// [audiobookId] - The ID of the audiobook to download
  Future<Audiobook?> downloadAudiobook(String audiobookId);

  /// Delete audiobook from remote database.
  ///
  /// [audiobookId] - The ID of the audiobook to delete
  Future<void> deleteAudiobook(String audiobookId);

  /// Get all audiobooks from remote database.
  ///
  /// Returns a list of all audiobooks for the current user.
  Future<List<Audiobook>> getAllRemoteAudiobooks();

  /// Check if sync is available (user authenticated and online).
  ///
  /// Returns true if sync can be performed.
  Future<bool> canSync();

  /// Get last sync timestamp.
  ///
  /// Returns the timestamp of the last successful sync.
  Future<DateTime?> getLastSyncTime();

  /// Clear sync queue (offline operations).
  ///
  /// Removes all pending sync operations from the queue.
  Future<void> clearSyncQueue();

  /// Get pending sync queue count.
  ///
  /// Returns the number of pending sync operations.
  Future<int> getPendingSyncCount();
}
