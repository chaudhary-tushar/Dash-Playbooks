class UserSettings {
  UserSettings({
    required this.syncEnabled,
    this.localLibraryPath,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      syncEnabled: (map['syncEnabled'] as bool?) ?? true,
      localLibraryPath: map['localLibraryPath'] as String?,
    );
  }
  final bool syncEnabled;
  final String? localLibraryPath;

  static UserSettings defaultSettings() => UserSettings(syncEnabled: true);

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
