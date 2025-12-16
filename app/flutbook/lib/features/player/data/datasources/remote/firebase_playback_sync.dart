import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';

class PlaybackRemoteDatasource {
  PlaybackRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Uploads playback session to remote storage
  Future<void> uploadPlaybackSession(PlaybackSession session) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('playback_sessions')
          .doc(session.audiobookId)
          .set({
            'audiobookId': session.audiobookId,
            'currentPositionInMs': session.currentPosition.inMilliseconds,
            'playbackSpeed': session.playbackSpeed,
            'isPlaying': session.isPlaying,
            'lastPlayedAt': Timestamp.fromDate(session.lastPlayedAt),
            'sleepTimerActive': session.sleepTimerActive,
            'sleepTimerDurationInMs': session.sleepTimerDuration?.inMilliseconds,
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      throw DatabaseException('Failed to upload playback session: $e');
    }
  }

  /// Gets playback sessions from remote storage
  Future<List<PlaybackSession>> getPlaybackSessions() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('playback_sessions')
          .get();

      final sessions = <PlaybackSession>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();

        final session = PlaybackSession(
          audiobookId: data['audiobookId'] as String? ?? doc.id,
          currentPosition: Duration(
            milliseconds: (data['currentPositionInMs'] as num?)?.toInt() ?? 0,
          ),
          playbackSpeed: (data['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
          isPlaying: data['isPlaying'] as bool? ?? false,
          lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          sleepTimerActive: data['sleepTimerActive'] as bool? ?? false,
          sleepTimerDuration: data['sleepTimerDurationInMs'] != null
              ? Duration(milliseconds: data['sleepTimerDurationInMs'] as int)
              : null,
        );

        sessions.add(session);
      }

      return sessions;
    } catch (e) {
      throw DatabaseException('Failed to retrieve playback sessions: $e');
    }
  }
}
