// lib/data/models/audiobook_model.dart
import 'package:isar/isar.dart';

part 'audiobook_model.g.dart';

@collection
class AudiobookModel {
  Id? id = Isar.autoIncrement; // This will be generated automatically
  
  String? internalId; // Original audiobook.id
  String title;
  String author;
  String album;
  String? coverArtPath;
  int durationInMs; // Store as milliseconds
  String filePath;
  List<ChapterModel> chapters;
  DateTime createdAt;
  DateTime? lastPlayedAt;
  bool completed;
  int totalSize;

  AudiobookModel({
    this.internalId,
    required this.title,
    required this.author,
    required this.album,
    this.coverArtPath,
    required this.durationInMs,
    required this.filePath,
    required this.chapters,
    required this.createdAt,
    this.lastPlayedAt,
    required this.completed,
    required this.totalSize,
  });

  Duration get duration => Duration(milliseconds: durationInMs);
  
  set duration(Duration value) {
    durationInMs = value.inMilliseconds;
  }
}

@embedded
class ChapterModel {
  String id;
  String title;
  int startTimeInMs; // Store as milliseconds
  int endTimeInMs;    // Store as milliseconds

  ChapterModel({
    required this.id,
    required this.title,
    required this.startTimeInMs,
    required this.endTimeInMs,
  });

  Duration get startTime => Duration(milliseconds: startTimeInMs);
  Duration get endTime => Duration(milliseconds: endTimeInMs);
  
  set startTime(Duration value) {
    startTimeInMs = value.inMilliseconds;
  }
  
  set endTime(Duration value) {
    endTimeInMs = value.inMilliseconds;
  }
}