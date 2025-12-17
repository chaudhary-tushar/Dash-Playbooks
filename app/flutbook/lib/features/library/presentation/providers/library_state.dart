// lib/features/library/presentation/providers/library_state.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';

// Library State class to represent the library state
class LibraryState {
  const LibraryState({
    this.audiobooks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filter,
    this.sortBy,
    this.sortAscending = true,
    this.searchQuery,
    this.viewType = 'list', // list or grid
  });

  final List<Audiobook> audiobooks;
  final bool isLoading;
  final String? errorMessage;
  final AudiobookFilter? filter;
  final String? sortBy;
  final bool sortAscending;
  final String? searchQuery;
  final String viewType; // list or grid

  LibraryState copyWith({
    List<Audiobook>? audiobooks,
    bool? isLoading,
    String? errorMessage,
    AudiobookFilter? filter,
    String? sortBy,
    bool? sortAscending,
    String? searchQuery,
    String? viewType,
  }) {
    return LibraryState(
      audiobooks: audiobooks ?? this.audiobooks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      searchQuery: searchQuery ?? this.searchQuery,
      viewType: viewType ?? this.viewType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LibraryState &&
        other.audiobooks == audiobooks &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.filter == filter &&
        other.sortBy == sortBy &&
        other.sortAscending == sortAscending &&
        other.searchQuery == searchQuery &&
        other.viewType == viewType;
  }

  @override
  int get hashCode {
    return audiobooks.hashCode ^
        isLoading.hashCode ^
        errorMessage.hashCode ^
        filter.hashCode ^
        sortBy.hashCode ^
        sortAscending.hashCode ^
        searchQuery.hashCode ^
        viewType.hashCode;
  }
}

// Filter class for library filtering
class AudiobookFilter {
  const AudiobookFilter({
    this.title,
    this.author,
    this.statusFilter = 'all', // all, reading, completed, wishlist
    this.completed,
    this.inProgress,
  });

  final String? title;
  final String? author;
  final String statusFilter; // all, reading, completed, wishlist
  final bool? completed;
  final bool? inProgress;

  AudiobookFilter copyWith({
    String? title,
    String? author,
    String? statusFilter,
    bool? completed,
    bool? inProgress,
  }) {
    return AudiobookFilter(
      title: title ?? this.title,
      author: author ?? this.author,
      statusFilter: statusFilter ?? this.statusFilter,
      completed: completed ?? this.completed,
      inProgress: inProgress ?? this.inProgress,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudiobookFilter &&
        other.title == title &&
        other.author == author &&
        other.statusFilter == statusFilter &&
        other.completed == completed &&
        other.inProgress == inProgress;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        author.hashCode ^
        statusFilter.hashCode ^
        completed.hashCode ^
        inProgress.hashCode;
  }
}
