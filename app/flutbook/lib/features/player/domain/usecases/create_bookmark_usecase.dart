// lib/features/player/domain/usecases/create_bookmark_usecase.dart
import 'package:flutbook/features/player/domain/entities/bookmark.dart';
import 'package:flutbook/features/player/domain/repositories/bookmark_repository.dart';

class CreateBookmarkUsecase {
  CreateBookmarkUsecase(this.repository);

  final BookmarkRepository repository;

  /// Creates a new bookmark for the specified audiobook
  Future<Bookmark> call({
    required String audiobookId,
    required Duration timestamp,
    String? note,
    String? chapterId,
  }) async {
    return repository.createBookmark(
      audiobookId: audiobookId,
      timestamp: timestamp,
      note: note,
      chapterId: chapterId,
    );
  }
}
