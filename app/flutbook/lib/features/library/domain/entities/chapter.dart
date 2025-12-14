// lib/domain/entities/chapter.dart
import 'dart:convert';

class Chapter {
  Chapter({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      startTime: Duration(milliseconds: map['startTime'] as int? ?? 0),
      endTime: Duration(milliseconds: map['endTime'] as int? ?? 0),
    );
  }

  factory Chapter.fromJson(String source) =>
      Chapter.fromMap(json.decode(source) as Map<String, dynamic>);
  final String id;
  final String title;
  final Duration startTime;
  final Duration endTime;

  Chapter copyWith({
    String? id,
    String? title,
    Duration? startTime,
    Duration? endTime,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.inMilliseconds,
      'endTime': endTime.inMilliseconds,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Chapter(id: $id, title: $title, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chapter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
