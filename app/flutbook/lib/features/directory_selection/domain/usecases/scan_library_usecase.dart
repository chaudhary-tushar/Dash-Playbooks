// lib/domain/usecases/scan_library_usecase.dart

import '../../data/datasources/metadat_extractor_ds.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';

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

class ScanLibraryUseCaseImpl implements ScanLibraryUseCase {
  const ScanLibraryUseCaseImpl({
    required this.extractor,
  });

  final MetadataExtractionDatasource extractor;

  @override
  Future<ScanResult> execute(String directoryPath) async {
    final stopwatch = Stopwatch()..start();
    final List<String> errors = <String>[];
    try {
      final audiobooks = await extractor.scanDirectory(directoryPath);
      stopwatch.stop();
      return ScanResult(
        scannedFiles: audiobooks.length,
        elapsedTime: stopwatch.elapsed,
        errors: errors,
        totalSize: audiobooks.fold<int>(0, (sum, audiobook) => sum + audiobook.totalSize),
        scanCompletedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      errors.add(e.toString());
      if (stackTrace != null) {
        errors.add(stackTrace.toString());
      }
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
