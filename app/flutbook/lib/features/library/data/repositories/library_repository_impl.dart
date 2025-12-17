// lib/data/repositories/library_repository_impl.dart
// import 'package:flutbook/data/providers/library_provider.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/library/data/datasources/audiobook_local_ds.dart';
import 'package:flutbook/features/library/data/datasources/remote/firebase_library_sync.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/library.dart';
import 'package:flutbook/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl({
    required AudiobookLocalDatasource localDatasource,
    // required LibraryProvider provider,
    LibraryRemoteDatasource? remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource;
  //  _provider = provider;
  final AudiobookLocalDatasource _localDatasource;
  final LibraryRemoteDatasource? _remoteDatasource;
  // final LibraryProvider _provider;

  @override
  Future<Library> getLibrary() async {
    try {
      final audiobooks = await _localDatasource.getAudiobooks();
      final totalDuration = audiobooks.fold(
        Duration.zero,
        (sum, book) => sum + book.duration,
      );

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
    // NOTE: Directory scanning is now handled by ScanLibraryUseCase
    // This method is deprecated and should not be called directly
    // Use ScanLibraryUseCase.execute() instead
    throw UnimplementedError(
      'Use ScanLibraryUseCase.execute() instead of LibraryRepository.scanDirectory()',
    );
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

  Future<String> _getLibraryPath() async {
    try {
      // Get library path from settings
      final settings = await _localDatasource.getSettings();
      return settings['library_path'] as String;
    } catch (e) {
      // If getting settings fails, return null
      print('Warning: Could not get library path from settings: $e');
      return 'None';
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
  // @override
  // Future<List<Audiobook>> searchInLibrary(String query) async {
  //   try {
  //     return await _localDatasource.searchAudiobooks(query);
  //   } catch (e) {
  //     throw StorageException(ErrorHandler.handleException(e));
  //   }
  // }

  /// Filters audiobooks in the library
  // @override
  // Future<List<Audiobook>> filterInLibrary(AudiobookFilter filter) async {
  //   try {
  //     return await _localDatasource.filterAudiobooks(filter);
  //   } catch (e) {
  //     throw StorageException(ErrorHandler.handleException(e));
  //   }
  // }

  @override
  Future<bool> isLibraryPathAccessible() async {
    try {
      final path = await getLibraryPath();
      if (path == null) return false;
      // File existence checks should be done by MetadataExtractionDatasource
      // For now, just verify we have a path
      return path.isNotEmpty;
    } catch (e) {
      // If we can't check, assume it's not accessible
      return false;
    }
  }

  @override
  Future<List<Audiobook>> filterInLibrary(AudiobookFilter filter) {
    // TODO: implement filterInLibrary
    throw UnimplementedError();
  }

  @override
  Future<String?> getLibraryPath() {
    // TODO: implement getLibraryPath
    throw UnimplementedError();
  }

  // Cache for audiobooks to improve performance
  List<Audiobook>? _audiobooksCache;
  DateTime? _cacheTimestamp;

  // Cache expiration time (5 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 5);

  @override
  Future<List<Audiobook>> getAudiobooks({
    String? sortBy,
    bool sortAscending = true,
    bool? completed,
    bool? inProgress,
    String? title,
    String? author,
    int? limit,
  }) async {
    try {
      // Check if cache is valid
      if (_audiobooksCache == null ||
          _cacheTimestamp == null ||
          DateTime.now().difference(_cacheTimestamp!) > _cacheExpiration) {
        // Cache expired or doesn't exist, fetch from datasource
        _audiobooksCache = await _localDatasource.getAudiobooks();
        _cacheTimestamp = DateTime.now();
      }

      // Handle empty library case
      if (_audiobooksCache!.isEmpty) {
        print('Info: Library is empty - no audiobooks found');
        return [];
      }

      // Start with cached audiobooks
      var result = List<Audiobook>.from(_audiobooksCache!);

      // Apply title filter if provided
      if (title != null && title.isNotEmpty) {
        result = result
            .where(
              (book) => book.title.toLowerCase().contains(title.toLowerCase()),
            )
            .toList();
      }

      // Apply author filter if provided
      if (author != null && author.isNotEmpty) {
        result = result
            .where(
              (book) =>
                  book.author.toLowerCase().contains(author.toLowerCase()),
            )
            .toList();
      }

      // Apply completed filter if provided
      if (completed != null) {
        result = result.where((book) => book.completed == completed).toList();
      }

      // Apply inProgress filter if provided
      if (inProgress != null) {
        if (inProgress) {
          // In progress means not completed but has been played
          result = result
              .where((book) => !book.completed && book.lastPlayedAt != null)
              .toList();
        } else {
          // Not in progress means either completed or never played
          result = result
              .where((book) => book.completed || book.lastPlayedAt == null)
              .toList();
        }
      }

      // Apply sorting
      if (sortBy != null && sortBy.isNotEmpty) {
        result.sort((a, b) {
          switch (sortBy) {
            case 'title':
              return sortAscending
                  ? a.title.compareTo(b.title)
                  : b.title.compareTo(a.title);
            case 'author':
              return sortAscending
                  ? a.author.compareTo(b.author)
                  : b.author.compareTo(a.author);
            case 'lastPlayed':
              // Handle null lastPlayedAt by sorting them to the end
              if (a.lastPlayedAt == null && b.lastPlayedAt == null) return 0;
              if (a.lastPlayedAt == null) return sortAscending ? 1 : -1;
              if (b.lastPlayedAt == null) return sortAscending ? -1 : 1;
              return sortAscending
                  ? a.lastPlayedAt!.compareTo(b.lastPlayedAt!)
                  : b.lastPlayedAt!.compareTo(a.lastPlayedAt!);
            case 'dateAdded':
              return sortAscending
                  ? a.createdAt.compareTo(b.createdAt)
                  : b.createdAt.compareTo(a.createdAt);
            case 'progress':
              // Calculate progress as percentage
              final progressA = _calculateProgress(a);
              final progressB = _calculateProgress(b);
              return sortAscending
                  ? progressA.compareTo(progressB)
                  : progressB.compareTo(progressA);
            default:
              // Default to title sorting
              return sortAscending
                  ? a.title.compareTo(b.title)
                  : b.title.compareTo(a.title);
          }
        });
      }

      // Apply limit if provided
      if (limit != null && limit > 0 && result.length > limit) {
        result = result.sublist(0, limit);
      }

      return result;
    } catch (e) {
      throw StorageException(ErrorHandler.handleException(e));
    }
  }

  /// Calculates progress percentage for an audiobook
  /// Returns 0 for books never played, 100 for completed books
  double _calculateProgress(Audiobook audiobook) {
    if (audiobook.completed) return 100;
    if (audiobook.lastPlayedAt == null) return 0;

    // For simplicity, we'll calculate based on last played position
    // In a real implementation, this would come from playback tracking
    // For now, we'll use a simple heuristic based on lastPlayedAt
    final durationMs = audiobook.duration.inMilliseconds;
    if (durationMs <= 0) return 0;

    // Calculate time since last played as a proxy for progress
    final timeSinceLastPlayed = DateTime.now().difference(
      audiobook.lastPlayedAt!,
    );
    final hoursSinceLastPlayed = timeSinceLastPlayed.inHours;

    // Simple heuristic: assume 1 hour of listening = 10% progress, capped at 99%
    final progress = (hoursSinceLastPlayed * 10).toDouble().clamp(0.0, 99.0);
    return progress;
  }

  @override
  Future<List<Audiobook>> searchInLibrary(String query) {
    // TODO: implement searchInLibrary
    throw UnimplementedError();
  }
}
