class PreferencesDatasource {
  Future<void> saveUserPreferences(dynamic user) async {}

  Future<bool> hasPendingSyncChanges() async => false;

  Future<DateTime?> getLastSyncTime() async => null;

  Future<bool> getLastSyncSuccessful() async => false;

  Future<void> setLastSyncTime(DateTime time) async {}

  Future<void> setLastSyncSuccessful(bool value) async {}

  Future<Map<String, dynamic>> getUserSettings() async => {};

  Future<void> saveUserSettings(Map<String, dynamic> settings) async {}
}
