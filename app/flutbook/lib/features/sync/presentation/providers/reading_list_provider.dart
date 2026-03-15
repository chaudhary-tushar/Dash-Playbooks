/// Reading list provider for state management.
///
/// Provides state management for reading list operations including:
/// - List CRUD operations
/// - Add/remove audiobooks from lists
/// - Sync with remote
/// - List selection and management
library;

import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/sync/domain/entities/reading_list.dart';
import 'package:flutbook/features/sync/domain/repositories/reading_list_sync_repository.dart';
import 'package:flutbook/features/sync/domain/usecases/list_management_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reading list state.
class ReadingListState {
  const ReadingListState({
    this.lists = const [],
    this.selectedList,
    this.isLoading = false,
    this.errorMessage,
    this.lastSyncTime,
  });

  final List<ReadingList> lists;
  final ReadingList? selectedList;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  /// Get list by ID
  ReadingList? getListById(String id) {
    try {
      return lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if an audiobook is in any list
  bool isAudiobookInLists(String audiobookId) {
    return lists.any((list) => list.containsAudiobook(audiobookId));
  }

  /// Get lists containing an audiobook
  List<ReadingList> getListsContainingAudiobook(String audiobookId) {
    return lists.where((list) => list.containsAudiobook(audiobookId)).toList();
  }

  ReadingListState copyWith({
    List<ReadingList>? lists,
    ReadingList? selectedList,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastSyncTime,
  }) {
    return ReadingListState(
      lists: lists ?? this.lists,
      selectedList: selectedList ?? this.selectedList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Notifier for managing reading list state.
class ReadingListNotifier extends Notifier<ReadingListState> {
  /// Create a new ReadingListNotifier.
  ReadingListNotifier();
  late ReadingListSyncRepository _repository;

  @override
  ReadingListState build() {
    // Initialize repository synchronously from async provider
    // This will throw if provider hasn't resolved yet, which is expected
    final repoAsync = ref.watch(readingListSyncRepositoryProvider);

    return repoAsync.when(
      data: (repo) {
        _repository = repo;
        return const ReadingListState();
      },
      loading: () => const ReadingListState(),
      error: (error, stack) => ReadingListState(
        errorMessage: 'Failed to initialize reading lists: $error',
      ),
    );
  }

  /// Get the get reading lists use case.
  GetReadingListsUseCase get _getListsUseCase {
    return GetReadingListsUseCase(repository: _repository);
  }

  /// Get the create reading list use case.
  CreateReadingListUseCase get _createListUseCase {
    return CreateReadingListUseCase(repository: _repository);
  }

  /// Get the update reading list use case.
  UpdateReadingListUseCase get _updateListUseCase {
    return UpdateReadingListUseCase(repository: _repository);
  }

  /// Get the delete reading list use case.
  DeleteReadingListUseCase get _deleteListUseCase {
    return DeleteReadingListUseCase(repository: _repository);
  }

  /// Get the add audiobook to list use case.
  AddAudiobookToListUseCase get _addAudiobookUseCase {
    return AddAudiobookToListUseCase(repository: _repository);
  }

  /// Get the remove audiobook from list use case.
  RemoveAudiobookFromListUseCase get _removeAudiobookUseCase {
    return RemoveAudiobookFromListUseCase(repository: _repository);
  }

  /// Get the sync reading lists use case.
  SyncReadingListsUseCase get _syncUseCase {
    return SyncReadingListsUseCase(repository: _repository);
  }

  /// Load all reading lists.
  Future<void> loadReadingLists() async {
    state = state.copyWith(isLoading: true);

    try {
      final lists = await _getListsUseCase.execute();
      state = state.copyWith(
        lists: lists,
        isLoading: false,
        lastSyncTime: await _syncUseCase.getLastSyncTime(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load reading lists: $e',
      );
    }
  }

  /// Create a new reading list.
  Future<ReadingList?> createList({
    required String name,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final list = await _createListUseCase.execute(
        name: name,
        description: description,
      );
      state = state.copyWith(
        lists: [...state.lists, list],
        isLoading: false,
      );
      return list;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create list: $e',
      );
      return null;
    }
  }

  /// Update an existing reading list.
  Future<void> updateList(ReadingList readingList) async {
    try {
      await _updateListUseCase.execute(readingList);
      state = state.copyWith(
        lists: state.lists.map((l) => l.id == readingList.id ? readingList : l).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update list: $e');
    }
  }

  /// Delete a reading list.
  Future<void> deleteList(String listId) async {
    try {
      await _deleteListUseCase.execute(listId);
      state = state.copyWith(
        lists: state.lists.where((l) => l.id != listId).toList(),
        selectedList: state.selectedList?.id == listId ? null : state.selectedList,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete list: $e');
    }
  }

  /// Add an audiobook to a reading list.
  Future<void> addAudiobookToList(String listId, String audiobookId) async {
    try {
      await _addAudiobookUseCase.execute(listId, audiobookId);
      final list = state.getListById(listId);
      if (list != null) {
        final updatedList = list.withAddedAudiobook(audiobookId);
        state = state.copyWith(
          lists: state.lists.map((l) => l.id == listId ? updatedList : l).toList(),
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to add to list: $e');
    }
  }

  /// Remove an audiobook from a reading list.
  Future<void> removeAudiobookFromList(String listId, String audiobookId) async {
    try {
      await _removeAudiobookUseCase.execute(listId, audiobookId);
      final list = state.getListById(listId);
      if (list != null) {
        final updatedList = list.withRemovedAudiobook(audiobookId);
        state = state.copyWith(
          lists: state.lists.map((l) => l.id == listId ? updatedList : l).toList(),
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to remove from list: $e');
    }
  }

  /// Select a reading list.
  void selectList(ReadingList? list) {
    state = state.copyWith(selectedList: list);
  }

  /// Sync reading lists with remote.
  Future<void> syncReadingLists() async {
    try {
      final result = await _syncUseCase.execute();
      if (result.isSuccess) {
        await loadReadingLists();
      } else if (result.hasErrors) {
        state = state.copyWith(errorMessage: result.errors.join(', '));
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Sync failed: $e');
    }
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith();
  }
}

/// Provider for reading list state management.
final readingListProvider = NotifierProvider<ReadingListNotifier, ReadingListState>(
  ReadingListNotifier.new,
);

// =============================================================================
// NOTE: Use case providers are created directly in ReadingListNotifier
// to avoid async/sync mismatch with the readingListSyncRepositoryProvider.
// =============================================================================
