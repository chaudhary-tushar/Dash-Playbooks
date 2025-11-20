// lib/domain/entities/library.dart
import 'dart:convert';

import 'package:flutbook/domain/entities/audiobook.dart';

class Library {
  Library({
    required this.id,
    required this.name,
    required this.path,
    required this.audiobooks,
    required this.lastScanAt,
    required this.totalAudiobooks,
    required this.totalDuration,
  });

  factory Library.fromMap(Map<String, dynamic> map) {
    return Library(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      path: map['path'] ?? '',
      audiobooks: List<Audiobook>.from(
        (map['audiobooks'] as List<dynamic>).map<Audiobook>(
          (x) => Audiobook.fromMap(x as Map<String, dynamic>),
        ),
      ),
      lastScanAt: DateTime.fromMillisecondsSinceEpoch(
        map['lastScanAt']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      totalAudiobooks: map['totalAudiobooks']?.toInt() ?? 0,
      totalDuration: Duration(milliseconds: map['totalDuration']?.toInt() ?? 0),
    );
  }

  factory Library.fromJson(String source) =>
      Library.fromMap(json.decode(source) as Map<String, dynamic>);
  final String id;
  final String name;
  final String path;
  final List<Audiobook> audiobooks;
  final DateTime lastScanAt;
  final int totalAudiobooks;
  final Duration totalDuration;

  Library copyWith({
    String? id,
    String? name,
    String? path,
    List<Audiobook>? audiobooks,
    DateTime? lastScanAt,
    int? totalAudiobooks,
    Duration? totalDuration,
  }) {
    return Library(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      audiobooks: audiobooks ?? this.audiobooks,
      lastScanAt: lastScanAt ?? this.lastScanAt,
      totalAudiobooks: totalAudiobooks ?? this.totalAudiobooks,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'audiobooks': audiobooks.map((x) => x.toMap()).toList(),
      'lastScanAt': lastScanAt.millisecondsSinceEpoch,
      'totalAudiobooks': totalAudiobooks,
      'totalDuration': totalDuration.inMilliseconds,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Library(id: $id, name: $name, path: $path, totalAudiobooks: $totalAudiobooks)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Library && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
