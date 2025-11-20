// lib/data/repositories/library_repository_impl.dart
import 'package:flutbook/data/datasources/local/audiobook_local_datasource.dart';
import 'package:flutbook/data/datasources/remote/firebase_sync_datasource.dart';
import 'package:flutbook/data/providers/library_provider.dart';
import 'package:flutbook/data/repositories/audiobook_repository_impl.dart';
import 'package:flutbook/data/repositories/error_handler.dart';
import 'package:flutbook/domain/entities/audiobook.dart';
import 'package:flutbook/domain/entities/library.dart';
import 'package:flutbook/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl({
    required AudiobookLocalDatasource localDatasource,
    required LibraryProvider provider,
    FirebaseSyncDatasource? remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource,
       _provider = provider;
  final AudiobookLocalDatasource _localDatasource;
  final FirebaseSyncDatasource? _remoteDatasource;
  final LibraryProvider _provider;

  @override
  Future<Library> getLibrary() async {
    try {
      final audiobooks = await _localDatasource.getAudiobooks();
      final totalDuration = audiobooks.fold(Duration.zero, (sum, book) => sum + book.duration);

      return Library(
        id: 'default_library', // For now, using a default library ID
        name: 'My Library',
        path: await _getLibraryPath(), // Would get from settings
        audiobooks: audiobooks,
        lastScanAt: DateTime.now(),
        totalAudiobooks: audiobooks.length,
        totalDuration: totalDuration,
      );
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Library> scanDirectory(String directoryPath) async {
    try {
      // First, use the local datasource to scan and extract audiobooks
      final audiobooks = await _localDatasource.scanDirectory(directoryPath);

      // Save to local storage
      await _localDatasource.saveAudiobooks(audiobooks);

      // If user is authenticated, consider syncing library changes
      if (_remoteDatasource != null) {
        try {
          // For each audiobook, upload its metadata to remote
          for (final audiobook in audiobooks) {
            await _remoteDatasource.uploadAudiobookMetadata(audiobook);
          }
        } catch (e) {
          print('Warning: Could not sync library changes to remote: $e');
          // Continue anyway, local storage is the primary source
        }
      }

      // Calculate total duration for the library
      final totalDuration = audiobooks.fold(Duration.zero, (sum, book) => sum + book.duration);

      return Library(
        id: 'default_library',
        name: 'My Library',
        path: directoryPath,
        audiobooks: audiobooks,
        lastScanAt: DateTime.now(),
        totalAudiobooks: audiobooks.length,
        totalDuration: totalDuration,
      );
    } catch (e) {
      throw FileSystemException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Library> updateLibrary(Library library) async {
    try {
      // In this implementation, a library is essentially a collection of audiobooks
      // and metadata about the library itself. We'll save all audiobooks.
      await _localDatasource.saveAudiobooks(library.audiobooks);

      // If authenticated, sync changes to remote
      if (_remoteDatasource != null) {
        try {
          await _remoteDatasource.syncAll();
        } catch (e) {
          print('Warning: Could not sync library updates to remote: $e');
          // Continue anyway, local storage is primary
        }
      }

      return library.copyWith(
        lastScanAt: DateTime.now(),
      );
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<void> deleteAudiobookFromLibrary(String audiobookId) async {
    try {
      // This would remove the audiobook from the library but not delete the actual file
      await _localDatasource.deleteAudiobook(audiobookId);

      // If authenticated, sync deletion
      if (_remoteDatasource != null) {
        try {
          await _remoteDatasource.deleteAudiobookMetadata(audiobookId);
        } catch (e) {
          print('Warning: Could not sync audiobook deletion to remote: $e');
          // Continue anyway
        }
      }
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<String?> getLibraryPath() async {
    try {
      // Get library path from settings
      final settings = await _localDatasource.getSettings();
      return settings['library_path'];
    } catch (e) {
      // If getting settings fails, return null
      print('Warning: Could not get library path from settings: $e');
      return null;
    }
  }

  @override
  Future<void> setLibraryPath(String path) async {
    try {
      // Save library path to settings
      final settings = await _localDatasource.getSettings();
      settings['library_path'] = path;
      await _localDatasource.saveSettings(settings);
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  /// Gets statistics about the library
  @override
  Future<LibraryStats> getLibraryStats() async {
    try {
      final library = await getLibrary();

      final numInProgress = library.audiobooks
          .where((a) => !a.completed && a.lastPlayedAt != null)
          .length;
      final numCompleted = library.audiobooks.where((a) => a.completed).length;
      final numNotStarted = library.audiobooks
          .where((a) => !a.completed && a.lastPlayedAt == null)
          .length;

      return LibraryStats(
        totalBooks: library.totalAudiobooks,
        inProgress: numInProgress,
        completed: numCompleted,
        notStarted: numNotStarted,
        totalDuration: library.totalDuration,
      );
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  /// Searches audiobooks in the library
  @override
  Future<List<Audiobook>> searchInLibrary(String query) async {
    try {
      return await _localDatasource.searchAudiobooks(query);
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  /// Filters audiobooks in the library
  @override
  Future<List<Audiobook>> filterInLibrary(AudiobookFilter filter) async {
    try {
      return await _localDatasource.filterAudiobooks(filter);
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  /// Checks if library directory is still accessible
  @override
  Future<bool> isLibraryPathAccessible() async {
    try {
      final path = await getLibraryPath();
      if (path == null) return false;

      return await _localDatasource.isFileAccessible(path);
    } catch (e) {
      // If we can't check, assume it's not accessible
      return false;
    }
  }
}

/// Statistics about the library
class LibraryStats {
  const LibraryStats({
    required this.totalBooks,
    required this.inProgress,
    required this.completed,
    required this.notStarted,
    required this.totalDuration,
  });
  final int totalBooks;
  final int inProgress;
  final int completed;
  final int notStarted;
  final Duration totalDuration;
}
