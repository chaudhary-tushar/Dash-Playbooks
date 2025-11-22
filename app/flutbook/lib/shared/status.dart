/// Shared status enums used across features for consistent state management.
/// Includes statuses for library scanning, playback control, and UI loading states.
library;

enum LibraryStatus {
  /// Library is in initial uninitialized state.
  initial,

  /// Library is being scanned or synced.
  loading,

  /// Library data is loaded and ready.
  loaded,

  /// An error occurred during library operations.
  error,
}

enum PlaybackStatus {
  /// Playback is stopped.
  stopped,

  /// Audiobook is currently playing.
  playing,

  /// Playback is paused.
  paused,

  /// Playback has completed the current chapter/book.
  completed,
}

enum UiStatus {
  /// UI is idle, no ongoing operations.
  idle,

  /// UI is busy with loading or processing.
  busy,
}
