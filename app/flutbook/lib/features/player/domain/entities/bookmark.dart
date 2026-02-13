// lib/features/player/domain/entities/bookmark.dart
import 'dart:convert';

class Bookmark {
  Bookmark({
    required this.id,
    required this.audiobookId,
    required this.timestamp,
    required this.createdAt,
    this.note,
    this.chapterId,
  }) {
    // Validate chapterId - must be null or a non-empty string
    if (chapterId != null && chapterId!.isEmpty) {
      throw ArgumentError('chapterId cannot be an empty string');
    }
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int? ?? 0,
      audiobookId: map['audiobookId'] as String? ?? '',
      timestamp: Duration(
        milliseconds: (map['timestamp'] as num?)?.toInt() ?? 0,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      note: map['note'] as String?,
      chapterId: map['chapterId'] as String?,
    );
  }

  factory Bookmark.fromJson(String source) =>
      Bookmark.fromMap(json.decode(source) as Map<String, dynamic>);

  final int id;
  final String audiobookId;
  final Duration timestamp;
  final DateTime createdAt;
  final String? note;
  final String? chapterId;

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audiobookId': audiobookId,
      'timestamp': timestamp.inMilliseconds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'note': note,
      'chapterId': chapterId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Bookmark(id: $id, audiobookId: $audiobookId, timestamp: $timestamp, note: $note, chapterId: $chapterId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark &&
        other.id == id &&
        other.audiobookId == audiobookId &&
        other.chapterId == chapterId;
  }

  @override
  int get hashCode => id.hashCode ^ audiobookId.hashCode ^ chapterId.hashCode;
}
