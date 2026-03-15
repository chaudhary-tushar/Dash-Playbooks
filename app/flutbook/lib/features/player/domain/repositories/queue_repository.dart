// lib/features/player/domain/repositories/queue_repository.dart
import 'package:flutbook/features/player/domain/entities/queue.dart';

abstract class QueueRepository {
  /// Creates a new queue
  Future<Queue> createQueue({
    required String name,
    List<String> audiobookIds = const [],
    bool isDefault = false,
  });

  /// Gets all queues
  Future<List<Queue>> getAllQueues();

  /// Gets a specific queue by ID
  Future<Queue?> getQueueById(int queueId);

  /// Gets the default queue
  Future<Queue?> getDefaultQueue();

  /// Deletes a specific queue
  Future<bool> deleteQueue(int queueId);

  /// Updates an existing queue
  Future<Queue> updateQueue({
    required int queueId,
    String? name,
    List<String>? audiobookIds,
    bool? isDefault,
    int? currentIndex,
  });

  /// Sets a queue as the default queue
  Future<void> setDefaultQueue(int queueId);

  /// Adds an audiobook to a queue
  Future<void> addAudiobookToQueue({
    required int queueId,
    required String audiobookId,
  });

  /// Removes an audiobook from a queue
  Future<void> removeAudiobookFromQueue({
    required int queueId,
    required String audiobookId,
  });

  /// Updates the current index in a queue
  Future<void> updateQueueIndex({
    required int queueId,
    required int currentIndex,
  });
}
