import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/playback/data/models/playback_session_model.dart';
import 'package:flutbook/features/playback/domain/entities/playback_session.dart';
import 'package:isar/isar.dart';

class PlaybackLocalDatasource {
  PlaybackLocalDatasource(this._isar);
  final Isar _isar;

  /// Saves playback session to Isar database with proper indexing
  Future<void> savePlaybackSession(PlaybackSession session) async {
    try {
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
}
