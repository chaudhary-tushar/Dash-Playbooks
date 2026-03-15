/// Offline queue repository interface.
///
/// Defines the contract for managing queued sync operations
/// that need to be executed when the device comes online.
library;

/// Queue operation types.
enum QueueOperationType {
  /// Create/insert operation
  create,

  /// Update operation
  update,

  /// Delete operation
  delete,
}

/// Queue item status.
enum QueueItemStatus {
  /// Item is pending sync
  pending,

  /// Item is currently being synced
  syncing,

  /// Item has been synced successfully
  synced,

  /// Item failed to sync
  failed,
}

/// Queue item entity.
class QueueItem {
  /// Create a new QueueItem.
  const QueueItem({
    required this.id,
    required this.operationType,
    required this.tableName,
    required this.recordId,
    required this.data,
    required this.createdAt,
    this.priority = 0,
    this.retryCount = 0,
    this.lastError,
    this.status = QueueItemStatus.pending,
  });

  /// Unique identifier for the queue item.
  final String id;

  /// Type of operation (create, update, delete).
  final QueueOperationType operationType;

  /// Name of the table/entity this operation affects.
  final String tableName;

  /// ID of the record being operated on.
  final String recordId;

  /// Data for the operation (JSON-serializable).
  final Map<String, dynamic> data;

  /// When the item was added to the queue.
  final DateTime createdAt;

  /// Priority of the operation (higher = more urgent).
  final int priority;

  /// Number of retry attempts.
  final int retryCount;

  /// Last error message if the operation failed.
  final String? lastError;

  /// Current status of the queue item.
  final QueueItemStatus status;

  /// Maximum retry attempts before giving up.
  static const int maxRetries = 3;

  /// Check if the item can be retried.
  bool get canRetry => retryCount < maxRetries && status == QueueItemStatus.failed;

  /// Check if the item is pending.
  bool get isPending => status == QueueItemStatus.pending;

  /// Create a copy with updated fields.
  QueueItem copyWith({
    String? id,
    QueueOperationType? operationType,
    String? tableName,
    String? recordId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? priority,
    int? retryCount,
    String? lastError,
    QueueItemStatus? status,
  }) {
    return QueueItem(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
    );
  }

  /// Mark the item as syncing.
  QueueItem markAsSyncing() {
    return copyWith(status: QueueItemStatus.syncing);
  }

  /// Mark the item as synced.
  QueueItem markAsSynced() {
    return copyWith(status: QueueItemStatus.synced);
  }

  /// Mark the item as failed.
  QueueItem markAsFailed(String error) {
    return copyWith(
      status: QueueItemStatus.failed,
      lastError: error,
      retryCount: retryCount + 1,
    );
  }
}

/// Repository interface for offline queue operations.
///
/// This interface defines the contract for managing queued sync
/// operations that need to be executed when the device comes online.
abstract class OfflineQueueRepository {
  /// Add an operation to the queue.
  ///
  /// [operationType] - Type of operation (create, update, delete)
  /// [tableName] - Name of the table/entity
  /// [recordId] - ID of the record
  /// [data] - Operation data
  /// [priority] - Optional priority (higher = more urgent)
  ///
  /// Returns the created [QueueItem].
  Future<QueueItem> enqueue({
    required QueueOperationType operationType,
    required String tableName,
    required String recordId,
    required Map<String, dynamic> data,
    int priority = 0,
  });

  /// Get all pending queue items.
  ///
  /// Returns items sorted by priority (descending) and createdAt (ascending).
  Future<List<QueueItem>> getPendingItems();

  /// Get a specific queue item by ID.
  ///
  /// [itemId] - The ID of the queue item
  Future<QueueItem?> getItem(String itemId);

  /// Update a queue item.
  ///
  /// [item] - The updated queue item
  Future<void> updateItem(QueueItem item);

  /// Remove a queue item from the queue.
  ///
  /// [itemId] - The ID of the queue item to remove
  Future<void> removeItem(String itemId);

  /// Remove multiple queue items.
  ///
  /// [itemIds] - List of queue item IDs to remove
  Future<void> removeItems(List<String> itemIds);

  /// Clear all synced items from the queue.
  ///
  /// Removes items with status [QueueItemStatus.synced].
  Future<void> clearSyncedItems();

  /// Clear all failed items from the queue.
  ///
  /// Removes items with status [QueueItemStatus.failed].
  Future<void> clearFailedItems();

  /// Clear the entire queue.
  ///
  /// Removes all items regardless of status.
  Future<void> clearAll();

  /// Get the count of pending items.
  ///
  /// Returns the number of items waiting to be synced.
  Future<int> getPendingCount();

  /// Get queue statistics.
  ///
  /// Returns a map with counts by status.
  Future<Map<QueueItemStatus, int>> getStatistics();

  /// Check if there are pending items.
  ///
  /// Returns true if there are items waiting to be synced.
  Future<bool> hasPendingItems();

  /// Get pending items for a specific table.
  ///
  /// [tableName] - Name of the table to filter by
  Future<List<QueueItem>> getPendingItemsForTable(String tableName);
}
