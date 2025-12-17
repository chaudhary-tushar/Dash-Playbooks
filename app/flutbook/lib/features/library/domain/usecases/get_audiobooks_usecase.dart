// lib/features/library/domain/usecases/get_audiobooks_usecase.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/repositories/library_repository.dart';

class GetAudiobooksUseCase {
  /// Gets audiobooks with optional filtering and sorting
  Future<List<Audiobook>> execute({
    String? sortBy,
    bool sortAscending = true,
    bool? completed,
    bool? inProgress,
    String? title,
    String? author,
    int? limit,
  }) async {
    throw UnimplementedError();
  }
}

class GetAudiobooksUseCaseImpl implements GetAudiobooksUseCase {
  GetAudiobooksUseCaseImpl({required LibraryRepository repository})
    : _repository = repository;

  final LibraryRepository _repository;

  @override
  Future<List<Audiobook>> execute({
    String? sortBy,
    bool sortAscending = true,
    bool? completed,
    bool? inProgress,
    String? title,
    String? author,
    int? limit,
  }) async {
    return _repository.getAudiobooks(
      sortBy: sortBy,
      sortAscending: sortAscending,
      completed: completed,
      inProgress: inProgress,
      title: title,
      author: author,
      limit: limit,
    );
  }
}
