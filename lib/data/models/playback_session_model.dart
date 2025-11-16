// lib/data/models/playback_session_model.dart
import 'package:isar/isar.dart';

part 'playback_session_model.g.dart';

@collection
class PlaybackSessionModel {
  Id? id = Isar.autoIncrement; // This will be generated automatically
  
  String audiobookId;
  int currentPositionInMs; // Store as milliseconds
  double playbackSpeed;
  bool isPlaying;
  DateTime lastPlayedAt;
  bool sleepTimerActive;
  int? sleepTimerDurationInMs; // Store as milliseconds

  PlaybackSessionModel({
    this.id,
    required this.audiobookId,
    required this.currentPositionInMs,
    required this.playbackSpeed,
    required this.isPlaying,
    required this.lastPlayedAt,
    required this.sleepTimerActive,
    this.sleepTimerDurationInMs,
  });

  Duration get currentPosition => Duration(milliseconds: currentPositionInMs);
  Duration? get sleepTimerDuration => sleepTimerDurationInMs != null 
      ? Duration(milliseconds: sleepTimerDurationInMs!) 
      : null;
  
  set currentPosition(Duration value) {
    currentPositionInMs = value.inMilliseconds;
  }
  
  set sleepTimerDuration(Duration? value) {
    sleepTimerDurationInMs = value?.inMilliseconds;
  }
}