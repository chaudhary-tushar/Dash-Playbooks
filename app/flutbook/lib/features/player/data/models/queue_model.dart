// lib/features/player/data/models/queue_model.dart
import 'package:flutbook/features/player/domain/entities/queue.dart' as domain;
import 'package:isar_community/isar.dart';

part 'queue_model.g.dart';

@collection
class QueueModel {
  // Empty constructor for Isar
  QueueModel();

  // Constructor from domain entity
  QueueModel.fromDomain(domain.Queue queue) {
    id = queue.id;
    name = queue.name;
    audiobookIds = queue.audiobookIds;
    createdAt = queue.createdAt;
    updatedAt = queue.updatedAt;
    isDefault = queue.isDefault;
    currentIndex = queue.currentIndex;
  }

  Id id = Isar.autoIncrement;

  late String name;

  late List<String> audiobookIds;

  late DateTime createdAt;

  late DateTime updatedAt;

  late bool isDefault;

  late int currentIndex;

  // Convert to domain entity
  domain.Queue toDomain() {
    return domain.Queue(
      id: id,
      name: name,
      audiobookIds: audiobookIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDefault: isDefault,
      currentIndex: currentIndex,
    );
  }
}
