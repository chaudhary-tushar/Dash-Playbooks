# Quickstart Guide: Cross-Platform Audiobook Player

## Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Android SDK (for Android builds)
- For Linux builds: Appropriate build tools
- For Web: Chrome browser for testing

## Setting Up the Development Environment

### Method 1: Standard Flutter Development

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd flutter-audiobooks
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Isar code:
   ```bash
   flutter packages pub run build_runner build
   ```

4. Run the application:
   ```bash
   flutter run -d android  # For Android
   flutter run -d linux    # For Linux
   flutter run -d chrome   # For Web
   ```

### Method 2: Docker-based Development

1. Build the development container:
   ```bash
   docker build -t audiobook-dev -f Dockerfile.dev .
   ```

2. Run the container with project mounted:
   ```bash
   docker run -it -v $(pwd):/app -w /app -p 3000:3000 audiobook-dev
   ```

3. Inside the container, run:
   ```bash
   flutter pub get
   flutter run -d chrome  # For web development
   ```

## Key Features Walkthrough

After launching the app, you'll first see the splash screen, followed by the authentication screen where you can choose to continue as an anonymous user. 

As an anonymous user:
1. Select "Continue as Anonymous"
2. Choose a directory containing audiobook files
3. Browse your library of audiobooks
4. Play any audiobook with full controls (play/pause, skip, speed control, progress tracking)

## Testing the MVP

The MVP includes User Story 1 functionality:
1. Directory selection and scanning
2. Metadata extraction from supported formats (mp3, m4a, m4b, wav, flac)
3. Playback controls (play/pause, skip forward/backward 10/15/30 sec)
4. Progress tracking and restoration
5. Speed control (0.5x to 3.0x)
6. Library browsing with filtering and sorting

To test, use the `test/` directory to run:
```bash
flutter test
```

To run integration tests:
```bash
flutter test integration_test/
```

## Build for Production

```bash
# For Android
flutter build apk --release

# For Linux
flutter build linux --release

# For Web
flutter build web --release
```

## Architecture Overview

The app follows a clean architecture with:
- **Domain layer**: Pure Dart business logic
- **Data layer**: Repository implementations and data sources (Isar database, file system, Firebase)
- **Presentation layer**: UI and state management with Riverpod
- **Platform layer**: Platform-specific integrations

## Development Notes

- All UI elements use Material 3 design
- Isar database for fast, local storage of audiobook metadata
- Error handling follows constitution requirements (no raw stack traces)
- Background playback implemented with audio_service