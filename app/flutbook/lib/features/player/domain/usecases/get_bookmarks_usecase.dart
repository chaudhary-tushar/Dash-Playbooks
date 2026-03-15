// lib/features/player/domain/usecases/get_bookmarks_usecase.dart
import 'package:flutbook/features/player/domain/entities/bookmark.dart';
import 'package:flutbook/features/player/domain/repositories/bookmark_repository.dart';

class GetBookmarksUsecase {
  GetBookmarksUsecase(this.repository);

  final BookmarkRepository repository;

  /// Gets all bookmarks for a specific audiobook
  Future<List<Bookmark>> call(String audiobookId) async {
    return repository.getBookmarksForAudiobook(audiobookId);
  }
}
