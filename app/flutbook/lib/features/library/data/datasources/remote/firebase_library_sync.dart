import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';

class LibraryRemoteDatasource {
  LibraryRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> uploadAudiobookMetadata(AudiobookModel audiobook) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('libraries')
          .doc(audiobook.id as String?)
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

  // Gets audiobook metadata from remote storage
  Future<List<AudiobookModel>> getAudiobookMetadata() async {
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

      final audiobooks = <AudiobookModel>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();

        final audiobook = AudiobookModel(
          internalId: (data['id'] as String?) ?? doc.id,
          title: (data['title'] as String?) ?? '',
          author: (data['author'] as String?) ?? '',
          album: (data['album'] as String?) ?? '',
          coverArtPath: data['coverArtPath'] as String?,
          durationInMs: (data['durationInMs'] as int?) ?? 0,
          filePath: (data['filePath'] as String?) ?? '',
          chapters: [], // Chapters would be loaded separately if needed
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate(),
          completed: (data['completed'] as bool?) ?? false,
          totalSize: (data['totalSize'] as int?) ?? 0,
        );

        audiobooks.add(audiobook);
      }

      return audiobooks;
    } catch (e) {
      throw DatabaseException('Failed to retrieve audiobook metadata: $e');
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

  Future<void> syncAll() async {
    // Stub: Full library sync to be implemented
  }
}
