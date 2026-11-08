/// Offline queue local datasource for storing pending sync operations.
///
/// Persists queue items to the Isar database via [QueueItemModel] so pending
/// operations survive app restarts. This replaces the original in-memory
/// implementation that lost the queue whenever the app was killed.
library;

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/sync/data/models/queue_item_model.dart';
import 'package:flutbook/features/sync/domain/repositories/offline_queue_repository.dart';
import 'package:isar_community/isar.dart';

// Re-export types from repository for convenience
export 'package:flutbook/features/sync/domain/repositories/offline_queue_repository.dart'
    show QueueItem, QueueItemStatus, QueueOperationType;

/// Offline queue local datasource.
///
/// Stores queued sync operations in the Isar database so that work is not
/// lost when the app process is terminated while offline.
class OfflineQueueLocalDatasource {
  /// Create a new OfflineQueueLocalDatasource backed by [isar].
  OfflineQueueLocalDatasource(this._isar) {
    if (!_isar.isOpen) {
      throw UninitializedDatasourceException('Isar database is not open');
    }
  }

  final Isar _isar;

  /// Add an item to the queue.
  Future<QueueItem> enqueue(QueueItem item) async {
    await _isar.writeTxn(() async {
      await _isar.queueItemModels.put(QueueItemModel.fromDomain(item));
    });
    return item;
  }

  /// Get all pending items.
  Future<List<QueueItem>> getPendingItems() async {
    final models = await _isar.queueItemModels
        .filter()
        .statusEqualTo(QueueItemStatus.pending.toString())
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  /// Get a specific item by ID.
  Future<QueueItem?> getItem(String itemId) async {
    final model = await _isar.queueItemModels
        .filter()
        .internalIdEqualTo(itemId)
        .findFirst();
    return model?.toDomain();
  }

  /// Update an item.
  Future<void> updateItem(QueueItem item) async {
    final existing = await _isar.queueItemModels
        .filter()
        .internalIdEqualTo(item.id)
        .findFirst();
    if (existing == null) return;

    final model = QueueItemModel.fromDomain(item);
    model.id = existing.id;
    await _isar.writeTxn(() async {
      await _isar.queueItemModels.put(model);
    });
  }

  /// Remove an item.
  Future<void> removeItem(String itemId) async {
    await _isar.writeTxn(() async {
      await _isar.queueItemModels
          .filter()
          .internalIdEqualTo(itemId)
          .deleteFirst();
    });
  }

  /// Remove multiple items.
  Future<void> removeItems(List<String> itemIds) async {
    await _isar.writeTxn(() async {
      for (final itemId in itemIds) {
        await _isar.queueItemModels
            .filter()
            .internalIdEqualTo(itemId)
            .deleteFirst();
      }
    });
  }

  /// Clear synced items.
  Future<void> clearSyncedItems() async {
    await _isar.writeTxn(() async {
      await _isar.queueItemModels
          .filter()
          .statusEqualTo(QueueItemStatus.synced.toString())
          .deleteAll();
    });
  }

  /// Clear failed items.
  Future<void> clearFailedItems() async {
    await _isar.writeTxn(() async {
      await _isar.queueItemModels
          .filter()
          .statusEqualTo(QueueItemStatus.failed.toString())
          .deleteAll();
    });
  }

  /// Clear all items.
  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.queueItemModels.clear();
    });
  }

  /// Get count of pending items.
  Future<int> getPendingCount() async {
    return _isar.queueItemModels
        .filter()
        .statusEqualTo(QueueItemStatus.pending.toString())
        .count();
  }

  /// Get queue statistics.
  Future<Map<String, int>> getStatistics() async {
    final all = await _isar.queueItemModels.where().findAll();
    return {
      'pending': all
          .where((m) => _statusOf(m) == QueueItemStatus.pending)
          .length,
      'synced': all.where((m) => _statusOf(m) == QueueItemStatus.synced).length,
      'failed': all.where((m) => _statusOf(m) == QueueItemStatus.failed).length,
    };
  }

  /// Check if there are pending items.
  Future<bool> hasPendingItems() async {
    return _isar.queueItemModels
        .filter()
        .statusEqualTo(QueueItemStatus.pending.toString())
        .count()
        .then((c) => c > 0);
  }

  /// Get pending items for a specific table.
  Future<List<QueueItem>> getPendingItemsForTable(String tableName) async {
    final models = await _isar.queueItemModels
        .filter()
        .tableNameEqualTo(tableName)
        .statusEqualTo(QueueItemStatus.pending.toString())
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  QueueItemStatus _statusOf(QueueItemModel model) {
    try {
      final name = model.status.split('.').last;
      return QueueItemStatus.values
          .firstWhere((e) => e.toString().endsWith('.$name'));
    } catch (_) {
      return QueueItemStatus.pending;
    }
  }
}
