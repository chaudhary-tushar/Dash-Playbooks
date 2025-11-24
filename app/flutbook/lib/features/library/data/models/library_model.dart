/// Isar schema definitions for Flutbook's local database models.
/// Includes [AudiobookModel], [PlaybackSessionModel], [UserProfileModel], [LibraryModel],
/// and embedded [ChapterModel] with domain entity conversions and Isar annotations.
library;

import 'package:flutbook/features/auth/data/models/user_profile_model.dart' show UserProfileModel;
// lib/data/datasources/local/isar_schema.dart
import 'package:flutbook/features/library/data/models/audiobook_model.dart'
    show AudiobookModel, ChapterModel;
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/library/domain/entities/library.dart' as domain;
import 'package:flutbook/features/player/data/models/playback_session_model.dart'
    show PlaybackSessionModel;
import 'package:isar_community/isar.dart';

part 'library_model.g.dart';

@collection
class LibraryModel {
  // Total duration in milliseconds

  LibraryModel({
    required this.name,
    required this.path,
    required this.audiobookIds,
    required this.lastScanAt,
    required this.totalAudiobooks,
    required this.totalDurationInMs,
    this.id,
    this.internalId,
  });

  // Convert from domain entity
  factory LibraryModel.fromDomain(domain.Library library) {
    return LibraryModel(
      internalId: library.id,
      name: library.name,
      path: library.path,
      audiobookIds: [], // NOTE: We store audiobook references separately
      lastScanAt: library.lastScanAt,
      totalAudiobooks: library.totalAudiobooks,
      totalDurationInMs: library.totalDuration.inMilliseconds,
    );
  }
  Id? id = Isar.autoIncrement;

  String? internalId; // Maps to domain library.id
  String name;
  String path;
  List<String> audiobookIds; // References to audiobooks by ID
  DateTime lastScanAt;
  int totalAudiobooks;
  int totalDurationInMs;

  // Convert to domain entity
  domain.Library toDomain() {
    return domain.Library(
      id: internalId ?? '', // fallback to empty string if not set yet
      name: name,
      path: path,
      audiobooks: [], // NOTE: This will be populated by joining with AudiobookModel
      lastScanAt: lastScanAt,
      totalAudiobooks: totalAudiobooks,
      totalDuration: Duration(milliseconds: totalDurationInMs),
    );
  }

  @ignore
  Duration get totalDuration => Duration(milliseconds: totalDurationInMs);
  set totalDuration(Duration value) => totalDurationInMs = value.inMilliseconds;
}
