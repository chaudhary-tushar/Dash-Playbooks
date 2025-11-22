/// Result class for sync operations
class SyncResult {
  const SyncResult({
    required this.success,
    required this.message,
    required this.itemsSynced,
  });
  final bool success;
  final String message;
  final int itemsSynced;
}
