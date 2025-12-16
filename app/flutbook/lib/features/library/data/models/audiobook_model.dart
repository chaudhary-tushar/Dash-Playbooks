// lib/data/models/audiobook_model.dart
/// Isar schema definitions for Flutbook's local database models.
/// Includes [AudiobookModel], [UserProfileModel], [LibraryModel],
/// and embedded [ChapterModel] with domain entity conversions and Isar annotations.
library;

import 'package:flutbook/features/auth/data/models/user_profile_model.dart' show UserProfileModel;
import 'package:flutbook/features/library/data/models/library_model.dart' show LibraryModel;
// lib/data/datasources/local/isar_schema.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart' as domain;
import 'package:flutbook/features/library/domain/entities/chapter.dart' as domain;
import 'package:isar_community/isar.dart';

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

  // Convert from domain entity
  factory AudiobookModel.fromDomain(domain.Audiobook audiobook) {
    return AudiobookModel(
      internalId: audiobook.id,
      title: audiobook.title,
      author: audiobook.author,
      album: audiobook.album,
      coverArtPath: audiobook.coverArtPath,
      durationInMs: audiobook.duration.inMilliseconds,
      filePath: audiobook.filePath,
      chapters: audiobook.chapters.map(ChapterModel.fromDomain).toList(),
      createdAt: audiobook.createdAt,
      lastPlayedAt: audiobook.lastPlayedAt,
      completed: audiobook.completed,
      totalSize: audiobook.totalSize,
    );
  }
  Id? id = Isar.autoIncrement;

  String? internalId; // Maps to domain audiobook.id
  String title;
  String author;
  String album;
  String? coverArtPath;
  int durationInMs; // Duration in milliseconds
  String filePath;
  List<ChapterModel> chapters;
  DateTime createdAt;
  DateTime? lastPlayedAt;
  bool completed;
  int totalSize;

  // Convert to domain entity
  domain.Audiobook toDomain() {
    return domain.Audiobook(
      id: internalId ?? filePath, // fallback to filepath if internalId not set
      title: title,
      author: author,
      album: album,
      coverArtPath: coverArtPath,
      duration: Duration(milliseconds: durationInMs),
      filePath: filePath,
      chapters: chapters.map((c) => c.toDomain()).toList(),
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt,
      completed: completed,
      totalSize: totalSize,
    );
  }

  @ignore
  Duration get duration => Duration(milliseconds: durationInMs);
  set duration(Duration value) => durationInMs = value.inMilliseconds;
}

@embedded
class ChapterModel {
  // End time in milliseconds

  ChapterModel({
    this.id = '',
    this.title = '',
    this.startTimeInMs = 0,
    this.endTimeInMs = 0,
  });

  // Convert from domain entity
  factory ChapterModel.fromDomain(domain.Chapter chapter) {
    return ChapterModel(
      id: chapter.id,
      title: chapter.title,
      startTimeInMs: chapter.startTime.inMilliseconds,
      endTimeInMs: chapter.endTime.inMilliseconds,
    );
  }
  String id;
  String title;
  int startTimeInMs; // Start time in milliseconds from beginning of audiobook
  int endTimeInMs;

  // Convert to domain entity
  domain.Chapter toDomain() {
    return domain.Chapter(
      id: id,
      title: title,
      startTime: Duration(milliseconds: startTimeInMs),
      endTime: Duration(milliseconds: endTimeInMs),
    );
  }

  @ignore
  Duration get startTime => Duration(milliseconds: startTimeInMs);
  set startTime(Duration value) => startTimeInMs = value.inMilliseconds;

  @ignore
  Duration get endTime => Duration(milliseconds: endTimeInMs);
  set endTime(Duration value) => endTimeInMs = value.inMilliseconds;
}
