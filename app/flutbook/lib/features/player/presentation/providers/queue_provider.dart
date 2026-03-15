// lib/features/player/presentation/providers/queue_provider.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/core/provider/providers.dart'
    show manageQueueUsecaseProvider, queueRepositoryProvider;
import 'package:flutbook/features/player/domain/entities/queue.dart';
import 'package:flutbook/features/player/domain/repositories/queue_repository.dart';
import 'package:flutbook/features/player/domain/usecases/manage_queue_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class representing the current queue state.
class QueueState {
  const QueueState({
    required this.queues,
    required this.currentQueue,
    required this.isLoading,
    this.errorMessage,
  });

  /// Creates an initial queue state with default values.
  factory QueueState.initial() {
    return const QueueState(
      queues: [],
      currentQueue: null,
      isLoading: false,
    );
  }

  final List<Queue> queues;
  final Queue? currentQueue;
  final bool isLoading;
  final String? errorMessage;

  QueueState copyWith({
    List<Queue>? queues,
    Queue? currentQueue,
    bool? isLoading,
    String? errorMessage,
  }) {
    return QueueState(
      queues: queues ?? this.queues,
      currentQueue: currentQueue ?? this.currentQueue,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Main queue provider that manages the state and logic for queue operations.
final queueProvider = NotifierProvider<QueueNotifier, QueueState>(
  QueueNotifier.new,
);

/// Notifier class that manages the queue state and business logic.
class QueueNotifier extends Notifier<QueueState> {
  // Dependencies
  late ManageQueueUsecase _manageQueueUsecase;
  late QueueRepository _queueRepository;

  @override
  QueueState build() {
    try {
      // Initialize use cases directly from providers
      _manageQueueUsecase = ref.read(manageQueueUsecaseProvider);
      final queueRepoAsync = ref.read(queueRepositoryProvider);
      _queueRepository =
          queueRepoAsync.value ??
          (throw UninitializedDatasourceException(
            'Queue repository not initialized',
          ));

      return QueueState.initial();
    } catch (e) {
      // Handle initialization errors
      return QueueState(
        queues: [],
        currentQueue: null,
        isLoading: false,
        errorMessage: ErrorHandler.handlePlaybackException(e),
      );
    }
  }

  /// Load all queues
  Future<void> loadQueues() async {
    state = state.copyWith(isLoading: true);

    try {
      final queues = await _manageQueueUsecase.getAllQueues();
      state = state.copyWith(
        queues: queues,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load queues: $e',
      );
    }
  }

  /// Create a new queue
  Future<void> createQueue({
    required String name,
    List<String> audiobookIds = const [],
    bool isDefault = false,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final queue = await _manageQueueUsecase.createQueue(
        name: name,
        audiobookIds: audiobookIds,
        isDefault: isDefault,
      );

      // Add the new queue to the list
      final updatedQueues = [...state.queues, queue];
      state = state.copyWith(
        queues: updatedQueues,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create queue: $e',
      );
    }
  }

  /// Delete a queue
  Future<void> deleteQueue(int queueId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _manageQueueUsecase.deleteQueue(queueId);

      // Remove the queue from the list
      final updatedQueues = state.queues.where((queue) => queue.id != queueId).toList();

      // If the deleted queue was the current queue, clear it
      Queue? updatedCurrentQueue = state.currentQueue;
      if (state.currentQueue?.id == queueId) {
        updatedCurrentQueue = null;
      }

      state = state.copyWith(
        queues: updatedQueues,
        currentQueue: updatedCurrentQueue,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete queue: $e',
      );
    }
  }

  /// Set the current queue
  Future<void> setCurrentQueue(int queueId) async {
    state = state.copyWith(isLoading: true);

    try {
      final queue = await _manageQueueUsecase.getQueueById(queueId);
      state = state.copyWith(
        currentQueue: queue,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to set current queue: $e',
      );
    }
  }

  /// Add an audiobook to a queue
  Future<void> addAudiobookToQueue({
    required int queueId,
    required String audiobookId,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _manageQueueUsecase.addAudiobookToQueue(
        queueId: queueId,
        audiobookId: audiobookId,
      );

      // Reload the queue to get updated data
      final updatedQueue = await _manageQueueUsecase.getQueueById(queueId);
      if (updatedQueue != null) {
        final updatedQueues = state.queues.map((queue) {
          return queue.id == queueId ? updatedQueue : queue;
        }).toList();

        Queue? updatedCurrentQueue = state.currentQueue;
        if (state.currentQueue?.id == queueId) {
          updatedCurrentQueue = updatedQueue;
        }

        state = state.copyWith(
          queues: updatedQueues,
          currentQueue: updatedCurrentQueue,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add audiobook to queue: $e',
      );
    }
  }

  /// Remove an audiobook from a queue
  Future<void> removeAudiobookFromQueue({
    required int queueId,
    required String audiobookId,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _manageQueueUsecase.removeAudiobookFromQueue(
        queueId: queueId,
        audiobookId: audiobookId,
      );

      // Reload the queue to get updated data
      final updatedQueue = await _manageQueueUsecase.getQueueById(queueId);
      if (updatedQueue != null) {
        final updatedQueues = state.queues.map((queue) {
          return queue.id == queueId ? updatedQueue : queue;
        }).toList();

        Queue? updatedCurrentQueue = state.currentQueue;
        if (state.currentQueue?.id == queueId) {
          updatedCurrentQueue = updatedQueue;
        }

        state = state.copyWith(
          queues: updatedQueues,
          currentQueue: updatedCurrentQueue,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to remove audiobook from queue: $e',
      );
    }
  }

  /// Update the current index in the current queue
  Future<void> updateQueueIndex(int currentIndex) async {
    if (state.currentQueue == null) return;

    try {
      await _manageQueueUsecase.updateQueueIndex(
        queueId: state.currentQueue!.id,
        currentIndex: currentIndex,
      );

      // Update the current queue in state
      final updatedQueue = state.currentQueue!.copyWith(
        currentIndex: currentIndex,
      );

      final updatedQueues = state.queues.map((queue) {
        return queue.id == updatedQueue.id ? updatedQueue : queue;
      }).toList();

      state = state.copyWith(
        queues: updatedQueues,
        currentQueue: updatedQueue,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update queue index: $e',
      );
    }
  }

  /// Clear any error message from the queue state.
  void clearError() {
    state = state.copyWith();
  }
}

/// Provider for all queues.
final queuesProvider = FutureProvider<List<Queue>>((ref) async {
  final queueRepoAsync = ref.watch(queueRepositoryProvider);
  return queueRepoAsync.when(
    loading: () => [],
    error: (error, stackTrace) => [],
    data: (repo) => repo.getAllQueues(),
  );
});
