/// Domain entity representing a bookmark in an audiobook.
///
/// A bookmark marks a specific position in an audiobook with an optional note.
/// Bookmarks are used to save and quickly navigate to important positions.
class Bookmark {
  const Bookmark({
    required this.id,
    required this.audiobookId,
    required this.timestamp,
    required this.createdAt,
    this.note,
    this.chapterId,
  });

  /// Creates a Bookmark from a Map
  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int,
      audiobookId: map['audiobookId'] as String,
      timestamp: Duration(milliseconds: map['timestamp'] as int),
      createdAt: DateTime.parse(map['createdAt'] as String),
      note: map['note'] as String?,
      chapterId: map['chapterId'] as String?,
    );
  }

  /// Unique identifier for the bookmark (Isar auto-increment ID)
  final int id;

  /// ID of the audiobook this bookmark belongs to
  final String audiobookId;

  /// Position in the audiobook (Duration)
  final Duration timestamp;

  /// When the bookmark was created
  final DateTime createdAt;

  /// Optional note attached to the bookmark
  final String? note;

  /// ID of the chapter at bookmark position (if available)
  final String? chapterId;

  /// Creates a copy of this bookmark with the given fields replaced
  Bookmark copyWith({
    int? id,
    String? audiobookId,
    Duration? timestamp,
    DateTime? createdAt,
    String? note,
    String? chapterId,
  }) {
    return Bookmark(
      id: id ?? this.id,
      audiobookId: audiobookId ?? this.audiobookId,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      chapterId: chapterId ?? this.chapterId,
    );
  }

  /// Converts bookmark to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audiobookId': audiobookId,
      'timestamp': timestamp.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
      'chapterId': chapterId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark &&
        other.id == id &&
        other.audiobookId == audiobookId &&
        other.timestamp == timestamp &&
        other.createdAt == createdAt &&
        other.note == note &&
        other.chapterId == chapterId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        audiobookId.hashCode ^
        timestamp.hashCode ^
        createdAt.hashCode ^
        note.hashCode ^
        chapterId.hashCode;
  }

  @override
  String toString() {
    return 'Bookmark(id: $id, audiobookId: $audiobookId, timestamp: $timestamp, '
        'createdAt: $createdAt, note: $note, chapterId: $chapterId)';
  }
}
