// lib/domain/entities/chapter.dart
import 'dart:convert';

class Chapter {
  Chapter({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.filePath,
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      startTime: Duration(milliseconds: map['startTime'] as int? ?? 0),
      endTime: Duration(milliseconds: map['endTime'] as int? ?? 0),
      filePath: map['filePath'] as String?,
    );
  }

  factory Chapter.fromJson(String source) =>
      Chapter.fromMap(json.decode(source) as Map<String, dynamic>);
  final String id;
  final String title;
  final Duration startTime;
  final Duration endTime;
  // For multi-file audiobooks: which audio file this chapter resides in.
  // Null for single-file or embedded-chapter audiobooks.
  final String? filePath;

  Chapter copyWith({
    String? id,
    String? title,
    Duration? startTime,
    Duration? endTime,
    String? filePath,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      filePath: filePath ?? this.filePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.inMilliseconds,
      'endTime': endTime.inMilliseconds,
      'filePath': filePath,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Chapter(id: $id, title: $title, startTime: $startTime, endTime: $endTime, filePath: $filePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chapter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
