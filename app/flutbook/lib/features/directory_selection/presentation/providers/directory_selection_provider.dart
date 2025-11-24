
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedPathProvider = StateProvider<String?>((ref) => null);

final scanResultProvider = FutureProvider.family<ScanResult, String>((ref, path) async {
  // TODO: Integrate with ScanLibraryUseCase.execute(path)
  // Stub for now
  await Future.delayed(const Duration(seconds: 2));
  return const ScanResult(
    scannedFiles
