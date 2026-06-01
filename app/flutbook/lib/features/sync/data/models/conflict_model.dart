/// Data model for tracking sync conflicts between local and remote data.
library;

/// The type of entity that has a conflict.
enum ConflictEntityType {
  /// Audiobook library conflict
  library,

  /// Playback position conflict
  playback,

  /// Reading list conflict
  readingList,
}

/// How a conflict was or should be resolved.
enum ConflictResolutionStrategy {
  /// Use whichever version has the newer timestamp
  lastWriteWins,

  /// Always prefer the local version
  localWins,

  /// Always prefer the remote version
  remoteWins,

  /// User must manually choose
  manual,
}

/// Current status of a conflict record.
enum ConflictStatus {
  /// Awaiting resolution
  pending,

  /// Resolved by keeping local data
  resolvedLocal,

  /// Resolved by keeping remote data
  resolvedRemote,

  /// Resolved by merging both versions
  resolvedMerged,

  /// Automatically resolved
  autoResolved,
}

/// A sync conflict between local and remote versions of an entity.
class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.entityTitle,
    required this.localData,
    required this.remoteData,
    required this.localTimestamp,
    required this.remoteTimestamp,
    this.status = ConflictStatus.pending,
    this.resolutionStrategy = ConflictResolutionStrategy.lastWriteWins,
    this.resolvedAt,
    this.resolvedData,
    this.notes,
  });

  factory SyncConflict.fromMap(Map<String, dynamic> map) {
    return SyncConflict(
      id: map['id'] as String,
      entityType: ConflictEntityType.values.byName(map['entityType'] as String),
      entityId: map['entityId'] as String,
      entityTitle: map['entityTitle'] as String,
      localData: Map<String, dynamic>.from(map['localData'] as Map),
      remoteData: Map<String, dynamic>.from(map['remoteData'] as Map),
      localTimestamp: DateTime.parse(map['localTimestamp'] as String),
      remoteTimestamp: DateTime.parse(map['remoteTimestamp'] as String),
      status: ConflictStatus.values.byName(map['status'] as String),
      resolutionStrategy: ConflictResolutionStrategy.values
          .byName(map['resolutionStrategy'] as String),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'] as String)
          : null,
      resolvedData: map['resolvedData'] != null
          ? Map<String, dynamic>.from(map['resolvedData'] as Map)
          : null,
      notes: map['notes'] as String?,
    );
  }

  /// Unique identifier for this conflict record
  final String id;

  /// Type of entity that has the conflict
  final ConflictEntityType entityType;

  /// ID of the conflicting entity
  final String entityId;

  /// Human-readable title for display (e.g. audiobook title)
  final String entityTitle;

  /// Serialized local data snapshot at time of conflict
  final Map<String, dynamic> localData;

  /// Serialized remote data snapshot at time of conflict
  final Map<String, dynamic> remoteData;

  /// When the local version was last modified
  final DateTime localTimestamp;

  /// When the remote version was last modified
  final DateTime remoteTimestamp;

  /// Current resolution status
  final ConflictStatus status;

  /// Strategy used to resolve this conflict
  final ConflictResolutionStrategy resolutionStrategy;

  /// When this conflict was resolved (null if still pending)
  final DateTime? resolvedAt;

  /// The final resolved data (null if still pending)
  final Map<String, dynamic>? resolvedData;

  /// Optional notes about the conflict or resolution
  final String? notes;

  bool get isPending => status == ConflictStatus.pending;
  bool get isResolved => status != ConflictStatus.pending;
  bool get isLocalNewer => localTimestamp.isAfter(remoteTimestamp);
  bool get isRemoteNewer => remoteTimestamp.isAfter(localTimestamp);

  SyncConflict copyWith({
    String? id,
    ConflictEntityType? entityType,
    String? entityId,
    String? entityTitle,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    DateTime? localTimestamp,
    DateTime? remoteTimestamp,
    ConflictStatus? status,
    ConflictResolutionStrategy? resolutionStrategy,
    DateTime? resolvedAt,
    Map<String, dynamic>? resolvedData,
    String? notes,
  }) {
    return SyncConflict(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      entityTitle: entityTitle ?? this.entityTitle,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      localTimestamp: localTimestamp ?? this.localTimestamp,
      remoteTimestamp: remoteTimestamp ?? this.remoteTimestamp,
      status: status ?? this.status,
      resolutionStrategy: resolutionStrategy ?? this.resolutionStrategy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedData: resolvedData ?? this.resolvedData,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityType': entityType.name,
      'entityId': entityId,
      'entityTitle': entityTitle,
      'localData': localData,
      'remoteData': remoteData,
      'localTimestamp': localTimestamp.toIso8601String(),
      'remoteTimestamp': remoteTimestamp.toIso8601String(),
      'status': status.name,
      'resolutionStrategy': resolutionStrategy.name,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedData': resolvedData,
      'notes': notes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncConflict &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
