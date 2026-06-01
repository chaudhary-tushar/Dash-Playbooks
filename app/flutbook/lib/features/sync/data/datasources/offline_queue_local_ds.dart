/// Offline queue local datasource for storing pending sync operations.
///
/// This is a temporary in-memory implementation until Isar code generation
/// is properly configured. It maintains queue items in memory during app runtime.
library;

import 'package:flutbook/features/sync/domain/repositories/offline_queue_repository.dart';

// Re-export types from repository for convenience
export 'package:flutbook/features/sync/domain/repositories/offline_queue_repository.dart'
    show QueueItem, QueueItemStatus, QueueOperationType;

/// In-memory queue item storage with persistence placeholder.
///
/// This class stores queue items in memory and provides methods to manage them.
/// Future implementation will persist to Isar database.
class QueueItemMemory {
  /// Create queue item memory.
  QueueItemMemory({required this.item});

  /// The queue item
  final QueueItem item;

  /// In-memory ID (for deletion operations)
  String get id => item.id;
}

/// Offline queue local datasource.
///
/// Provides storage for queued sync operations using an in-memory implementation.
/// Future implementation will use Isar for persistent storage.
class OfflineQueueLocalDatasource {
  /// Create a new OfflineQueueLocalDatasource.
  ///
  /// [isar] - The Isar database instance (placeholder for future use)
  OfflineQueueLocalDatasource() : _queue = [];

  final List<QueueItemMemory> _queue;

  /// Add an item to the queue.
  Future<QueueItem> enqueue(QueueItem item) async {
    _queue.add(QueueItemMemory(item: item));
    return item;
  }

  /// Get all pending items.
  Future<List<QueueItem>> getPendingItems() async {
    return _queue
        .where((m) => m.item.status == QueueItemStatus.pending)
        .map((m) => m.item)
        .toList();
  }

  /// Get a specific item by ID.
  Future<QueueItem?> getItem(String itemId) async {
    try {
      return _queue.firstWhere((m) => m.item.id == itemId).item;
    } catch (_) {
      return null;
    }
  }

  /// Update an item.
  Future<void> updateItem(QueueItem item) async {
    final index = _queue.indexWhere((m) => m.item.id == item.id);
    if (index >= 0) {
      _queue[index] = QueueItemMemory(item: item);
    }
  }

  /// Remove an item.
  Future<void> removeItem(String itemId) async {
    _queue.removeWhere((m) => m.item.id == itemId);
  }

  /// Remove multiple items.
  Future<void> removeItems(List<String> itemIds) async {
    for (final itemId in itemIds) {
      _queue.removeWhere((m) => m.item.id == itemId);
    }
  }

  /// Clear synced items.
  Future<void> clearSyncedItems() async {
    _queue.removeWhere((m) => m.item.status == QueueItemStatus.synced);
  }

  /// Clear failed items.
  Future<void> clearFailedItems() async {
    _queue.removeWhere((m) => m.item.status == QueueItemStatus.failed);
  }

  /// Clear all items.
  Future<void> clearAll() async {
    _queue.clear();
  }

  /// Get count of pending items.
  Future<int> getPendingCount() async {
    return _queue.where((m) => m.item.status == QueueItemStatus.pending).length;
  }

  /// Get queue statistics.
  Future<Map<String, int>> getStatistics() async {
    return {
      'pending': _queue.where((m) => m.item.status == QueueItemStatus.pending).length,
      'synced': _queue.where((m) => m.item.status == QueueItemStatus.synced).length,
      'failed': _queue.where((m) => m.item.status == QueueItemStatus.failed).length,
    };
  }

  /// Check if there are pending items.
  Future<bool> hasPendingItems() async {
    return _queue.any((m) => m.item.status == QueueItemStatus.pending);
  }

  /// Get pending items for a specific table.
  Future<List<QueueItem>> getPendingItemsForTable(String tableName) async {
    return _queue
        .where((m) => m.item.tableName == tableName && m.item.status == QueueItemStatus.pending)
        .map((m) => m.item)
        .toList();
  }
}
