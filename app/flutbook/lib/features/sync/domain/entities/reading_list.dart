/// Reading list entity for organizing audiobooks.
///
/// Represents a custom list created by users to organize
/// their audiobooks (e.g., "Favorites", "To Listen", "Mystery").
library;

import 'package:equatable/equatable.dart';

/// Reading list entity.
class ReadingList extends Equatable {
  /// Create a new ReadingList.
  const ReadingList({
    required this.id,
    required this.name,
    required this.createdAt, this.description,
    this.audiobookIds = const [],
    this.updatedAt,
    this.order = 0,
  });

  /// Unique identifier for the list.
  final String id;

  /// Name of the list (e.g., "Favorites", "To Listen").
  final String name;

  /// Optional description of the list.
  final String? description;

  /// List of audiobook IDs in this reading list.
  final List<String> audiobookIds;

  /// When the list was created.
  final DateTime createdAt;

  /// When the list was last updated.
  final DateTime? updatedAt;

  /// Display order for the list.
  final int order;

  /// Get the number of audiobooks in the list.
  int get length => audiobookIds.length;

  /// Check if the list is empty.
  bool get isEmpty => audiobookIds.isEmpty;

  /// Check if the list is not empty.
  bool get isNotEmpty => audiobookIds.isNotEmpty;

  /// Check if an audiobook is in the list.
  bool containsAudiobook(String audiobookId) => audiobookIds.contains(audiobookId);

  /// Add an audiobook to the list (returns new instance).
  ReadingList withAddedAudiobook(String audiobookId) {
    if (containsAudiobook(audiobookId)) {
      return this;
    }
    return copyWith(
      audiobookIds: [...audiobookIds, audiobookId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove an audiobook from the list (returns new instance).
  ReadingList withRemovedAudiobook(String audiobookId) {
    if (!containsAudiobook(audiobookId)) {
      return this;
    }
    return copyWith(
      audiobookIds: audiobookIds.where((id) => id != audiobookId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated fields.
  ReadingList copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? audiobookIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? order,
  }) {
    return ReadingList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      audiobookIds: audiobookIds ?? this.audiobookIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        audiobookIds,
        createdAt,
        updatedAt,
        order,
      ];
}
