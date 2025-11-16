// lib/domain/entities/filter.dart

class AudiobookFilter {
  final String? title;
  final String? author;
  final bool? completed;
  final bool? inProgress;
  final String? sortBy; // 'title', 'author', 'lastPlayed', 'dateAdded'
  final bool sortAscending;
  final int? limit;

  const AudiobookFilter({
    this.title,
    this.author,
    this.completed,
    this.inProgress,
    this.sortBy,
    this.sortAscending = true,
    this.limit,
  });
}