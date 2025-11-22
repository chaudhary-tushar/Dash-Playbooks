// lib/data/models/playback_session_model.dart
import 'package:flutbook/features/playback/domain/entities/playback_session.dart' as domain;
import 'package:isar_community/isar.dart';

part 'playback_session_model.g.dart';

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
