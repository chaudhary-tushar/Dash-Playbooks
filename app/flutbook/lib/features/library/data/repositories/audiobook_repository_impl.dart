// lib/data/repositories/audiobook_repository_impl.dart
// import 'package:flutbook/data/providers/audiobook_provider.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/library/data/datasources/audiobook_local_ds.dart';
import 'package:flutbook/features/library/data/datasources/remote/firebase_library_sync.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/repositories/audiobook_repository.dart';

class AudiobookRepositoryImpl implements AudiobookRepository {
  AudiobookRepositoryImpl({
    required AudiobookLocalDatasource localDatasource,
    // required AudiobookProvider provider,
    LibraryRemoteDatasource? remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource;
  //  _provider = provider;
  final AudiobookLocalDatasource _localDatasource;
  final LibraryRemoteDatasource? _remoteDatasource; // Nullable for anonymous users
  // final AudiobookProvider _provider;

  @override
  Future<List<Audiobook>> getAllAudiobooks() async {
    try {
      return await _localDatasource.getAudiobooks();
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Audiobook?> getAudiobookById(String id) async {
    try {
      return await _localDatasource.getAudiobookById(id);
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<List<Audiobook>> scanDirectory(String directoryPath) async {
    try {
      // This is handled by the local datasource
      // The repository coordinates between local and remote operations
      final audiobooks = await _localDatasource.scanDirectory(directoryPath);

      // Save to local storage
      await _localDatasource.saveAudiobooks(audiobooks);

      // If user is authenticated, consider syncing new audiobooks
      if (_remoteDatasource != null) {
        try {
          // In a real implementation, we would sync new audiobooks to remote
          // For now, we just save locally
        } catch (e) {
          print('Warning: Could not sync audiobooks to remote: $e');
          // Continue anyway, local storage is the primary source
        }
      }

      return audiobooks;
    } catch (e) {
      throw FileSystemException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<void> updateAudiobook(Audiobook audiobook) async {
    try {
      // Update the audiobook in local storage
      final allAudiobooks = await _localDatasource.getAudiobooks();
      final updatedAudiobooks = allAudiobooks
          .map((a) => a.id == audiobook.id ? audiobook : a)
          .toList();

      await _localDatasource.saveAudiobooks(updatedAudiobooks);

      // If user is authenticated, sync the update
      if (_remoteDatasource != null) {
        try {
          await _remoteDatasource.uploadAudiobookMetadata(audiobook as AudiobookModel);
        } catch (e) {
          print('Warning: Could not sync audiobook update to remote: $e');
          // Continue anyway, local storage is the primary source
        }
      }
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<void> deleteAudiobook(String id) async {
    try {
      // For this implementation, we're not deleting the actual file, just the record
      final allAudiobooks = await _localDatasource.getAudiobooks();
      final remainingAudiobooks = allAudiobooks.where((a) => a.id != id).toList();

      // Note: This removes from database but not the actual file
      // In a full implementation, we might want to handle file deletion separately
      await _localDatasource.saveAudiobooks(remainingAudiobooks);

      // If user is authenticated, sync the deletion
      if (_remoteDatasource != null) {
        try {
          await _remoteDatasource.deleteAudiobookMetadata(id);
        } catch (e) {
          print('Warning: Could not sync audiobook deletion to remote: $e');
          // Continue anyway, local storage is the primary source
        }
      }
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  // @override
  // Future<List<Audiobook>> searchAudiobooks(String query) async {
  //   try {
  //     return await _localDatasource.searchAudiobooks(query);
  //   } catch (e) {
  //     throw StorageException(ErrorHandler.handleException(e));
  //   }
  // }

  // @override
  // Future<List<Audiobook>> filterAudiobooks(AudiobookFilter filter) async {
  //   try {
  //     return await _localDatasource.filterAudiobooks(filter);
  //   } catch (e) {
  //     throw StorageException(ErrorHandler.handleException(e));
  //   }
  // }

  @override
  Future<List<Audiobook>> findAudiobooks({
    String? author,
    bool? completed,
    int? limit,
  }) async {
    try {
      return await _localDatasource.findAudiobooks(
        author: author,
        completed: completed,
        limit: limit,
      );
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  /// Checks if a file is still accessible (handles moved/deleted files after scan)
  Future<bool> isFileAccessible(String filePath) async {
    try {
      return await _localDatasource.isFileAccessible(filePath);
    } catch (e) {
      // If we can't check due to error, assume it's not accessible
      return false;
    }
  }

  /// Updates playback position for an audiobook
  Future<void> updatePlaybackPosition(
    String audiobookId,
    Duration position,
  ) async {
    try {
      // Get the audiobook to update
      final audiobook = await getAudiobookById(audiobookId);
      if (audiobook == null) {
        throw StorageException('Audiobook with ID $audiobookId not found');
      }

      // Update the last played time
      final updatedAudiobook = audiobook.copyWith(
        lastPlayedAt: DateTime.now(),
        completed: position.inMilliseconds / audiobook.duration.inMilliseconds >= 0.95,
      );

      await updateAudiobook(updatedAudiobook);
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  /// Saves playback session state
  Future<void> savePlaybackSession(
    String audiobookId,
    Duration position, {
    double? playbackSpeed,
  }) async {
    try {
      // In a real implementation, we would save to a playback session data source
      // For now, we'll just update the audiobook with the new position
      final audiobook = await getAudiobookById(audiobookId);
      if (audiobook == null) {
        throw StorageException('Audiobook with ID $audiobookId not found');
      }

      final updatedAudiobook = audiobook.copyWith(
        lastPlayedAt: DateTime.now(),
        completed: position.inMilliseconds / audiobook.duration.inMilliseconds >= 0.95,
      );

      await updateAudiobook(updatedAudiobook);

      // If user is authenticated, sync the playback position
      if (_remoteDatasource != null) {
        try {
          // Create a playback session object and sync with remote
          // await _remoteDatasource!.uploadPlaybackSession(playbackSession);
        } catch (e) {
          print('Warning: Could not sync playback session to remote: $e');
          // Continue anyway, local storage is the primary source
        }
      }
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }
}
