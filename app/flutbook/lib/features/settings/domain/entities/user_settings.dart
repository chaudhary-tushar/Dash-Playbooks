class UserSettings {
  UserSettings({
    required this.syncEnabled,
    this.localLibraryPath,
  });

  UserSettings.defaults() : syncEnabled = true, localLibraryPath = null;

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      syncEnabled: (map['syncEnabled'] as bool?) ?? true,
      localLibraryPath: map['localLibraryPath'] as String?,
    );
  }
  final bool syncEnabled;
  final String? localLibraryPath;

  Map<String, dynamic> toMap() => {
    'syncEnabled': syncEnabled,
    'localLibraryPath': localLibraryPath,
  };

  UserSettings copyWith({
    bool? syncEnabled,
    String? localLibraryPath,
  }) {
    return UserSettings(
      syncEnabled: syncEnabled ?? this.syncEnabled,
      localLibraryPath: localLibraryPath ?? this.localLibraryPath,
    );
  }
}
