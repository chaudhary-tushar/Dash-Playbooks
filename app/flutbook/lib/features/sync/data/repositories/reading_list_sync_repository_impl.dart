/// Implementation of reading list synchronization repository.
///
/// Handles reading list management with local storage
/// and remote Supabase synchronization.
library;

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/sync/data/datasources/supabase_reading_list_datasource.dart';
import 'package:flutbook/features/sync/domain/entities/reading_list.dart';
import 'package:flutbook/features/sync/domain/repositories/reading_list_sync_repository.dart';

/// Implementation of [ReadingListSyncRepository].
///
/// Provides reading list management with sync capabilities.
class ReadingListSyncRepositoryImpl implements ReadingListSyncRepository {
  /// Create a new ReadingListSyncRepositoryImpl.
  ///
  /// [remoteDatasource] - Remote Supabase datasource
  ReadingListSyncRepositoryImpl({
    required SupabaseReadingListDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final SupabaseReadingListDatasource _remoteDatasource;

  // Local cache for reading lists
  final Map<String, ReadingList> _localCache = {};
  DateTime? _lastSyncTime;

  @override
  Future<ReadingListSyncResult> syncReadingLists() async {
    try {
      final errors = <String>[];
      int uploadedCount = 0;
      int downloadedCount = 0;
      int conflictsResolved = 0;

      // Step 1: Get local and remote reading lists
      final localLists = List<ReadingList>.from(_localCache.values);
      final remoteLists = await getAllRemoteReadingLists();

      // Create maps for quick lookup
      final localMap = {for (final list in localLists) list.id: list};
      final remoteMap = {for (final list in remoteLists) list.id: list};

      // Step 2: Upload local changes to remote
      for (final localList in localLists) {
        try {
          final remoteList = remoteMap[localList.id];

          if (remoteList == null) {
            // New local list - upload to remote
            await _remoteDatasource.createReadingList(localList);
            uploadedCount++;
          } else {
            // List exists in both - check for conflicts
            final localUpdatedAt = localList.updatedAt ?? localList.createdAt;
            final remoteUpdatedAt = remoteList.updatedAt ?? remoteList.createdAt;

            if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
              // Local is newer - upload to remote
              await _remoteDatasource.updateReadingList(localList);
              uploadedCount++;
              conflictsResolved++;
            }
          }
        } catch (e) {
          errors.add('Failed to upload list ${localList.name}: $e');
        }
      }

      // Step 3: Download remote changes to local
      for (final remoteList in remoteLists) {
        try {
          final localList = localMap[remoteList.id];

          if (localList == null) {
            // New remote list - download to local cache
            _localCache[remoteList.id] = remoteList;
            downloadedCount++;
          } else {
            // List exists in both - check for conflicts
            final localUpdatedAt = localList.updatedAt ?? localList.createdAt;
            final remoteUpdatedAt = remoteList.updatedAt ?? remoteList.createdAt;

            if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
              // Remote is newer - download to local cache
              _localCache[remoteList.id] = remoteList;
              downloadedCount++;
              conflictsResolved++;
            }
          }
        } catch (e) {
          errors.add('Failed to download list ${remoteList.name}: $e');
        }
      }

      // Update last sync time
      _lastSyncTime = DateTime.now();

      // Determine sync status
      ReadingListSyncStatus status;
      if (errors.isEmpty && (uploadedCount > 0 || downloadedCount > 0)) {
        status = ReadingListSyncStatus.success;
      } else if (errors.isEmpty) {
        status = ReadingListSyncStatus.idle;
      } else if (uploadedCount > 0 || downloadedCount > 0) {
        status = ReadingListSyncStatus.partial;
      } else {
        status = ReadingListSyncStatus.failed;
      }

      return ReadingListSyncResult(
        status: status,
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictsResolved: conflictsResolved,
        errors: errors,
      );
    } catch (e) {
      throw DatabaseException('Reading list sync failed: $e');
    }
  }

  @override
  Future<List<ReadingList>> getAllReadingLists() async {
    // Return from local cache if available
    if (_localCache.isNotEmpty) {
      return _localCache.values.toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    }

    // Otherwise fetch from remote
    try {
      final lists = await _remoteDatasource.getReadingLists();
      for (final list in lists) {
        _localCache[list.id] = list;
      }
      return lists;
    } catch (e) {
      throw DatabaseException('Failed to get reading lists: $e');
    }
  }

  @override
  Future<ReadingList?> getReadingList(String listId) async {
    // Check local cache first
    if (_localCache.containsKey(listId)) {
      return _localCache[listId];
    }

    // Fetch from remote
    try {
      final list = await _remoteDatasource.getReadingList(listId);
      if (list != null) {
        _localCache[listId] = list;
      }
      return list;
    } catch (e) {
      throw DatabaseException('Failed to get reading list: $e');
    }
  }

  @override
  Future<void> createReadingList(ReadingList readingList) async {
    // Add to local cache
    _localCache[readingList.id] = readingList;

    // Sync to remote if available
    try {
      if (await canSync()) {
        await _remoteDatasource.createReadingList(readingList);
      }
    } catch (e) {
      // Keep in local cache, will sync later
    }
  }

  @override
  Future<void> updateReadingList(ReadingList readingList) async {
    // Update local cache
    _localCache[readingList.id] = readingList;

    // Sync to remote if available
    try {
      if (await canSync()) {
        await _remoteDatasource.updateReadingList(readingList);
      }
    } catch (e) {
      // Keep in local cache, will sync later
    }
  }

  @override
  Future<void> deleteReadingList(String listId) async {
    // Remove from local cache
    _localCache.remove(listId);

    // Delete from remote if available
    try {
      if (await canSync()) {
        await _remoteDatasource.deleteReadingList(listId);
      }
    } catch (e) {
      // Already removed from local cache
    }
  }

  @override
  Future<void> addAudiobookToList(String listId, String audiobookId) async {
    // Update local cache
    final list = _localCache[listId];
    if (list != null) {
      _localCache[listId] = list.withAddedAudiobook(audiobookId);
    }

    // Sync to remote if available
    try {
      if (await canSync()) {
        await _remoteDatasource.addAudiobookToList(listId, audiobookId);
      }
    } catch (e) {
      // Keep in local cache, will sync later
    }
  }

  @override
  Future<void> removeAudiobookFromList(String listId, String audiobookId) async {
    // Update local cache
    final list = _localCache[listId];
    if (list != null) {
      _localCache[listId] = list.withRemovedAudiobook(audiobookId);
    }

    // Sync to remote if available
    try {
      if (await canSync()) {
        await _remoteDatasource.removeAudiobookFromList(listId, audiobookId);
      }
    } catch (e) {
      // Keep in local cache, will sync later
    }
  }

  @override
  Future<List<ReadingList>> getAllRemoteReadingLists() async {
    try {
      return await _remoteDatasource.getReadingLists();
    } catch (e) {
      throw DatabaseException('Failed to get remote reading lists: $e');
    }
  }

  @override
  Future<bool> canSync() async {
    try {
      return await _remoteDatasource.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return _lastSyncTime;
  }
}
