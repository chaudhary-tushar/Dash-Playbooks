/// Result class for sync operations
class SyncResult {
  const SyncResult({
    required this.success,
    required this.itemsSynced, this.message,
    this.errorMessage,
  });
  final bool success;
  final String? message;
  final String? errorMessage;
  final int itemsSynced;
}
