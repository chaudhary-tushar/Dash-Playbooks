// lib/features/player/domain/entities/chapter.dart
import 'dart:convert';

import 'package:flutbook/features/player/domain/entities/bookmark.dart';

class Chapter {
  Chapter({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.audiobookId,
    this.bookmarks = const [],
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      startTime: Duration(milliseconds: map['startTime'] as int? ?? 0),
      endTime: Duration(milliseconds: map['endTime'] as int? ?? 0),
      audiobookId: map['audiobookId'] as String? ?? '',
      bookmarks: List<Bookmark>.from(
        (map['bookmarks'] as List<dynamic>? ?? []).map<Bookmark>(
          (x) => Bookmark.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  factory Chapter.fromJson(String source) =>
      Chapter.fromMap(json.decode(source) as Map<String, dynamic>);

  final String id;
  final String title;
  final Duration startTime;
  final Duration endTime;
  final String audiobookId;
  final List<Bookmark> bookmarks;

  Chapter copyWith({
    String? id,
    String? title,
    Duration? startTime,
    Duration? endTime,
    String? audiobookId,
    List<Bookmark>? bookmarks,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      audiobookId: audiobookId ?? this.audiobookId,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.inMilliseconds,
      'endTime': endTime.inMilliseconds,
      'audiobookId': audiobookId,
      'bookmarks': bookmarks.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Chapter(id: $id, title: $title, startTime: $startTime, endTime: $endTime, audiobookId: $audiobookId, bookmarks: ${bookmarks.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chapter &&
        other.id == id &&
        other.audiobookId == audiobookId;
  }

  @override
  int get hashCode => id.hashCode ^ audiobookId.hashCode;
}
