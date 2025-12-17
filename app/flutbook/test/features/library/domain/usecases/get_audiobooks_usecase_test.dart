// test/features/library/domain/usecases/get_audiobooks_usecase_test.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/repositories/library_repository.dart';
import 'package:flutbook/features/library/domain/usecases/get_audiobooks_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late GetAudiobooksUseCase useCase;
  late MockLibraryRepository mockRepository;

  setUp(() {
    mockRepository = MockLibraryRepository();
    useCase = GetAudiobooksUseCaseImpl(repository: mockRepository);
  });

  // Test data
  final testAudiobooks = [
    Audiobook(
      id: '1',
      title: 'Book A',
      author: 'Author X',
      album: 'Album 1',
      duration: const Duration(hours: 1),
      filePath: '/path/to/book1.mp3',
      chapters: [],
      createdAt: DateTime(2023),
      completed: false,
      totalSize: 1000000,
      lastPlayedAt: DateTime(2023, 1, 15),
    ),
    Audiobook(
      id: '2',
      title: 'Book B',
      author: 'Author Y',
      album: 'Album 2',
      duration: const Duration(hours: 2),
      filePath: '/path/to/book2.mp3',
      chapters: [],
      createdAt: DateTime(2023, 2),
      completed: true,
      totalSize: 2000000,
      lastPlayedAt: DateTime(2023, 2, 20),
    ),
    Audiobook(
      id: '3',
      title: 'Book C',
      author: 'Author X',
      album: 'Album 3',
      duration: const Duration(hours: 1, minutes: 30),
      filePath: '/path/to/book3.mp3',
      chapters: [],
      createdAt: DateTime(2023, 3),
      completed: false,
      totalSize: 1500000,
    ),
  ];

  group('GetAudiobooksUseCase.execute', () {
    test('should return all audiobooks when no parameters provided', () async {
      // Arrange
      when(
        () => mockRepository.getAudiobooks(),
      ).thenAnswer((_) async => testAudiobooks);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, 3);
      expect(result, testAudiobooks);
      verify(() => mockRepository.getAudiobooks()).called(1);
    });

    test('should return filtered audiobooks by title', () async {
      // Arrange
      when(
        () => mockRepository.getAudiobooks(title: 'Book A'),
      ).thenAnswer((_) async => [testAudiobooks[0]]);

      // Act
      final result = await useCase.execute(title: 'Book A');

      // Assert
      expect(result.length, 1);
      expect(result.first.title, 'Book A');
      verify(() => mockRepository.getAudiobooks(title: 'Book A')).called(1);
    });

    test('should return filtered audiobooks by author', () async {
      // Arrange
      when(
        () => mockRepository.getAudiobooks(author: 'Author X'),
      ).thenAnswer((_) async => [testAudiobooks[0], testAudiobooks[2]]);

      // Act
      final result = await useCase.execute(author: 'Author X');

      // Assert
      expect(result.length, 2);
      expect(result.every((book) => book.author == 'Author X'), true);
      verify(() => mockRepository.getAudiobooks(author: 'Author X')).called(1);
    });

    test('should return filtered audiobooks by completed status', () async {
      // Arrange
      when(
        () => mockRepository.getAudiobooks(completed: true),
      ).thenAnswer((_) async => [testAudiobooks[1]]);

      // Act
      final result = await useCase.execute(completed: true);

      // Assert
      expect(result.length, 1);
      expect(result.first.completed, true);
      verify(() => mockRepository.getAudiobooks(completed: true)).called(1);
    });

    test('should return filtered audiobooks by inProgress status', () async {
      // Arrange
      when(
        () => mockRepository.getAudiobooks(inProgress: true),
      ).thenAnswer((_) async => [testAudiobooks[0]]);

      // Act
      final result = await useCase.execute(inProgress: true);

      // Assert
      expect(result.length, 1);
      expect(result.first.title, 'Book A');
      verify(() => mockRepository.getAudiobooks(inProgress: true)).called(1);
    });

    test('should return sorted audiobooks by title ascending', () async {
      // Arrange
      final sortedBooks = [
        testAudiobooks[0],
        testAudiobooks[1],
        testAudiobooks[2],
      ];
      when(
        () => mockRepository.getAudiobooks(sortBy: 'title'),
      ).thenAnswer((_) async => sortedBooks);

      // Act
      final result = await useCase.execute(sortBy: 'title');

      // Assert
      expect(result.length, 3);
      expect(result[0].title, 'Book A');
      expect(result[1].title, 'Book B');
      expect(result[2].title, 'Book C');
      verify(() => mockRepository.getAudiobooks(sortBy: 'title')).called(1);
    });

    test('should return sorted audiobooks by title descending', () async {
      // Arrange
      final sortedBooks = [
        testAudiobooks[2],
        testAudiobooks[1],
        testAudiobooks[0],
      ];
      when(
        () =>
            mockRepository.getAudiobooks(sortBy: 'title', sortAscending: false),
      ).thenAnswer((_) async => sortedBooks);

      // Act
      final result = await useCase.execute(
        sortBy: 'title',
        sortAscending: false,
      );

      // Assert
      expect(result.length, 3);
      expect(result[0].title, 'Book C');
      expect(result[1].title, 'Book B');
      expect(result[2].title, 'Book A');
      verify(
        () =>
            mockRepository.getAudiobooks(sortBy: 'title', sortAscending: false),
      ).called(1);
    });

    test('should return sorted audiobooks by author', () async {
      // Arrange
      final sortedBooks = [
        testAudiobooks[0],
        testAudiobooks[2],
        testAudiobooks[1],
      ];
      when(
        () => mockRepository.getAudiobooks(sortBy: 'author'),
      ).thenAnswer((_) async => sortedBooks);

      // Act
      final result = await useCase.execute(sortBy: 'author');

      // Assert
      expect(result.length, 3);
      expect(result[0].author, 'Author X');
      expect(result[1].author, 'Author X');
      expect(result[2].author, 'Author Y');
      verify(() => mockRepository.getAudiobooks(sortBy: 'author')).called(1);
    });

    test('should return sorted audiobooks by dateAdded', () async {
      // Arrange
      final sortedBooks = [
        testAudiobooks[0],
        testAudiobooks[1],
        testAudiobooks[2],
      ];
      when(
        () => mockRepository.getAudiobooks(sortBy: 'dateAdded'),
      ).thenAnswer((_) async => sortedBooks);

      // Act
      final result = await useCase.execute(sortBy: 'dateAdded');

      // Assert
      expect(result.length, 3);
      expect(result[0].title, 'Book A');
      expect(result[1].title, 'Book B');
      expect(result[2].title, 'Book C');
      verify(() => mockRepository.getAudiobooks(sortBy: 'dateAdded')).called(1);
    });

    test('should return sorted audiobooks by progress', () async {
      // Arrange
      final sortedBooks = [
        testAudiobooks[1],
        testAudiobooks[0],
        testAudiobooks[2],
      ];
      when(
        () => mockRepository.getAudiobooks(
          sortBy: 'progress',
          sortAscending: false,
        ),
      ).thenAnswer((_) async => sortedBooks);

      // Act
      final result = await useCase.execute(
        sortBy: 'progress',
        sortAscending: false,
      );

      // Assert
      expect(result.length, 3);
      expect(result[0].completed, true);
      expect(result[1].title, 'Book A');
      expect(result[2].title, 'Book C');
      verify(
        () => mockRepository.getAudiobooks(
          sortBy: 'progress',
          sortAscending: false,
        ),
      ).called(1);
    });

    test('should return limited number of audiobooks', () async {
      // Arrange
      final limitedBooks = [testAudiobooks[0], testAudiobooks[1]];
      when(
        () => mockRepository.getAudiobooks(limit: 2),
      ).thenAnswer((_) async => limitedBooks);

      // Act
      final result = await useCase.execute(limit: 2);

      // Assert
      expect(result.length, 2);
      verify(() => mockRepository.getAudiobooks(limit: 2)).called(1);
    });

    test('should return empty list when no audiobooks found', () async {
      // Arrange
      when(
        () => mockRepository.getAudiobooks(),
      ).thenAnswer((_) async => []);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getAudiobooks()).called(1);
    });

    test('should combine multiple filters and sorting', () async {
      // Arrange
      final filteredBooks = [testAudiobooks[0], testAudiobooks[2]];
      when(
        () => mockRepository.getAudiobooks(
          author: 'Author X',
          completed: false,
          sortBy: 'title',
        ),
      ).thenAnswer((_) async => filteredBooks);

      // Act
      final result = await useCase.execute(
        author: 'Author X',
        completed: false,
        sortBy: 'title',
      );

      // Assert
      expect(result.length, 2);
      expect(result[0].title, 'Book A');
      expect(result[1].title, 'Book C');
      verify(
        () => mockRepository.getAudiobooks(
          author: 'Author X',
          completed: false,
          sortBy: 'title',
        ),
      ).called(1);
    });

    test('should handle repository exceptions', () async {
      // Arrange
      when(
        () => mockRepository.getAudiobooks(),
      ).thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase.execute(),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.getAudiobooks()).called(1);
    });
  });
}
