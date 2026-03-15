/// Use cases for offline queue management.
///
/// Provides business logic for managing queued sync operations.
library;

import 'package:flutbook/features/sync/domain/repositories/offline_queue_repository.dart';

/// Use case for adding an item to the queue.
class EnqueueItemUseCase {
  /// Create a new EnqueueItemUseCase.
  const EnqueueItemUseCase({
    required OfflineQueueRepository repository,
  }) : _repository = repository;

  final OfflineQueueRepository _repository;

  /// Execute the use case.
  ///
  /// Adds an operation to the queue.
  ///
  /// [operationType] - Type of operation
  /// [tableName] - Name of the table/entity
  /// [recordId] - ID of the record
  /// [data] - Operation data
  /// [priority] - Optional priority
  Future<QueueItem> execute({
    required QueueOperationType operationType,
    required String tableName,
    required String recordId,
    required Map<String, dynamic> data,
    int priority = 0,
  }) async {
    return _repository.enqueue(
      operationType: operationType,
      tableName: tableName,
      recordId: recordId,
      data: data,
      priority: priority,
    );
  }
}

/// Use case for getting pending queue items.
class GetPendingItemsUseCase {
  /// Create a new GetPendingItemsUseCase.
  const GetPendingItemsUseCase({
    required OfflineQueueRepository repository,
  }) : _repository = repository;

  final OfflineQueueRepository _repository;

  /// Execute the use case.
  ///
  /// Returns all pending queue items.
  Future<List<QueueItem>> execute() async {
    return _repository.getPendingItems();
  }
}

/// Use case for processing queue items.
class ProcessQueueUseCase {
  /// Create a new ProcessQueueUseCase.
  const ProcessQueueUseCase({
    required OfflineQueueRepository repository,
  }) : _repository = repository;

  final OfflineQueueRepository _repository;

  /// Execute the use case.
  ///
  /// Processes all pending queue items.
  /// Returns the number of items processed.
  Future<int> execute() async {
    final pendingItems = await _repository.getPendingItems();
    
    for (final item in pendingItems) {
      // Mark as syncing
      await _repository.updateItem(item.markAsSyncing());
      
      // Note: Actual sync logic would be implemented in the repository
      // This use case just orchestrates the process
      
      // After successful sync, item would be marked as synced
      // After failed sync, item would be marked as failed with retry
    }
    
    return pendingItems.length;
  }
}

/// Use case for getting queue statistics.
class GetQueueStatisticsUseCase {
  /// Create a new GetQueueStatisticsUseCase.
  const GetQueueStatisticsUseCase({
    required OfflineQueueRepository repository,
  }) : _repository = repository;

  final OfflineQueueRepository _repository;

  /// Execute the use case.
  ///
  /// Returns queue statistics.
  Future<Map<QueueItemStatus, int>> execute() async {
    return _repository.getStatistics();
  }

  /// Get pending count.
  Future<int> getPendingCount() async {
    return _repository.getPendingCount();
  }

  /// Check if there are pending items.
  Future<bool> hasPendingItems() async {
    return _repository.hasPendingItems();
  }
}

/// Use case for clearing queue items.
class ClearQueueUseCase {
  /// Create a new ClearQueueUseCase.
  const ClearQueueUseCase({
    required OfflineQueueRepository repository,
  }) : _repository = repository;

  final OfflineQueueRepository _repository;

  /// Clear synced items.
  Future<void> clearSynced() async {
    await _repository.clearSyncedItems();
  }

  /// Clear failed items.
  Future<void> clearFailed() async {
    await _repository.clearFailedItems();
  }

  /// Clear all items.
  Future<void> clearAll() async {
    await _repository.clearAll();
  }
}

/// Use case for retrying failed items.
class RetryFailedItemsUseCase {
  /// Create a new RetryFailedItemsUseCase.
  const RetryFailedItemsUseCase({
    required OfflineQueueRepository repository,
  }) : _repository = repository;

  final OfflineQueueRepository _repository;

  /// Execute the use case.
  ///
  /// Retries all failed items that can be retried.
  /// Returns the number of items retried.
  Future<int> execute() async {
    final pendingItems = await _repository.getPendingItems();
    int retriedCount = 0;
    
    for (final item in pendingItems) {
      if (item.canRetry) {
        await _repository.updateItem(
          item.copyWith(status: QueueItemStatus.pending, retryCount: item.retryCount),
        );
        retriedCount++;
      }
    }
    
    return retriedCount;
  }
}
