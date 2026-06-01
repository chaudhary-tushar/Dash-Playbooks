// lib/domain/usecases/scan_library_usecase.dart

import 'package:flutbook/features/directory_selection/data/datasources/metadat_extractor_ds.dart';
import 'package:flutbook/features/library/data/datasources/audiobook_local_ds.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class ScanLibraryUseCase {
  /// Scans a directory and updates the local library.
  Future<ScanResult> execute(String directoryPath) async {
    throw UnimplementedError();
  }
}

class ScanResult {
  const ScanResult({
    required this.scannedFiles,
    required this.elapsedTime,
    required this.errors,
    required this.totalSize,
    required this.scanCompletedAt,
  });
  final int scannedFiles;
  final Duration elapsedTime;
  final List<String> errors;
  final int totalSize;
  final DateTime scanCompletedAt;

  bool get hasErrors => errors.isNotEmpty;
  bool get success => !hasErrors;
}

/// Orchestrates scanning: groups files by directory → extract metadata → save.
///
/// Strategy:
/// - Audio files found directly in the scanned root directory are treated as
///   individual audiobooks (one per file). This handles standalone .mp3 files.
/// - Audio files found inside subdirectories are grouped together and become
///   a single audiobook whose title is the subdirectory name. This is the
///   standard multi-file audiobook layout (e.g. "The Hobbit/" with 20 MP3s).
class ScanLibraryUseCaseImpl implements ScanLibraryUseCase {
  const ScanLibraryUseCaseImpl({
    required this.extractor,
    required this.localDatasource,
  });

  final MetadataExtractionDatasource extractor;
  final AudiobookLocalDatasource localDatasource;

  @override
  Future<ScanResult> execute(String directoryPath) async {
    final stopwatch = Stopwatch()..start();
    final errors = <String>[];

    try {
      // 1. Find all audio files recursively.
      final audioFiles = await extractor.scanDirectoryForAudioFiles(directoryPath);

      // 2. Group files by immediate parent directory.
      final filesByDir = <String, List<String>>{};
      for (final filePath in audioFiles) {
        final dir = path.dirname(filePath);
        filesByDir.putIfAbsent(dir, () => []).add(filePath);
      }

      final newAudiobooks = <Audiobook>[];

      // 3. For each directory group, produce one Audiobook.
      for (final entry in filesByDir.entries) {
        final dirPath = entry.key;
        final files = entry.value;

        // Files directly in the scanned root → one Audiobook per file.
        if (dirPath == directoryPath) {
          for (final filePath in files) {
            try {
              final exists = await localDatasource.audiobookExistsByFilePath(filePath);
              if (exists) continue;

              final audiobook = await extractor.extractMetadata(filePath);
              if (audiobook != null) newAudiobooks.add(audiobook);
            } catch (e) {
              errors.add('Failed to extract metadata from $filePath: $e');
            }
          }
        } else {
          // Files inside a subdirectory → one Audiobook for the whole directory.
          try {
            final dirId = extractor.generateDirectoryId(dirPath);
            final exists = await localDatasource.audiobookExistsById(dirId);
            if (exists) continue;

            final audiobook = await extractor.extractDirectoryMetadata(dirPath, files);
            if (audiobook != null) newAudiobooks.add(audiobook);
          } catch (e) {
            errors.add('Failed to extract directory metadata from $dirPath: $e');
          }
        }
      }

      // 4. Remove database records whose files no longer exist on disk.
      await _pruneDeletedAudiobooks(directoryPath, audioFiles);

      // 5. Persist new audiobooks.
      if (newAudiobooks.isNotEmpty) {
        await localDatasource.saveAudiobooks(newAudiobooks);
      }

      stopwatch.stop();
      final totalSize = newAudiobooks.fold<int>(0, (sum, a) => sum + a.totalSize);

      return ScanResult(
        scannedFiles: newAudiobooks.length,
        elapsedTime: stopwatch.elapsed,
        errors: errors,
        totalSize: totalSize,
        scanCompletedAt: DateTime.now(),
      );
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint('Scan failed: $e\n$stack');
      return ScanResult(
        scannedFiles: 0,
        elapsedTime: stopwatch.elapsed,
        errors: [...errors, 'Scan failed: $e'],
        totalSize: 0,
        scanCompletedAt: DateTime.now(),
      );
    }
  }

  /// Deletes database records for audiobooks whose files are no longer present
  /// inside [directoryPath].
  Future<void> _pruneDeletedAudiobooks(
    String directoryPath,
    List<String> currentFiles,
  ) async {
    try {
      final allInDb = await localDatasource.getAudiobooks();
      final inScannedDir = allInDb.where(
        (a) => a.filePath.startsWith(directoryPath),
      );

      final currentFileSet = Set<String>.from(currentFiles);

      for (final audiobook in inScannedDir) {
        // For directory audiobooks the filePath is the first chapter file.
        // Consider it stale only when none of its chapter files remain.
        final hasLiveFile = audiobook.chapters.isNotEmpty
            ? audiobook.chapters.any(
                (c) => c.filePath != null && currentFileSet.contains(c.filePath),
              )
            : currentFileSet.contains(audiobook.filePath);

        if (!hasLiveFile) {
          // Double-check: the file truly gone (not just outside the scan dir).
          final accessible = await extractor.isFileAccessible(audiobook.filePath);
          if (!accessible) {
            await localDatasource.deleteAudiobook(audiobook.id);
            debugPrint('Removed stale audiobook: ${audiobook.filePath}');
          }
        }
      }
    } catch (e) {
      debugPrint('Warning: pruning stale audiobooks failed: $e');
    }
  }
}
