// lib/domain/usecases/scan_library_usecase.dart

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
