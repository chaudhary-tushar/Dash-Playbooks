// lib/features/player/data/models/bookmark_model.dart
import 'package:flutbook/features/player/domain/entities/bookmark.dart'
    as domain;
import 'package:isar_community/isar.dart';

part 'bookmark_model.g.dart';

@collection
class BookmarkModel {
  // Empty constructor for Isar
  BookmarkModel();

  // Constructor from domain entity
  BookmarkModel.fromDomain(domain.Bookmark bookmark) {
    id = bookmark.id;
    audiobookId = bookmark.audiobookId;
    timestamp = bookmark.timestamp.inMilliseconds;
    createdAt = bookmark.createdAt;
    note = bookmark.note;
    chapterId = bookmark.chapterId;
  }
  Id id = Isar.autoIncrement;

  @Index()
  late String audiobookId;

  late int timestamp; // Duration in milliseconds

  late DateTime createdAt;

  String? note;

  @Index(composite: [CompositeIndex('audiobookId')])
  String? chapterId;

  // Convert to domain entity
  domain.Bookmark toDomain() {
    return domain.Bookmark(
      id: id,
      audiobookId: audiobookId,
      timestamp: Duration(milliseconds: timestamp),
      createdAt: createdAt,
      note: note,
      chapterId: chapterId,
    );
  }
}
