/// Domain entity representing a playback queue.
///
/// A queue is a named collection of audiobooks that can be played in sequence.
/// Users can create multiple queues and switch between them.
class Queue {
  const Queue({
    required this.id,
    required this.name,
    required this.audiobookIds,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.currentIndex = 0,
  });

  /// Creates a Queue from a Map
  factory Queue.fromMap(Map<String, dynamic> map) {
    return Queue(
      id: map['id'] as int,
      name: map['name'] as String,
      audiobookIds: List<String>.from(map['audiobookIds'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDefault: map['isDefault'] as bool? ?? false,
      currentIndex: map['currentIndex'] as int? ?? 0,
    );
  }

  /// Unique identifier for the queue (Isar auto-increment ID)
  final int id;

  /// Name of the queue (e.g., "Workout Mix", "Commute")
  final String name;

  /// List of audiobook IDs in the queue
  final List<String> audiobookIds;

  /// When the queue was created
  final DateTime createdAt;

  /// When the queue was last updated
  final DateTime updatedAt;

  /// Whether this is the default queue
  final bool isDefault;

  /// Current index in the queue
  final int currentIndex;

  /// Creates a copy of this queue with the given fields replaced
  Queue copyWith({
    int? id,
    String? name,
    List<String>? audiobookIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    int? currentIndex,
  }) {
    return Queue(
      id: id ?? this.id,
      name: name ?? this.name,
      audiobookIds: audiobookIds ?? this.audiobookIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  /// Converts queue to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'audiobookIds': audiobookIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
      'currentIndex': currentIndex,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Queue &&
        other.id == id &&
        other.name == name &&
        other.audiobookIds == audiobookIds &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isDefault == isDefault &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        audiobookIds.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isDefault.hashCode ^
        currentIndex.hashCode;
  }

  @override
  String toString() {
    return 'Queue(id: $id, name: $name, audiobookIds: $audiobookIds, '
        'createdAt: $createdAt, updatedAt: $updatedAt, isDefault: $isDefault, '
        'currentIndex: $currentIndex)';
  }
}
