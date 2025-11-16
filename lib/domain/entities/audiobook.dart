// lib/domain/entities/audiobook.dart
import 'dart:convert';
import 'chapter.dart';

class Audiobook {
  final String id;
  final String title;
  final String author;
  final String album;
  final String? coverArtPath;
  final Duration duration;
  final String filePath;
  final List<Chapter> chapters;
  final DateTime createdAt;
  final DateTime? lastPlayedAt;
  final bool completed;
  final int totalSize;

  Audiobook({
    required this.id,
    required this.title,
    required this.author,
    required this.album,
    this.coverArtPath,
    required this.duration,
    required this.filePath,
    required this.chapters,
    required this.createdAt,
    this.lastPlayedAt,
    required this.completed,
    required this.totalSize,
  });

  Audiobook copyWith({
    String? id,
    String? title,
    String? author,
    String? album,
    String? coverArtPath,
    Duration? duration,
    String? filePath,
    List<Chapter>? chapters,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    bool? completed,
    int? totalSize,
  }) {
    return Audiobook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      album: album ?? this.album,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      chapters: chapters ?? this.chapters,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      completed: completed ?? this.completed,
      totalSize: totalSize ?? this.totalSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'album': album,
      'coverArtPath': coverArtPath,
      'duration': duration.inMilliseconds,
      'filePath': filePath,
      'chapters': chapters.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastPlayedAt': lastPlayedAt?.millisecondsSinceEpoch,
      'completed': completed,
      'totalSize': totalSize,
    };
  }

  factory Audiobook.fromMap(Map<String, dynamic> map) {
    return Audiobook(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      album: map['album'] ?? '',
      coverArtPath: map['coverArtPath'],
      duration: Duration(milliseconds: map['duration']?.toInt() ?? 0),
      filePath: map['filePath'] ?? '',
      chapters: List<Chapter>.from(
          (map['chapters'] as List<dynamic>).map<Chapter>((x) => Chapter.fromMap(x as Map<String, dynamic>))),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']?.toInt() ?? DateTime.now().millisecondsSinceEpoch),
      lastPlayedAt: map['lastPlayedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastPlayedAt'] as int)
          : null,
      completed: map['completed'] ?? false,
      totalSize: map['totalSize']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Audiobook.fromJson(String source) => Audiobook.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Audiobook(id: $id, title: $title, author: $author, filePath: $filePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Audiobook &&
        other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}