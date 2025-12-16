// lib/core/extensions/app_extensions.dart
extension DurationExtension on Duration {
  int get inWholeMilliseconds => inMilliseconds;
}

extension StringExtension on String {
  bool get isNullOrEmpty => isEmpty;

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DateTimeExtension on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
}
