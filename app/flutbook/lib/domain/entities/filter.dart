// lib/domain/entities/filter.dart

class AudiobookFilter {
  const AudiobookFilter({
    this.title,
    this.author,
    this.completed,
    this.inProgress,
    this.sortBy,
    this.sortAscending = true,
    this.limit,
  });
  final String? title;
  final String? author;
  final bool? completed;
  final bool? inProgress;
  final String? sortBy; // 'title', 'author', 'lastPlayed', 'dateAdded'
  final bool sortAscending;
  final int? limit;
}
