/// Result class for sync operations
class SyncResult {
  const SyncResult({
    required this.success,
    this.message,
    this.errorMessage,
    required this.itemsSynced,
  });
  final bool success;
  final String? message;
  final String? errorMessage;
  final int itemsSynced;
}
