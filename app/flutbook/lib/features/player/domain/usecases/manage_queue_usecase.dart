// lib/features/player/domain/usecases/manage_queue_usecase.dart
import 'package:flutbook/features/player/domain/entities/queue.dart';
import 'package:flutbook/features/player/domain/repositories/queue_repository.dart';

class ManageQueueUsecase {
  ManageQueueUsecase(this.repository);

  final QueueRepository repository;

  /// Creates a new queue
  Future<Queue> createQueue({
    required String name,
    List<String> audiobookIds = const [],
    bool isDefault = false,
  }) async {
    return repository.createQueue(
      name: name,
      audiobookIds: audiobookIds,
      isDefault: isDefault,
    );
  }

  /// Gets all queues
  Future<List<Queue>> getAllQueues() async {
    return repository.getAllQueues();
  }

  /// Gets a specific queue by ID
  Future<Queue?> getQueueById(int queueId) async {
    return repository.getQueueById(queueId);
  }

  /// Gets the default queue
  Future<Queue?> getDefaultQueue() async {
    return repository.getDefaultQueue();
  }

  /// Deletes a specific queue
  Future<bool> deleteQueue(int queueId) async {
    return repository.deleteQueue(queueId);
  }

  /// Updates an existing queue
  Future<Queue> updateQueue({
    required int queueId,
    String? name,
    List<String>? audiobookIds,
    bool? isDefault,
    int? currentIndex,
  }) async {
    return repository.updateQueue(
      queueId: queueId,
      name: name,
      audiobookIds: audiobookIds,
      isDefault: isDefault,
      currentIndex: currentIndex,
    );
  }

  /// Sets a queue as the default queue
  Future<void> setDefaultQueue(int queueId) async {
    await repository.setDefaultQueue(queueId);
  }

  /// Adds an audiobook to a queue
  Future<void> addAudiobookToQueue({
    required int queueId,
    required String audiobookId,
  }) async {
    await repository.addAudiobookToQueue(
      queueId: queueId,
      audiobookId: audiobookId,
    );
  }

  /// Removes an audiobook from a queue
  Future<void> removeAudiobookFromQueue({
    required int queueId,
    required String audiobookId,
  }) async {
    await repository.removeAudiobookFromQueue(
      queueId: queueId,
      audiobookId: audiobookId,
    );
  }

  /// Updates the current index in a queue
  Future<void> updateQueueIndex({
    required int queueId,
    required int currentIndex,
  }) async {
    await repository.updateQueueIndex(
      queueId: queueId,
      currentIndex: currentIndex,
    );
  }
}
