// lib/features/player/data/datasources/queue_local_ds.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/models/queue_model.dart';
import 'package:isar_community/isar.dart';

class QueueLocalDatasource {
  QueueLocalDatasource(this._isar) {
    validateInitialization();
  }
  final Isar _isar;

  void validateInitialization() {
    if (!_isar.isOpen) {
      throw UninitializedDatasourceException('Isar database is not open');
    }
  }

  /// Checks if the datasource is initialized and ready for use
  bool get isInitialized => _isar.isOpen;

  /// Creates a new queue
  Future<QueueModel> createQueue(QueueModel queue) async {
    validateInitialization();

    return _isar.writeTxn(() async {
      // Set the ID to auto-increment (0 means let Isar assign it)
      queue.id = Isar.autoIncrement;
      await _isar.queueModels.put(queue);
      return queue;
    });
  }

  /// Gets all queues
  Future<List<QueueModel>> getAllQueues() async {
    validateInitialization();
    return _isar.queueModels.where().findAll();
  }

  /// Gets a specific queue by ID
  Future<QueueModel?> getQueueById(int queueId) async {
    validateInitialization();
    return _isar.queueModels.get(queueId);
  }

  /// Gets the default queue
  Future<QueueModel?> getDefaultQueue() async {
    validateInitialization();
    return _isar.queueModels.filter().isDefaultEqualTo(true).findFirst();
  }

  /// Deletes a specific queue
  Future<bool> deleteQueue(int queueId) async {
    validateInitialization();
    return _isar.writeTxn(() async {
      final result = await _isar.queueModels.delete(queueId);
      return result;
    });
  }

  /// Updates an existing queue
  Future<QueueModel> updateQueue(QueueModel queue) async {
    validateInitialization();

    return _isar.writeTxn(() async {
      await _isar.queueModels.put(queue);
      return queue;
    });
  }

  /// Sets a queue as the default queue
  Future<void> setDefaultQueue(int queueId) async {
    validateInitialization();

    await _isar.writeTxn(() async {
      // First, unset all queues as default
      final allQueues = await _isar.queueModels.where().findAll();
      for (final queue in allQueues) {
        queue.isDefault = false;
        await _isar.queueModels.put(queue);
      }

      // Then set the specified queue as default
      final queue = await _isar.queueModels.get(queueId);
      if (queue != null) {
        queue.isDefault = true;
        await _isar.queueModels.put(queue);
      }
    });
  }

  /// Adds an audiobook to a queue
  Future<void> addAudiobookToQueue(int queueId, String audiobookId) async {
    validateInitialization();

    await _isar.writeTxn(() async {
      final queue = await _isar.queueModels.get(queueId);
      if (queue != null) {
        if (!queue.audiobookIds.contains(audiobookId)) {
          queue.audiobookIds = [...queue.audiobookIds, audiobookId];
          await _isar.queueModels.put(queue);
        }
      }
    });
  }

  /// Removes an audiobook from a queue
  Future<void> removeAudiobookFromQueue(int queueId, String audiobookId) async {
    validateInitialization();

    await _isar.writeTxn(() async {
      final queue = await _isar.queueModels.get(queueId);
      if (queue != null) {
        queue.audiobookIds = queue.audiobookIds.where((id) => id != audiobookId).toList();
        await _isar.queueModels.put(queue);
      }
    });
  }

  /// Updates the current index in a queue
  Future<void> updateQueueIndex(int queueId, int currentIndex) async {
    validateInitialization();

    await _isar.writeTxn(() async {
      final queue = await _isar.queueModels.get(queueId);
      if (queue != null) {
        queue.currentIndex = currentIndex;
        await _isar.queueModels.put(queue);
      }
    });
  }
}
