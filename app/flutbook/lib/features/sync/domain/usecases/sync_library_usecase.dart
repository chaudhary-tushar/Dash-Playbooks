/// Use case for synchronizing library with remote database.
///
/// Orchestrates the bidirectional sync process between local
/// and remote audiobook libraries.
library;

import 'package:flutbook/features/sync/domain/repositories/library_sync_repository.dart';

/// Use case for library synchronization.
///
/// Executes the library sync process and returns sync results.
class SyncLibraryUseCase {
  /// Create a new SyncLibraryUseCase.
  ///
  /// [repository] - The library sync repository
  const SyncLibraryUseCase({
    required LibrarySyncRepository repository,
  }) : _repository = repository;

  final LibrarySyncRepository _repository;

  /// Execute library sync.
  ///
  /// Performs bidirectional sync between local and remote libraries.
  /// Returns [SyncResult] with sync statistics and status.
  ///
  /// Usage:
  /// ```dart
  /// final syncUseCase = SyncLibraryUseCase(repository: repo);
  /// final result = await syncUseCase.execute();
  ///
  /// if (result.isSuccess) {
  ///   print('Synced ${result.uploadedCount} uploads, ${result.downloadedCount} downloads');
  /// } else {
  ///   print('Sync failed: ${result.errors}');
  /// }
  /// ```
  Future<SyncResult> execute() async {
    // Check if sync is possible
    final canSync = await _repository.canSync();
    if (!canSync) {
      return const SyncResult(
        status: SyncStatus.idle,
        errors: ['Cannot sync: User not authenticated or offline'],
      );
    }

    // Perform the sync
    return _repository.syncLibrary();
  }

  /// Check if sync is available.
  ///
  /// Returns true if user is authenticated and online.
  Future<bool> canSync() => _repository.canSync();

  /// Get last sync timestamp.
  ///
  /// Returns null if no sync has been performed.
  Future<DateTime?> getLastSyncTime() => _repository.getLastSyncTime();

  /// Get pending sync queue count.
  ///
  /// Returns the number of operations waiting to be synced.
  Future<int> getPendingSyncCount() => _repository.getPendingSyncCount();
}
