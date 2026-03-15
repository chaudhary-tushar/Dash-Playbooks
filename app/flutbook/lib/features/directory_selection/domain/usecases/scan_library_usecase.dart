// lib/domain/usecases/scan_library_usecase.dart

import 'package:flutbook/features/directory_selection/data/datasources/metadat_extractor_ds.dart';
import 'package:flutbook/features/library/data/datasources/audiobook_local_ds.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';

class ScanLibraryUseCase {
  /// Scans a directory and updates the local library
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

/// Orchestrates the scanning process: extract metadata → save to database → return result.
///
/// This use case receives clean dependencies with no circular relationships:
/// - MetadataExtractionDatasource handles file scanning and metadata extraction
/// - AudiobookLocalDatasource handles database storage
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
      // Step 1: Scan directory and extract metadata from all audio files
      final audioFiles = await extractor.scanDirectoryForAudioFiles(directoryPath);
      final audiobooks = <Audiobook>[];

      // Step 2: Extract metadata for each file, collecting errors for individual files
      for (final filePath in audioFiles) {
        try {
          final Audiobook? audiobook = await extractor.extractMetadata(filePath);
          if (audiobook != null) {
            // Check if this audiobook already exists in the database based on file path
            final exists = await localDatasource.audiobookExistsByFilePath(filePath);
            if (!exists) {
              audiobooks.add(audiobook);
            } else {
              print('Audiobook already exists in database: $filePath');
            }
          }
        } catch (e) {
          // Log individual file errors but continue processing
          errors.add('Failed to extract metadata from $filePath: $e');
        }
      }

      // Step 3: Get all audiobooks in the database that are in the scanned directory
      final allAudiobooksInDb = await localDatasource.getAudiobooks();
      final audiobooksInScannedDir = allAudiobooksInDb
          .where((audiobook) => audiobook.filePath.startsWith(directoryPath))
          .toList();

      // Step 4: Identify audiobooks that are in the database but no longer in the directory
      final audiobooksToRemove = <Audiobook>[];
      for (final dbAudiobook in audiobooksInScannedDir) {
        final stillExists = audioFiles.any((filePath) => filePath == dbAudiobook.filePath);
        if (!stillExists) {
          // Check if file actually exists on disk before marking as missing
          if (!await extractor.isFileAccessible(dbAudiobook.filePath)) {
            audiobooksToRemove.add(dbAudiobook);
          }
        }
      }

      // Step 5: Remove audiobooks that are no longer in the directory
      for (final audiobook in audiobooksToRemove) {
        await localDatasource.deleteAudiobook(audiobook.id);
        print('Removed audiobook no longer in directory: ${audiobook.filePath}');
      }

      // Step 6: Save all newly found audiobooks to database
      if (audiobooks.isNotEmpty) {
        await localDatasource.saveAudiobooks(audiobooks);
      }

      stopwatch.stop();
      final totalSize = audiobooks.fold<int>(
        0,
        (sum, audiobook) => sum + audiobook.totalSize,
      );

      return ScanResult(
        scannedFiles: audiobooks.length,
        elapsedTime: stopwatch.elapsed,
        errors: errors,
        totalSize: totalSize,
        scanCompletedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      errors
        ..add('Scan failed: $e')
        ..add(stackTrace.toString());

      stopwatch.stop();
      return ScanResult(
        scannedFiles: 0,
        elapsedTime: stopwatch.elapsed,
        errors: errors,
        totalSize: 0,
        scanCompletedAt: DateTime.now(),
      );
    }
  }
}
