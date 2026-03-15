/// Implementation of offline queue repository.
///
/// Handles queue management with local in-memory storage.
library;

import 'package:flutbook/features/sync/data/datasources/offline_queue_local_ds.dart';
import 'package:flutbook/features/sync/domain/repositories/offline_queue_repository.dart';

/// Implementation of [OfflineQueueRepository].
///
/// Provides queue management with in-memory local storage.
class OfflineQueueRepositoryImpl implements OfflineQueueRepository {
  /// Create a new OfflineQueueRepositoryImpl.
  ///
  /// [localDatasource] - Local in-memory datasource
  OfflineQueueRepositoryImpl({
    required OfflineQueueLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final OfflineQueueLocalDatasource _localDatasource;

  @override
  Future<QueueItem> enqueue({
    required QueueOperationType operationType,
    required String tableName,
    required String recordId,
    required Map<String, dynamic> data,
    int priority = 0,
  }) async {
    final item = QueueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString() + recordId,
      operationType: operationType,
      tableName: tableName,
      recordId: recordId,
      data: data,
      createdAt: DateTime.now(),
      priority: priority,
    );

    return _localDatasource.enqueue(item);
  }

  @override
  Future<List<QueueItem>> getPendingItems() async {
    return _localDatasource.getPendingItems();
  }

  @override
  Future<QueueItem?> getItem(String itemId) async {
    return _localDatasource.getItem(itemId);
  }

  @override
  Future<void> updateItem(QueueItem item) async {
    await _localDatasource.updateItem(item);
  }

  @override
  Future<void> removeItem(String itemId) async {
    await _localDatasource.removeItem(itemId);
  }

  @override
  Future<void> removeItems(List<String> itemIds) async {
    await _localDatasource.removeItems(itemIds);
  }

  @override
  Future<void> clearSyncedItems() async {
    await _localDatasource.clearSyncedItems();
  }

  @override
  Future<void> clearFailedItems() async {
    await _localDatasource.clearFailedItems();
  }

  @override
  Future<void> clearAll() async {
    await _localDatasource.clearAll();
  }

  @override
  Future<int> getPendingCount() async {
    return _localDatasource.getPendingCount();
  }

  @override
  Future<Map<QueueItemStatus, int>> getStatistics() async {
    final stats = await _localDatasource.getStatistics();
    return {
      QueueItemStatus.pending: stats['pending'] ?? 0,
      QueueItemStatus.synced: stats['synced'] ?? 0,
      QueueItemStatus.failed: stats['failed'] ?? 0,
    };
  }

  @override
  Future<bool> hasPendingItems() async {
    return _localDatasource.hasPendingItems();
  }

  @override
  Future<List<QueueItem>> getPendingItemsForTable(String tableName) async {
    return _localDatasource.getPendingItemsForTable(tableName);
  }
}
