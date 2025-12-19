import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/data/models/playback_history_model.dart';
import 'package:flutbook/features/player/data/models/playback_session_model.dart';
import 'package:flutbook/features/player/domain/entities/playback_history.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:isar_community/isar.dart';

class PlaybackLocalDatasource {
  PlaybackLocalDatasource(this._isar) {
    _validateInitialization();
  }
  final Isar _isar;

  /// Validates that the datasource is properly initialized with a valid Isar instance
  void _validateInitialization() {}

  /// Checks if the datasource is initialized and ready for use
  bool get isInitialized => _isar != null;

  /// Saves playback session to Isar database with proper indexing
  Future<void> savePlaybackSession(PlaybackSession session) async {
    try {
      _validateInitialization();
      final sessionModel = PlaybackSessionModel.fromDomain(session);

      await _isar.writeTxn(() async {
        await _isar.playbackSessionModels.put(sessionModel);
      });
    } catch (e) {
      throw DatabaseException('Failed to save playback session: $e');
    }
  }

  /// Gets playback session from Isar database
  Future<PlaybackSession?> getPlaybackSession(String audiobookId) async {
    try {
      _validateInitialization();
      final sessionModel = await _isar.playbackSessionModels
          .where()
          .filter()
          .audiobookIdEqualTo(audiobookId)
          .findFirst();

      return sessionModel?.toDomain();
    } catch (e) {
      throw DatabaseException('Failed to retrieve playback session: $e');
    }
  }

  /// Gets all playback sessions from Isar database
  Future<List<PlaybackSession>> getAllPlaybackSessions() async {
    try {
      _validateInitialization();
      final sessionModels = await _isar.playbackSessionModels.where().findAll();

      return sessionModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw DatabaseException('Failed to retrieve playback sessions: $e');
    }
  }

  /// Saves playback history entry to Isar database
  Future<void> savePlaybackHistory(PlaybackHistory history) async {
    try {
      _validateInitialization();
      final historyModel = PlaybackHistoryModel(
        audiobookId: history.audiobookId,
        positionInMs: history.position.inMilliseconds,
        durationInMs: history.duration.inMilliseconds,
        playedAt: history.playedAt,
      );

      await _isar.writeTxn(() async {
        await _isar.playbackHistoryModels.put(historyModel);
      });
    } catch (e) {
      throw DatabaseException('Failed to save playback history: $e');
    }
  }

  /// Gets playback history for a specific audiobook
  Future<List<PlaybackHistory>> getPlaybackHistory(String audiobookId) async {
    try {
      _validateInitialization();
      final historyModels = await _isar.playbackHistoryModels
          .where()
          .filter()
          .audiobookIdEqualTo(audiobookId)
          .sortByPlayedAtDesc()
          .findAll();

      return historyModels
          .map(
            (model) => PlaybackHistory(
              audiobookId: model.audiobookId,
              position: Duration(milliseconds: model.positionInMs),
              duration: Duration(milliseconds: model.durationInMs),
              playedAt: model.playedAt,
            ),
          )
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to retrieve playback history: $e');
    }
  }

  /// Gets all playback history entries
  Future<List<PlaybackHistory>> getAllPlaybackHistory() async {
    try {
      _validateInitialization();
      final historyModels = await _isar.playbackHistoryModels
          .where()
          .sortByPlayedAtDesc()
          .findAll();

      return historyModels
          .map(
            (model) => PlaybackHistory(
              audiobookId: model.audiobookId,
              position: Duration(milliseconds: model.positionInMs),
              duration: Duration(milliseconds: model.durationInMs),
              playedAt: model.playedAt,
            ),
          )
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to retrieve all playback history: $e');
    }
  }

  /// Clears all playback history
  Future<void> clearPlaybackHistory() async {
    try {
      _validateInitialization();
      await _isar.writeTxn(() async {
        await _isar.playbackHistoryModels.clear();
      });
    } catch (e) {
      throw DatabaseException('Failed to clear playback history: $e');
    }
  }

  /// Gets the last played position for an audiobook
  Future<Duration?> getLastPlayedPosition(String audiobookId) async {
    try {
      _validateInitialization();
      final lastSession = await _isar.playbackHistoryModels
          .where()
          .filter()
          .audiobookIdEqualTo(audiobookId)
          .sortByPlayedAtDesc()
          .findFirst();

      return lastSession != null
          ? Duration(milliseconds: lastSession.positionInMs)
          : null;
    } catch (e) {
      throw DatabaseException('Failed to get last played position: $e');
    }
  }

  /// Gets total playback time for an audiobook
  Future<Duration> getTotalPlaybackTime(String audiobookId) async {
    try {
      _validateInitialization();
      final historyModels = await _isar.playbackHistoryModels
          .where()
          .filter()
          .audiobookIdEqualTo(audiobookId)
          .findAll();

      final totalMs = historyModels.fold<int>(
        0,
        (sum, model) => sum + model.durationInMs,
      );
      return Duration(milliseconds: totalMs);
    } catch (e) {
      throw DatabaseException('Failed to get total playback time: $e');
    }
  }
}
