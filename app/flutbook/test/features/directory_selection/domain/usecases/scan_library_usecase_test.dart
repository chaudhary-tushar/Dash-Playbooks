import 'package:flutbook/features/directory_selection/data/datasources/metadat_extractor_ds.dart';
import 'package:flutbook/features/directory_selection/domain/usecases/scan_library_usecase.dart';
import 'package:flutbook/features/library/data/datasources/audiobook_local_ds.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMetadataExtractionDatasource extends Mock
    implements MetadataExtractionDatasource {}

class MockAudiobookLocalDatasource extends Mock
    implements AudiobookLocalDatasource {}

void main() {
  late ScanLibraryUseCaseImpl usecase;
  late MockMetadataExtractionDatasource mockExtractor;
  late MockAudiobookLocalDatasource mockLocalDatasource;

  setUp(() {
    mockExtractor = MockMetadataExtractionDatasource();
    mockLocalDatasource = MockAudiobookLocalDatasource();
    usecase = ScanLibraryUseCaseImpl(
      extractor: mockExtractor,
      localDatasource: mockLocalDatasource,
    );
  });

  group('ScanLibraryUseCaseImpl', () {
    test('should call scanDirectoryForAudioFiles and save audiobooks on successful scan', () async {
      const testPath = '/test/directory';
      const audioFiles = ['/test/file1.mp3', '/test/file2.m4a'];
      final mockAudiobook = Audiobook.empty().copyWith(
        id: 'test_id',
        title: 'Test Audiobook',
        filePath: '/test/file1.mp3',
      );

      when(() => mockExtractor.scanDirectoryForAudioFiles(testPath))
          .thenAnswer((_) async => audioFiles);
      when(() => mockExtractor.extractMetadata(any()))
          .thenAnswer((_) async => mockAudiobook);
      when(() => mockLocalDatasource.saveAudiobooks(any()))
          .thenAnswer((_) async => Future.value());

      final result = await usecase.execute(testPath);

      expect(result.scannedFiles, 2);
      expect(result.hasErrors, false);
    });
  });
}
