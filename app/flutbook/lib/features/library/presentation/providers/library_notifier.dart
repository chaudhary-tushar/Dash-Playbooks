// lib/features/library/presentation/providers/library_notifier.dart
import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/presentation/providers/library_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// LibraryNotifier class that extends Notifier for Riverpod 3.x
class LibraryNotifier extends Notifier<LibraryState> {
  @override
  LibraryState build() {
    // Initialize with loading state and fetch audiobooks
    ref.onDispose(() {
      // Cleanup if needed
    });

    // Fetch audiobooks after provider initialization
    Future.microtask(fetchAudiobooks);

    // Start with loading state
    return const LibraryState(isLoading: true);
  }

  // Fetch audiobooks with current filters and sorting
  Future<void> fetchAudiobooks() async {
    if (!ref.mounted) return;

    try {
      // Get the library repository
      final repository = ref.read(libraryRepositoryProvider);

      // Build the filter based on current state
      final filter = state.filter;
      final sortBy = state.sortBy;
      final sortAscending = state.sortAscending;
      final searchQuery = state.searchQuery;

      // Map status filter to repository parameters
      bool? completedFilter;
      bool? inProgressFilter;

      final statusFilter = filter?.statusFilter ?? 'all';
      switch (statusFilter) {
        case 'all':
          // Show all audiobooks
          completedFilter = null;
          inProgressFilter = null;
        case 'reading':
          // Show only in-progress audiobooks (not completed, but played)
          completedFilter = false;
          inProgressFilter = true;
        case 'completed':
          // Show only completed audiobooks
          completedFilter = true;
          inProgressFilter = null;
        case 'wishlist':
          // Show only not started audiobooks (never played)
          completedFilter = false;
          inProgressFilter = false;
        default:
          completedFilter = null;
          inProgressFilter = null;
      }

      // Fetch audiobooks with current parameters
      final audiobooks = await repository.getAudiobooks(
        sortBy: sortBy,
        sortAscending: sortAscending,
        completed: completedFilter,
        inProgress: inProgressFilter,
        title: searchQuery ?? filter?.title,
        author: filter?.author,
      );

      if (ref.mounted) {
        state = state.copyWith(
          audiobooks: audiobooks,
          isLoading: false,
        );
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch audiobooks: $e',
        );
      }
    }
  }

  // Update filter and refresh audiobooks
  Future<void> updateFilter(AudiobookFilter filter) async {
    if (!ref.mounted) return;

    state = state.copyWith(
      filter: filter,
      isLoading: true,
    );

    await fetchAudiobooks();
  }

  // Update status filter and refresh audiobooks
  Future<void> updateStatusFilter(String statusFilter) async {
    if (!ref.mounted) return;

    final currentFilter = state.filter ?? const AudiobookFilter();
    final newFilter = currentFilter.copyWith(statusFilter: statusFilter);

    state = state.copyWith(
      filter: newFilter,
      isLoading: true,
    );

    await fetchAudiobooks();
  }

  // Update view type
  Future<void> updateViewType(String viewType) async {
    if (!ref.mounted) return;

    state = state.copyWith(viewType: viewType);
  }

  // Update sorting and refresh audiobooks
  Future<void> updateSorting(String sortBy, {bool sortAscending = true}) async {
    if (!ref.mounted) return;

    // Map new sort values to existing ones for compatibility
    var mappedSortBy = sortBy;
    if (sortBy == 'name') {
      mappedSortBy = 'title';
    } else if (sortBy == 'date') {
      mappedSortBy = 'recent';
    } else if (sortBy == 'progress') {
      mappedSortBy = 'progress';
    }

    state = state.copyWith(
      sortBy: mappedSortBy,
      sortAscending: sortAscending,
      isLoading: true,
    );

    await fetchAudiobooks();
  }

  // Update search query and refresh audiobooks
  Future<void> updateSearchQuery(String searchQuery) async {
    if (!ref.mounted) return;

    state = state.copyWith(
      searchQuery: searchQuery.isEmpty ? null : searchQuery,
      isLoading: true,
    );

    await fetchAudiobooks();
  }

  // Clear all filters and sorting
  Future<void> clearFilters() async {
    if (!ref.mounted) return;

    state = state.copyWith(
      sortAscending: true,
      isLoading: true,
    );

    await fetchAudiobooks();
  }

  // Refresh the library data
  Future<void> refreshLibrary() async {
    if (!ref.mounted) return;

    // Set loading state for refresh operation and clear any previous errors
    state = state.copyWith(
      isLoading: true,
    );

    await fetchAudiobooks();
  }

  // Get current audiobooks
  List<Audiobook> getCurrentAudiobooks() {
    return state.audiobooks;
  }

  // Get current filter
  AudiobookFilter? getCurrentFilter() {
    return state.filter;
  }

  // Check if library is loading
  bool isLoading() {
    return state.isLoading;
  }

  // Get current error message
  String? getErrorMessage() {
    return state.errorMessage;
  }
}
