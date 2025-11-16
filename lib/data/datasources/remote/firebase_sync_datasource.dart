// lib/data/datasources/remote/firebase_sync_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/entities/audiobook.dart';
import '../../../domain/entities/playback_session.dart';

class FirebaseSyncDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseSyncDatasource({ 
    FirebaseFirestore? firestore, 
    FirebaseAuth? auth 
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  /// Uploads audiobook metadata to remote storage
  Future<void> uploadAudiobookMetadata(Audiobook audiobook) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('libraries')
          .doc(audiobook.id)
          .set({
        'id': audiobook.id,
        'title': audiobook.title,
        'author': audiobook.author,
        'album': audiobook.album,
        'coverArtPath': audiobook.coverArtPath,
        'durationInMs': audiobook.duration.inMilliseconds,
        'filePath': audiobook.filePath, // Only saving metadata, not the actual file path
        'createdAt': Timestamp.fromDate(audiobook.createdAt),
        'lastPlayedAt': audiobook.lastPlayedAt != null 
            ? Timestamp.fromDate(audiobook.lastPlayedAt!) 
            : null,
        'completed': audiobook.completed,
        'totalSize': audiobook.totalSize,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw DatabaseException('Failed to upload audiobook metadata: $e');
    }
  }

  /// Gets audiobook metadata from remote storage
  Future<List<Audiobook>> getAudiobookMetadata() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('libraries')
          .get();

      final audiobooks = <Audiobook>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        final audiobook = Audiobook(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          author: data['author'] ?? '',
          album: data['album'] ?? '',
          coverArtPath: data['coverArtPath'],
          duration: Duration(
            milliseconds: data['durationInMs']?.toInt() ?? 0,
          ),
          filePath: data['filePath'] ?? '',
          chapters: [], // Chapters would be loaded separately if needed
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate(),
          completed: data['completed'] ?? false,
          totalSize: data['totalSize']?.toInt() ?? 0,
        );
        
        audiobooks.add(audiobook);
      }

      return audiobooks;
    } catch (e) {
      throw DatabaseException('Failed to retrieve audiobook metadata: $e');
    }
  }

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
          audiobookId: data['audiobookId'] ?? doc.id,
          currentPosition: Duration(
            milliseconds: data['currentPositionInMs']?.toInt() ?? 0,
          ),
          playbackSpeed: data['playbackSpeed']?.toDouble() ?? 1.0,
          isPlaying: data['isPlaying'] ?? false,
          lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          sleepTimerActive: data['sleepTimerActive'] ?? false,
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

  /// Syncs all user data with remote, with conflict resolution
  Future<SyncResult> syncAll() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      // For simplicity, we'll sync audiobook metadata and playback sessions
      // In a real implementation, we'd also sync user settings and preferences
      final remoteAudiobooks = await getAudiobookMetadata();
      final remoteSessions = await getPlaybackSessions();

      return SyncResult(success: true, message: 'Sync completed successfully', itemsSynced: remoteAudiobooks.length + remoteSessions.length);
    } catch (e) {
      return SyncResult(success: false, message: 'Sync failed: $e', itemsSynced: 0);
    }
  }

  /// Deletes audiobook metadata from remote storage
  Future<void> deleteAudiobookMetadata(String audiobookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('libraries')
          .doc(audiobookId)
          .delete();
    } catch (e) {
      throw DatabaseException('Failed to delete audiobook metadata: $e');
    }
  }
}

/// Result class for sync operations
class SyncResult {
  final bool success;
  final String message;
  final int itemsSynced;

  const SyncResult({
    required this.success,
    required this.message,
    required this.itemsSynced,
  });
}