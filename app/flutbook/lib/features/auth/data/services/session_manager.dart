import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionExpiryKey = 'session_expiry';
  static const String _sessionCreatedAtKey = 'session_created_at';

  /// Gets the session expiry date
  Future<DateTime?> getSessionExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_sessionExpiryKey);
    if (expiryString != null) {
      return DateTime.tryParse(expiryString);
    }
    return null;
  }

  /// Sets the session expiry date
  Future<void> setSessionExpiry(DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionExpiryKey, expiry.toIso8601String());
    await prefs.setString(_sessionCreatedAtKey, DateTime.now().toIso8601String());
  }

  /// Checks if the session has expired
  Future<bool> isSessionExpired() async {
    final expiry = await getSessionExpiry();
    if (expiry == null) {
      return true; // No session data means expired
    }
    return DateTime.now().isAfter(expiry);
  }

  /// Clears the session data
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionExpiryKey);
    await prefs.remove(_sessionCreatedAtKey);
  }

  /// Calculates the session expiry date based on the creation date
  /// with a random duration between 7 and 30 days
  DateTime calculateExpiryDate(DateTime createdAt) {
    // Random duration between 7 and 30 days
    final randomDays = 7 + (23 * (DateTime.now().microsecond % 1000000) / 1000000).floor();
    return createdAt.add(Duration(days: randomDays));
  }

  /// Checks if the session should be renewed (if it's older than 7 days)
  Future<bool> shouldRenewSession() async {
    final createdAtString = await _getSessionCreatedAt();
    if (createdAtString == null) {
      return true; // No session data means should renew
    }

    final createdAt = DateTime.tryParse(createdAtString);
    if (createdAt == null) {
      return true; // Invalid date means should renew
    }

    // If session is older than 7 days, it should be renewed
    return DateTime.now().difference(createdAt).inDays >= 7;
  }

  /// Gets the session creation date
  Future<String?> _getSessionCreatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionCreatedAtKey);
  }
}
