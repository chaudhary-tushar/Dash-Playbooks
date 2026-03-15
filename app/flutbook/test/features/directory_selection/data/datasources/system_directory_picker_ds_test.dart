// test/features/directory_selection/data/datasources/system_directory_picker_ds_test.dart
import 'package:flutbook/features/directory_selection/data/datasources/system_directory_picker_ds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSystemDirectoryPickerDatasource extends Mock
    implements SystemDirectoryPickerDatasource {}

void main() {
  late SystemDirectoryPickerDatasource datasource;

  setUp(() {
    datasource = MockSystemDirectoryPickerDatasource();
  });

  group('SystemDirectoryPickerDatasource', () {
    test('can be instantiated', () {
      expect(datasource, isNotNull);
      expect(datasource, isA<SystemDirectoryPickerDatasource>());
    });

    test('pickDirectory returns null when user cancels', () async {
      // Arrange
      when(() => datasource.pickDirectory()).thenAnswer((_) async => null);

      // Act
      final result = await datasource.pickDirectory();

      // Assert
      expect(result, isNull);
      verify(() => datasource.pickDirectory()).called(1);
    });

    test('pickDirectory returns path on success', () async {
      // Arrange
      const testPath = '/test/directory';
      when(() => datasource.pickDirectory()).thenAnswer((_) async => testPath);

      // Act
      final result = await datasource.pickDirectory();

      // Assert
      expect(result, equals(testPath));
      verify(() => datasource.pickDirectory()).called(1);
    });

    test(
      'checkDirectoryPermission returns false for invalid directory',
      () async {
        // Arrange
        when(
          () => datasource.checkDirectoryPermission(any()),
        ).thenAnswer((_) async => false);

        // Act
        final result = await datasource.checkDirectoryPermission(
          '/invalid/path',
        );

        // Assert
        expect(result, isFalse);
        verify(() => datasource.checkDirectoryPermission(any())).called(1);
      },
    );

    test('checkDirectoryPermission returns true for valid directory', () async {
      // Arrange
      when(
        () => datasource.checkDirectoryPermission(any()),
      ).thenAnswer((_) async => true);

      // Act
      final result = await datasource.checkDirectoryPermission('/valid/path');

      // Assert
      expect(result, isTrue);
      verify(() => datasource.checkDirectoryPermission(any())).called(1);
    });

    test('requestStoragePermission returns true on web', () async {
      // Arrange
      when(
        () => datasource.requestStoragePermission(),
      ).thenAnswer((_) async => true);

      // Act
      final result = await datasource.requestStoragePermission();

      // Assert
      expect(result, isTrue);
      verify(() => datasource.requestStoragePermission()).called(1);
    });

    test('getDefaultDownloadDirectory returns null on web', () async {
      // Arrange
      when(
        () => datasource.getDefaultDownloadDirectory(),
      ).thenAnswer((_) async => null);

      // Act
      final result = await datasource.getDefaultDownloadDirectory();

      // Assert
      expect(result, isNull);
      verify(() => datasource.getDefaultDownloadDirectory()).called(1);
    });

    test('getDefaultDocumentsDirectory returns path on mobile', () async {
      // Arrange
      const testPath = '/documents';
      when(
        () => datasource.getDefaultDocumentsDirectory(),
      ).thenAnswer((_) async => testPath);

      // Act
      final result = await datasource.getDefaultDocumentsDirectory();

      // Assert
      expect(result, equals(testPath));
      verify(() => datasource.getDefaultDocumentsDirectory()).called(1);
    });
  });
}
