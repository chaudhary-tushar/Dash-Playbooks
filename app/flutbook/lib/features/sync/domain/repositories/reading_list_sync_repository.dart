/// Reading list synchronization repository interface.
///
/// Defines the contract for syncing reading list data
/// between local storage and remote Supabase database.
library;

import 'package:flutbook/features/sync/domain/entities/reading_list.dart';

/// Result of a reading list sync operation.
class ReadingListSyncResult {
  const ReadingListSyncResult({
    required this.status,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictsResolved = 0,
    this.errors = const [],
  });

  final ReadingListSyncStatus status;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictsResolved;
  final List<String> errors;

  bool get isSuccess => status == ReadingListSyncStatus.success;
  bool get hasErrors => errors.isNotEmpty;

  ReadingListSyncResult copyWith({
    ReadingListSyncStatus? status,
    int? uploadedCount,
    int? downloadedCount,
    int? conflictsResolved,
    List<String>? errors,
  }) {
    return ReadingListSyncResult(
      status: status ?? this.status,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      conflictsResolved: conflictsResolved ?? this.conflictsResolved,
      errors: errors ?? this.errors,
    );
  }
}

/// Reading list sync status enumeration.
enum ReadingListSyncStatus {
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

/// Repository interface for reading list synchronization.
///
/// This interface defines the contract for managing and syncing
/// reading lists between local storage and remote Supabase database.
abstract class ReadingListSyncRepository {
  /// Sync local reading lists with remote Supabase database.
  ///
  /// Performs bidirectional sync:
  /// 1. Uploads local list changes to remote
  /// 2. Downloads remote list changes to local
  /// 3. Resolves conflicts using last-write-wins strategy
  ///
  /// Returns [ReadingListSyncResult] with sync statistics.
  Future<ReadingListSyncResult> syncReadingLists();

  /// Get all reading lists from local storage.
  ///
  /// Returns a list of all reading lists for the current user.
  Future<List<ReadingList>> getAllReadingLists();

  /// Get a specific reading list by ID.
  ///
  /// [listId] - The ID of the reading list
  Future<ReadingList?> getReadingList(String listId);

  /// Create a new reading list.
  ///
  /// [readingList] - The reading list to create
  Future<void> createReadingList(ReadingList readingList);

  /// Update an existing reading list.
  ///
  /// [readingList] - The updated reading list
  Future<void> updateReadingList(ReadingList readingList);

  /// Delete a reading list.
  ///
  /// [listId] - The ID of the reading list to delete
  Future<void> deleteReadingList(String listId);

  /// Add an audiobook to a reading list.
  ///
  /// [listId] - The ID of the reading list
  /// [audiobookId] - The ID of the audiobook to add
  Future<void> addAudiobookToList(String listId, String audiobookId);

  /// Remove an audiobook from a reading list.
  ///
  /// [listId] - The ID of the reading list
  /// [audiobookId] - The ID of the audiobook to remove
  Future<void> removeAudiobookFromList(String listId, String audiobookId);

  /// Get all reading lists from remote database.
  ///
  /// Returns a list of all remote reading lists.
  Future<List<ReadingList>> getAllRemoteReadingLists();

  /// Check if sync is available (user authenticated and online).
  ///
  /// Returns true if sync can be performed.
  Future<bool> canSync();

  /// Get last sync timestamp for reading lists.
  ///
  /// Returns the timestamp of the last successful sync.
  Future<DateTime?> getLastSyncTime();
}
