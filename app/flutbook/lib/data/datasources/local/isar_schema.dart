// lib/data/datasources/local/isar_schema.dart
import 'package:flutbook/domain/entities/audiobook.dart' as domain;
import 'package:flutbook/domain/entities/chapter.dart' as domain;
import 'package:flutbook/domain/entities/library.dart' as domain;
import 'package:flutbook/domain/entities/playback_session.dart' as domain;
import 'package:flutbook/domain/entities/user_profile.dart' as domain;
import 'package:isar/isar.dart';

part 'isar_schema.g.dart';

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

@collection
class PlaybackSessionModel {
  // Sleep timer duration in milliseconds

  PlaybackSessionModel({
    required this.audiobookId,
    required this.currentPositionInMs,
    required this.playbackSpeed,
    required this.isPlaying,
    required this.lastPlayedAt,
    required this.sleepTimerActive,
    this.id,
    this.sleepTimerDurationInMs,
  });

  // Convert from domain entity
  factory PlaybackSessionModel.fromDomain(domain.PlaybackSession session) {
    return PlaybackSessionModel(
      audiobookId: session.audiobookId,
      currentPositionInMs: session.currentPosition.inMilliseconds,
      playbackSpeed: session.playbackSpeed,
      isPlaying: session.isPlaying,
      lastPlayedAt: session.lastPlayedAt,
      sleepTimerActive: session.sleepTimerActive,
      sleepTimerDurationInMs: session.sleepTimerDuration?.inMilliseconds,
    );
  }
  Id? id = Isar.autoIncrement;

  String audiobookId; // Maps to domain audiobook.id
  int currentPositionInMs; // Current position in milliseconds
  double playbackSpeed;
  bool isPlaying;
  DateTime lastPlayedAt;
  bool sleepTimerActive;
  int? sleepTimerDurationInMs;

  // Convert to domain entity
  domain.PlaybackSession toDomain() {
    return domain.PlaybackSession(
      audiobookId: audiobookId,
      currentPosition: Duration(milliseconds: currentPositionInMs),
      playbackSpeed: playbackSpeed,
      isPlaying: isPlaying,
      lastPlayedAt: lastPlayedAt,
      sleepTimerActive: sleepTimerActive,
      sleepTimerDuration: sleepTimerDurationInMs != null
          ? Duration(milliseconds: sleepTimerDurationInMs!)
          : null,
    );
  }

  @ignore
  Duration get currentPosition => Duration(milliseconds: currentPositionInMs);
  set currentPosition(Duration value) => currentPositionInMs = value.inMilliseconds;

  @ignore
  Duration? get sleepTimerDuration =>
      sleepTimerDurationInMs != null ? Duration(milliseconds: sleepTimerDurationInMs!) : null;
  set sleepTimerDuration(Duration? value) => sleepTimerDurationInMs = value?.inMilliseconds;
}

@collection
class UserProfileModel {
  UserProfileModel({
    required this.email,
    required this.authMethod,
    required this.syncEnabled,
    this.id,
    this.internalId,
    this.displayName,
    this.lastSyncAt,
    this.localLibraryPath,
  });

  // Convert from domain entity
  factory UserProfileModel.fromDomain(domain.UserProfile profile) {
    return UserProfileModel(
      internalId: profile.id,
      email: profile.email,
      displayName: profile.displayName,
      authMethod: profile.authMethod,
      syncEnabled: profile.syncEnabled,
      lastSyncAt: profile.lastSyncAt,
      localLibraryPath: profile.localLibraryPath,
    );
  }
  Id? id = Isar.autoIncrement;

  String? internalId; // Maps to domain user.id
  String email;
  String? displayName;
  String authMethod; // email_password, google_oauth, etc.
  bool syncEnabled;
  DateTime? lastSyncAt;
  String? localLibraryPath;

  // Convert to domain entity
  domain.UserProfile toDomain() {
    return domain.UserProfile(
      id: internalId ?? '', // fallback to empty string if not set yet
      email: email,
      displayName: displayName,
      authMethod: authMethod,
      syncEnabled: syncEnabled,
      lastSyncAt: lastSyncAt,
      localLibraryPath: localLibraryPath,
    );
  }
}

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

extension DurationExtension on Duration {
  int get inWholeMilliseconds => inMilliseconds;
}
