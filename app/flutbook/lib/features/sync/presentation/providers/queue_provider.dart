/// Offline queue provider for state management.
///
/// Provides state management for offline queue operations including:
/// - View pending operations
/// - Process queue
/// - Clear queue items
/// - Retry failed items
library;

import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/sync/domain/repositories/offline_queue_repository.dart';
import 'package:flutbook/features/sync/domain/usecases/offline_queue_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Queue state.
class QueueState {
  const QueueState({
    this.pendingItems = const [],
    this.syncedCount = 0,
    this.failedCount = 0,
    this.isProcessing = false,
    this.errorMessage,
    this.lastProcessedTime,
  });

  final List<QueueItem> pendingItems;
  final int syncedCount;
  final int failedCount;
  final bool isProcessing;
  final String? errorMessage;
  final DateTime? lastProcessedTime;

  int get totalCount => pendingItems.length + syncedCount + failedCount;
  bool get hasPendingItems => pendingItems.isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  QueueState copyWith({
    List<QueueItem>? pendingItems,
    int? syncedCount,
    int? failedCount,
    bool? isProcessing,
    String? errorMessage,
    DateTime? lastProcessedTime,
  }) {
    return QueueState(
      pendingItems: pendingItems ?? this.pendingItems,
      syncedCount: syncedCount ?? this.syncedCount,
      failedCount: failedCount ?? this.failedCount,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      lastProcessedTime: lastProcessedTime ?? this.lastProcessedTime,
    );
  }
}

/// Notifier for managing queue state.
class QueueNotifier extends Notifier<QueueState> {
  /// Create a new QueueNotifier.
  QueueNotifier();

  @override
  QueueState build() {
    return const QueueState();
  }

  /// Get the enqueue item use case.
  EnqueueItemUseCase get _enqueueUseCase {
    return ref.read(enqueueItemUseCaseProvider);
  }

  /// Get the get pending items use case.
  GetPendingItemsUseCase get _getPendingItemsUseCase {
    return ref.read(getPendingItemsUseCaseProvider);
  }

  /// Get the process queue use case.
  ProcessQueueUseCase get _processQueueUseCase {
    return ref.read(processQueueUseCaseProvider);
  }

  /// Get the queue statistics use case.
  GetQueueStatisticsUseCase get _getStatisticsUseCase {
    return ref.read(getQueueStatisticsUseCaseProvider);
  }

  /// Get the clear queue use case.
  ClearQueueUseCase get _clearQueueUseCase {
    return ref.read(clearQueueUseCaseProvider);
  }

  /// Get the retry failed items use case.
  RetryFailedItemsUseCase get _retryFailedItemsUseCase {
    return ref.read(retryFailedItemsUseCaseProvider);
  }

  /// Load pending queue items.
  Future<void> loadPendingItems() async {
    try {
      final items = await _getPendingItemsUseCase.execute();
      final stats = await _getStatisticsUseCase.execute();

      state = state.copyWith(
        pendingItems: items,
        syncedCount: stats[QueueItemStatus.synced] ?? 0,
        failedCount: stats[QueueItemStatus.failed] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load queue items: $e',
      );
    }
  }

  /// Add an item to the queue.
  Future<QueueItem> enqueue({
    required QueueOperationType operationType,
    required String tableName,
    required String recordId,
    required Map<String, dynamic> data,
    int priority = 0,
  }) async {
    try {
      final item = await _enqueueUseCase.execute(
        operationType: operationType,
        tableName: tableName,
        recordId: recordId,
        data: data,
        priority: priority,
      );
      await loadPendingItems();
      return item;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to enqueue item: $e',
      );
      rethrow;
    }
  }

  /// Process the queue.
  Future<int> processQueue() async {
    state = state.copyWith(isProcessing: true);

    try {
      final count = await _processQueueUseCase.execute();
      await loadPendingItems();

      state = state.copyWith(
        isProcessing: false,
        lastProcessedTime: DateTime.now(),
      );

      return count;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to process queue: $e',
      );

      return 0;
    }
  }

  /// Clear synced items.
  Future<void> clearSynced() async {
    try {
      await _clearQueueUseCase.clearSynced();
      await loadPendingItems();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to clear synced items: $e',
      );
    }
  }

  /// Clear failed items.
  Future<void> clearFailed() async {
    try {
      await _clearQueueUseCase.clearFailed();
      await loadPendingItems();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to clear failed items: $e',
      );
    }
  }

  /// Clear all items.
  Future<void> clearAll() async {
    try {
      await _clearQueueUseCase.clearAll();
      await loadPendingItems();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to clear queue: $e',
      );
    }
  }

  /// Retry failed items.
  Future<int> retryFailed() async {
    try {
      final count = await _retryFailedItemsUseCase.execute();
      await loadPendingItems();
      return count;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to retry failed items: $e',
      );
      return 0;
    }
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith();
  }
}

/// Provider for queue state management.
final queueProvider = NotifierProvider<QueueNotifier, QueueState>(
  QueueNotifier.new,
);

// =============================================================================
// USE CASE PROVIDERS
// =============================================================================

/// Provides EnqueueItemUseCase.
final enqueueItemUseCaseProvider = Provider<EnqueueItemUseCase>((ref) {
  final repoAsync = ref.read(offlineQueueRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Offline queue repository not initialized');
  }
  return EnqueueItemUseCase(repository: repo);
});

/// Provides GetPendingItemsUseCase.
final getPendingItemsUseCaseProvider = Provider<GetPendingItemsUseCase>((ref) {
  final repoAsync = ref.read(offlineQueueRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Offline queue repository not initialized');
  }
  return GetPendingItemsUseCase(repository: repo);
});

/// Provides ProcessQueueUseCase.
final processQueueUseCaseProvider = Provider<ProcessQueueUseCase>((ref) {
  final repoAsync = ref.read(offlineQueueRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Offline queue repository not initialized');
  }
  return ProcessQueueUseCase(repository: repo);
});

/// Provides GetQueueStatisticsUseCase.
final getQueueStatisticsUseCaseProvider = Provider<GetQueueStatisticsUseCase>((ref) {
  final repoAsync = ref.read(offlineQueueRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Offline queue repository not initialized');
  }
  return GetQueueStatisticsUseCase(repository: repo);
});

/// Provides ClearQueueUseCase.
final clearQueueUseCaseProvider = Provider<ClearQueueUseCase>((ref) {
  final repoAsync = ref.read(offlineQueueRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Offline queue repository not initialized');
  }
  return ClearQueueUseCase(repository: repo);
});

/// Provides RetryFailedItemsUseCase.
final retryFailedItemsUseCaseProvider = Provider<RetryFailedItemsUseCase>((ref) {
  final repoAsync = ref.read(offlineQueueRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    throw Exception('Offline queue repository not initialized');
  }
  return RetryFailedItemsUseCase(repository: repo);
});
