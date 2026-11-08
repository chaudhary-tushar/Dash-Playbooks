# Flutter Audiobook Player

A cross-platform, offline-first audiobook player built with Flutter, targeting Android and Linux (desktop). The application follows Material 3 design principles with a focus on privacy and local-first functionality.

## Features

- **Offline-First**: All core functionality works without internet connection
- **Cross-Platform**: Works on Android, Linux, and Web with native-like experience
- **Local Library**: Scan and play audiobooks from local directories
- **Progress Tracking**: Remembers playback position across sessions
- **Metadata Extraction**: Extracts title, author, cover art, and duration from audio files
- **Playback Controls**: Play/pause, skip forward/backward, speed control (0.5x-3.0x), sleep timer
- **Chapter Navigation**: Supports chapter-aware formats like m4b
- **Background Playback**: Continues playing when app is in background
- **Authentication**: Optional Supabase authentication (email/password, Google OAuth, anonymous) for cloud sync
- **Synchronization**: Sync progress and library across devices when authenticated

## Tech Stack

- **Framework**: Flutter 3.x with Dart 3.x
- **State Management**: Riverpod
- **Audio Playback**: just_audio (via just_audio_media_kit) + audio_service
- **Database**: Isar (local, offline-first) + Supabase (Postgres backend + Auth + Storage for sync)
- **UI**: Material 3 design system
- **Architecture**: Clean Architecture with layered design (domain, data, presentation, platform)

## Architecture

The app follows a layered architecture:

- **domain/**: Business logic (entities, use cases, repositories)
- **data/**: Data implementation (Isar database, Supabase, file operations)
- **presentation/**: UI and state management
- **platform/**: Platform-specific integrations

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Android SDK (for Android builds)
- For Linux builds: Appropriate build tools

### Setup

1. Clone the repository
2. Run `flutter pub get`
3. Provide Supabase configuration via `SUPABASE_URL` and `SUPABASE_ANON_KEY` (see `lib/core/config/app_config.dart`)
4. Run `flutter run` to start the app

### Development

The app supports hot reload for rapid development:

- For Android: `flutter run -d android`
- For Linux: `flutter run -d linux`

## Testing

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Building

- APK: `flutter build apk`
- Linux: `flutter build linux`

## Platform Support

- **Android**: Full support with background playback and notifications
- **Linux**: Desktop experience with MPRIS integration
- Additional platforms (Windows, iOS) to be added later

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT