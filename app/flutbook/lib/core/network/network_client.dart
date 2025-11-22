/// Abstract network client for remote data sources.
/// Provides interface for HTTP operations, to be implemented with Dio/http for Firebase sync etc.
library;

abstract class NetworkClient {
  /// Performs GET request to the given endpoint.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  });

  /// Performs POST request to the given endpoint.
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  });
}
