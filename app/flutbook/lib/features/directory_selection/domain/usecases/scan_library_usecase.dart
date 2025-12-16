// lib/domain/usecases/scan_library_usecase.dart

import 'package:flutbook/features/directory_selection/data/datasources/metadat_extractor_ds.dart';
import 'package:flutbook/features/library/data/datasources/audiobook_local_ds.dart';

abstract class ScanLibraryUseCase {
  /// Scans a directory and updates the local library
  Future<ScanResult> execute(String directoryPath);
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
      final audiobooks = <dynamic>[];

      // Step 2: Extract metadata for each file, collecting errors for individual files
      for (final filePath in audioFiles) {
        try {
          final audiobook = await extractor.extractMetadata(filePath);
          if (audiobook != null) {
            audiobooks.add(audiobook);
          }
        } catch (e) {
          // Log individual file errors but continue processing
          errors.add('Failed to extract metadata from $filePath: $e');
        }
      }

      // Step 3: Save all successfully extracted audiobooks to database
      if (audiobooks.isNotEmpty) {
        await localDatasource.saveAudiobooks(audiobooks.cast());
      }

      stopwatch.stop();
      final totalSize = audiobooks.fold<int>(
        0,
        (sum, audiobook) => sum + (audiobook.totalSize as int),
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
