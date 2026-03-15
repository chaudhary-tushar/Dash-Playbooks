// lib/features/player/data/repositories/queue_repository_impl.dart
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/datasources/queue_local_ds.dart';
import 'package:flutbook/features/player/data/models/queue_model.dart';
import 'package:flutbook/features/player/domain/entities/queue.dart';
import 'package:flutbook/features/player/domain/repositories/queue_repository.dart';

class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl({required QueueLocalDatasource localDatasource})
    : _localDatasource = localDatasource {
    validateDependencies();
  }

  final QueueLocalDatasource _localDatasource;
  bool _isInitialized = false;

  /// Initialize the repository and validate dependencies
  void validateDependencies() {
    if (!_localDatasource.isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Local datasource not initialized',
      );
    }
    _isInitialized = true;
  }

  /// Checks if the repository is ready for use
  bool get isInitialized => _isInitialized;

  @override
  Future<Queue> createQueue({
    required String name,
    List<String> audiobookIds = const [],
    bool isDefault = false,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate name
    if (name.isEmpty) {
      throw ArgumentError('name cannot be an empty string');
    }

    try {
      final queueModel = QueueModel()
        ..name = name
        ..audiobookIds = audiobookIds
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDefault = isDefault
        ..currentIndex = 0;

      final createdModel = await _localDatasource.createQueue(queueModel);
      return createdModel.toDomain();
    } catch (e) {
      throw Exception('Failed to create queue: $e');
    }
  }

  @override
  Future<List<Queue>> getAllQueues() async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      final queueModels = await _localDatasource.getAllQueues();
      return queueModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get all queues: $e');
    }
  }

  @override
  Future<Queue?> getQueueById(int queueId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      final queueModel = await _localDatasource.getQueueById(queueId);
      return queueModel?.toDomain();
    } catch (e) {
      throw Exception('Failed to get queue by ID: $e');
    }
  }

  @override
  Future<Queue?> getDefaultQueue() async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      final queueModel = await _localDatasource.getDefaultQueue();
      return queueModel?.toDomain();
    } catch (e) {
      throw Exception('Failed to get default queue: $e');
    }
  }

  @override
  Future<bool> deleteQueue(int queueId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      return await _localDatasource.deleteQueue(queueId);
    } catch (e) {
      throw Exception('Failed to delete queue: $e');
    }
  }

  @override
  Future<Queue> updateQueue({
    required int queueId,
    String? name,
    List<String>? audiobookIds,
    bool? isDefault,
    int? currentIndex,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      // First, get the existing queue
      final existingQueue = await _localDatasource.getQueueById(queueId);
      if (existingQueue == null) {
        throw Exception('Queue not found');
      }

      // Update the fields
      if (name != null) {
        // Validate name
        if (name.isEmpty) {
          throw ArgumentError('name cannot be an empty string');
        }
        existingQueue.name = name;
      }
      if (audiobookIds != null) {
        existingQueue.audiobookIds = audiobookIds;
      }
      if (isDefault != null) {
        existingQueue.isDefault = isDefault;
      }
      if (currentIndex != null) {
        existingQueue.currentIndex = currentIndex;
      }
      existingQueue.updatedAt = DateTime.now();

      final updatedModel = await _localDatasource.updateQueue(existingQueue);
      return updatedModel.toDomain();
    } catch (e) {
      throw Exception('Failed to update queue: $e');
    }
  }

  @override
  Future<void> setDefaultQueue(int queueId) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      await _localDatasource.setDefaultQueue(queueId);
    } catch (e) {
      throw Exception('Failed to set default queue: $e');
    }
  }

  @override
  Future<void> addAudiobookToQueue({
    required int queueId,
    required String audiobookId,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate audiobookId
    if (audiobookId.isEmpty) {
      throw ArgumentError('audiobookId cannot be an empty string');
    }

    try {
      await _localDatasource.addAudiobookToQueue(queueId, audiobookId);
    } catch (e) {
      throw Exception('Failed to add audiobook to queue: $e');
    }
  }

  @override
  Future<void> removeAudiobookFromQueue({
    required int queueId,
    required String audiobookId,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    // Validate audiobookId
    if (audiobookId.isEmpty) {
      throw ArgumentError('audiobookId cannot be an empty string');
    }

    try {
      await _localDatasource.removeAudiobookFromQueue(queueId, audiobookId);
    } catch (e) {
      throw Exception('Failed to remove audiobook from queue: $e');
    }
  }

  @override
  Future<void> updateQueueIndex({
    required int queueId,
    required int currentIndex,
  }) async {
    if (!isInitialized) {
      throw UninitializedDatasourceException(
        'QueueRepository: Cannot perform operations - repository not initialized',
      );
    }

    try {
      await _localDatasource.updateQueueIndex(queueId, currentIndex);
    } catch (e) {
      throw Exception('Failed to update queue index: $e');
    }
  }
}
