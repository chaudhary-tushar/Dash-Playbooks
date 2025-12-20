// lib/features/library/domain/entities/audiobook_group.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';

class AudiobookGroup {
  AudiobookGroup({
    required this.groupKey,
    required this.groupName,
    required this.audiobooks,
    this.groupType = 'metadata',
  });

  final String groupKey; // Unique identifier for the group
  final String groupName; // Display name for the group
  final List<Audiobook> audiobooks; // List of audiobooks in this group
  final String groupType; // 'metadata' or 'directory'

  // Calculate total duration for the group
  Duration get totalDuration {
    return audiobooks.fold(
      Duration.zero,
      (sum, book) => sum + book.duration,
    );
  }

  // Check if all audiobooks in the group are completed
  bool get isCompleted {
    return audiobooks.every((book) => book.completed);
  }

  // Get the most recent lastPlayedAt from any audiobook in the group
  DateTime? get lastPlayedAt {
    final playedBooks = audiobooks
        .where((book) => book.lastPlayedAt != null)
        .toList();
    if (playedBooks.isEmpty) return null;

    playedBooks.sort((a, b) => b.lastPlayedAt!.compareTo(a.lastPlayedAt!));
    return playedBooks.first.lastPlayedAt;
  }

  // Calculate overall progress for the group (average of individual progresses)
  double get progress {
    if (audiobooks.isEmpty) return 0;

    final progresses = audiobooks.map((book) {
      if (book.completed) return 100.0;
      if (book.lastPlayedAt == null) return 0.0;

      // Simple heuristic for progress calculation
      final durationMs = book.duration.inMilliseconds;
      if (durationMs <= 0) return 0.0;

      final timeSinceLastPlayed = DateTime.now().difference(book.lastPlayedAt!);
      final hoursSinceLastPlayed = timeSinceLastPlayed.inHours;
      return (hoursSinceLastPlayed * 10).toDouble().clamp(0.0, 99.0);
    }).toList();

    return progresses.reduce((a, b) => a + b) / progresses.length;
  }

  // Get cover art path - use the first audiobook's cover if available
  String? get coverArtPath {
    for (final book in audiobooks) {
      if (book.coverArtPath != null && book.coverArtPath!.isNotEmpty) {
        return book.coverArtPath;
      }
    }
    return null;
  }

  // Get the first author from the group (for display purposes)
  String get representativeAuthor {
    for (final book in audiobooks) {
      if (book.author.isNotEmpty) {
        return book.author;
      }
    }
    return 'Unknown Author';
  }

  // Copy with method for immutability
  AudiobookGroup copyWith({
    String? groupKey,
    String? groupName,
    List<Audiobook>? audiobooks,
    String? groupType,
  }) {
    return AudiobookGroup(
      groupKey: groupKey ?? this.groupKey,
      groupName: groupName ?? this.groupName,
      audiobooks: audiobooks ?? this.audiobooks,
      groupType: groupType ?? this.groupType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudiobookGroup && other.groupKey == groupKey;
  }

  @override
  int get hashCode => groupKey.hashCode;

  @override
  String toString() {
    return 'AudiobookGroup(groupKey: $groupKey, groupName: $groupName, audiobooks: ${audiobooks.length})';
  }
}
