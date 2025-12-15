# Flutter Audiobook Player App Flow Process

## Overview
This document describes the navigation flow and business logic of the Flutter audiobook player app from splash screen to full navigation functionality. The app uses the Very Good Core architecture pattern with Riverpod for state management and isar database for local storage.

## App Architecture
- **Data Layer**: Contains datasources, models and repositories
- **Domain Layer**: Contains entities, repositories interfaces and use cases
- **Presentation Layer**: Contains UI, navigation, providers and theme
- **Platform Layer**: Contains platform-specific audio service handlers

## Navigation Flow

### 1. App Launch
- `main.dart`: App initializes with Riverpod ProviderScope
- `AudiobookPlayerApp` is created as the root widget
- Initial route is set to `/splash`

### 2. Splash Screen (`/splash`)
- `SplashScreen` displays an animated splash screen with the app logo
- Duration: 2 seconds (simulated loading)
- After 2 seconds, automatically navigates to `/main` route
- Uses Material gradient background with app title and loading indicator

### 3. Main Library Screen (`/main` or `/library`)
- `LibraryScreen` displays user's audiobook library
- Shows list of audiobooks with cover art, title, author
- Implements search functionality
- Provides filtering options (completed, in-progress, not started)
- Provides sorting options (recent, title, author)
- From here users can:
  - Tap on an audiobook to navigate to playback screen (`/playback`)
  - Navigate to settings screen (`/settings`) via popup menu

### 4. Settings Screen (`/settings`)
- `SettingsScreen` contains various app configuration options:
  - User profile management
  - Playback settings (speed, skip intervals)
  - Library settings (directory, auto download)
  - Account settings (sync, account management)
  - App info (about, privacy policy, rating)

### 5. Playback Screen (`/playback`)
- `PlaybackScreen` provides audiobook playback functionality:
  - Displays cover art, title and author
  - Shows current playback position with progress bar
  - Provides playback controls (play/pause, skip, speed)
  - Shows sleep timer functionality
  - Displays chapter markers on progress bar
  - Implements seeking functionality

## Business Logic

### State Management
- Uses Riverpod for state management
- UI state provider manages general UI states
- Playback provider manages audio playback state
- Repository pattern implements data abstraction

### Data Flow
- Local data is stored using Isar database
- Settings are stored using JSON files
- Cloud sync is implemented via Firebase Firestore
- Metadata extraction is performed locally from audio files

### Authentication Flow (Faked)
- The authentication screen is referenced but not yet implemented
- Login functionality uses Firebase authentication
- Google Sign-In is integrated for social login

### Audio Playback Flow
- Audio service handler manages background audio playback
- Just audio package handles media playback
- Audio service package manages playback when app is in background
- Player state is persisted and restored on app resume

## Navigation Patterns
- Uses named routes for navigation throughout the app
- Route arguments are passed as objects (e.g., Audiobook object)
- Deep linking is supported via named routes
- Navigation is handled via Navigator.pushNamed

## Screens and Components
- **Splash Screen**: Initial loading screen
- **Library Screen**: Main audiobook library interface  
- **Playback Screen**: Audio playback interface
- **Settings Screen**: App configuration
- **Auth Screen**: User authentication (future implementation)
- **Directory Selection Screen**: Library directory selection (future implementation)

## Widgets Used
- **Audiobook Card**: Displays individual audiobook in library
- **Playback Controls**: Handles play/pause, skip, speed controls
- **Progress Bar**: Shows playback position with seeking capability
- **Chapter List**: Displays chapters in audiobook (future implementation)

## Theme and Styling
- Uses Material 3 theming
- Light and dark themes are supported
- Theme mode follows system preferences by default
- Custom app theme extends Material 3 components

## Future Improvements
- Directory selection for audiobook scanning
- Chapter navigation
- Sleep timer implementation
- Offline download management
- Cloud sync implementation