// lib/data/datasources/remote_datasource.dart
import 'package:flutbook/domain/entities/audiobook.dart';
import 'package:flutbook/domain/entities/playback_session.dart';

abstract class RemoteDataSource {
  /// Uploads audiobook metadata to remote storage
  Future<void> uploadAudiobookMetadata(Audiobook audiobook);

  /// Gets audiobook metadata from remote storage
  Future<List<Audiobook>> getAudiobookMetadata();

  /// Uploads playback session to remote storage
  Future<void> uploadPlaybackSession(PlaybackSession session);

  /// Gets playback sessions from remote storage
  Future<List<PlaybackSession>> getPlaybackSessions();

  /// Syncs all user data with remote
  Future<SyncResult> syncAll();
}
