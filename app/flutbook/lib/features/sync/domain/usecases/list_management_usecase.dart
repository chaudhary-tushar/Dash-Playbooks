/// Use cases for reading list management.
///
/// Provides business logic for creating, updating, deleting,
/// and managing reading lists.
library;

import 'package:flutbook/features/sync/domain/entities/reading_list.dart';
import 'package:flutbook/features/sync/domain/repositories/reading_list_sync_repository.dart';
import 'package:uuid/uuid.dart';

/// Use case for getting all reading lists.
class GetReadingListsUseCase {
  /// Create a new GetReadingListsUseCase.
  const GetReadingListsUseCase({
    required ReadingListSyncRepository repository,
  }) : _repository = repository;

  final ReadingListSyncRepository _repository;

  /// Execute the use case.
  ///
  /// Returns all reading lists for the current user.
  Future<List<ReadingList>> execute() async {
    return _repository.getAllReadingLists();
  }
}

/// Use case for creating a new reading list.
class CreateReadingListUseCase {
  /// Create a new CreateReadingListUseCase.
  const CreateReadingListUseCase({
    required ReadingListSyncRepository repository,
  }) : _repository = repository;

  final ReadingListSyncRepository _repository;

  /// Execute the use case.
  ///
  /// [name] - The name of the reading list
  /// [description] - Optional description
  /// [audiobookIds] - Optional initial audiobook IDs
  ///
  /// Returns the created reading list.
  Future<ReadingList> execute({
    required String name,
    String? description,
    List<String> audiobookIds = const [],
  }) async {
    final readingList = ReadingList(
      id: const Uuid().v4(),
      name: name,
      description: description,
      audiobookIds: audiobookIds,
      createdAt: DateTime.now(),
    );

    await _repository.createReadingList(readingList);
    return readingList;
  }
}

/// Use case for updating a reading list.
class UpdateReadingListUseCase {
  /// Create a new UpdateReadingListUseCase.
  const UpdateReadingListUseCase({
    required ReadingListSyncRepository repository,
  }) : _repository = repository;

  final ReadingListSyncRepository _repository;

  /// Execute the use case.
  ///
  /// [readingList] - The updated reading list
  Future<void> execute(ReadingList readingList) async {
    await _repository.updateReadingList(
      readingList.copyWith(updatedAt: DateTime.now()),
    );
  }
}

/// Use case for deleting a reading list.
class DeleteReadingListUseCase {
  /// Create a new DeleteReadingListUseCase.
  const DeleteReadingListUseCase({
    required ReadingListSyncRepository repository,
  }) : _repository = repository;

  final ReadingListSyncRepository _repository;

  /// Execute the use case.
  ///
  /// [listId] - The ID of the reading list to delete
  Future<void> execute(String listId) async {
    await _repository.deleteReadingList(listId);
  }
}

/// Use case for adding an audiobook to a reading list.
class AddAudiobookToListUseCase {
  /// Create a new AddAudiobookToListUseCase.
  const AddAudiobookToListUseCase({
    required ReadingListSyncRepository repository,
  }) : _repository = repository;

  final ReadingListSyncRepository _repository;

  /// Execute the use case.
  ///
  /// [listId] - The ID of the reading list
  /// [audiobookId] - The ID of the audiobook to add
  Future<void> execute(String listId, String audiobookId) async {
    await _repository.addAudiobookToList(listId, audiobookId);
  }
}

/// Use case for removing an audiobook from a reading list.
class RemoveAudiobookFromListUseCase {
  /// Create a new RemoveAudiobookFromListUseCase.
  const RemoveAudiobookFromListUseCase({
    required ReadingListSyncRepository repository,
  }) : _repository = repository;

  final ReadingListSyncRepository _repository;

  /// Execute the use case.
  ///
  /// [listId] - The ID of the reading list
  /// [audiobookId] - The ID of the audiobook to remove
  Future<void> execute(String listId, String audiobookId) async {
    await _repository.removeAudiobookFromList(listId, audiobookId);
  }
}

/// Use case for syncing reading lists with remote.
class SyncReadingListsUseCase {
  /// Create a new SyncReadingListsUseCase.
  const SyncReadingListsUseCase({
    required ReadingListSyncRepository repository,
  }) : _repository = repository;

  final ReadingListSyncRepository _repository;

  /// Execute the use case.
  ///
  /// Returns sync result with statistics.
  Future<ReadingListSyncResult> execute() async {
    final canSync = await _repository.canSync();
    if (!canSync) {
      return const ReadingListSyncResult(
        status: ReadingListSyncStatus.idle,
        errors: ['Cannot sync: User not authenticated or offline'],
      );
    }

    return _repository.syncReadingLists();
  }

  /// Check if sync is available.
  Future<bool> canSync() => _repository.canSync();

  /// Get last sync timestamp.
  Future<DateTime?> getLastSyncTime() => _repository.getLastSyncTime();
}
