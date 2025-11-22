class SyncStatus {
  const SyncStatus({
    required this.isSyncing,
    required this.syncEnabled,
    required this.lastSyncSuccessful,
    required this.hasPendingChanges,
    this.lastSyncAt,
  });
  final bool isSyncing;
  final bool syncEnabled;
  final bool lastSyncSuccessful;
  final bool hasPendingChanges;
  final DateTime? lastSyncAt;
}
