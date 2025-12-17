// lib/features/player/data/models/playback_history_model.dart
import 'package:isar_community/isar.dart';

part 'playback_history_model.g.dart';

@collection
class PlaybackHistoryModel {
  PlaybackHistoryModel({
    required this.audiobookId,
    required this.positionInMs,
    required this.durationInMs,
    required this.playedAt,
    this.id,
  });

  Id? id = Isar.autoIncrement;

  String audiobookId; // Maps to domain audiobook.id
  int positionInMs; // Position in milliseconds
  int durationInMs; // Duration of playback session in milliseconds
  DateTime playedAt; // When this playback session occurred

  @ignore
  Duration get position => Duration(milliseconds: positionInMs);
  set position(Duration value) => positionInMs = value.inMilliseconds;

  @ignore
  Duration get duration => Duration(milliseconds: durationInMs);
  set duration(Duration value) => durationInMs = value.inMilliseconds;
}
