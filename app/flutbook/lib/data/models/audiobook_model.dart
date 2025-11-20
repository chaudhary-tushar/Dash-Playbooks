// lib/data/models/audiobook_model.dart
import 'package:isar/isar.dart';

part 'audiobook_model.g.dart';

@collection
class AudiobookModel {
  AudiobookModel({
    required this.title,
    required this.author,
    required this.album,
    required this.durationInMs,
    required this.filePath,
    required this.chapters,
    required this.createdAt,
    required this.completed,
    required this.totalSize,
    this.internalId,
    this.coverArtPath,
    this.lastPlayedAt,
  });
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

  @ignore
  Duration get duration => Duration(milliseconds: durationInMs);

  set duration(Duration value) {
    durationInMs = value.inMilliseconds;
  }
}

@embedded
class ChapterModel {
  // Store as milliseconds

  ChapterModel({
    this.id = '',
    this.title = '',
    this.startTimeInMs = 0,
    this.endTimeInMs = 0,
  });
  String id;
  String title;
  int startTimeInMs; // Store as milliseconds
  int endTimeInMs;

  @ignore
  Duration get startTime => Duration(milliseconds: startTimeInMs);
  @ignore
  Duration get endTime => Duration(milliseconds: endTimeInMs);

  set startTime(Duration value) {
    startTimeInMs = value.inMilliseconds;
  }

  set endTime(Duration value) {
    endTimeInMs = value.inMilliseconds;
  }
}
