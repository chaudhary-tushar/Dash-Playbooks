import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutbook/features/library/data/datasources/models/audiobook_model.dart';

class LibraryRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LibraryRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

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

  // Gets audiobook metadata from remote storage
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
