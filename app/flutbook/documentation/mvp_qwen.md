# Flutter Audiobook Player - MVP Documentation

## Overview
Flutbook is a cross-platform audiobook player application built with Flutter. The app is designed following clean architecture principles with Riverpod for state management and Isar for local data persistence.

## Current User Flow

### 1. Splash Screen (main.dart)
- App starts with a splash screen that appears for 2 seconds
- Then navigates to the main screen (currently the library screen)

### 2. Library Screen (features/library/presentation/views/library_screen.dart)
- Displays a list of audiobooks with mock data
- Includes search, filtering (by status), and sorting capabilities
- Shows audiobook cards with cover art, title, author, and progress
- Each card can be tapped to navigate to the playback screen

### 3. Playback Screen (features/playback/presentation/views/playback_screen.dart)
- Displays audiobook details (title, author, cover art)
- Shows a progress bar with seeking capability
- Provides playback controls (play/pause, skip forward/backward)
- Allows adjusting playback speed
- Includes sleep timer functionality

### 4. Settings Screen (features/settings/presentation/view/settings_screen.dart)
- Controls for dark mode, playback speed, skip intervals
- Library directory selection
- Account management options
- App information section

### 5. Authentication Flow (features/auth/)
- Login screen with both mobile and tablet/desktop layouts
- Social login options (Google)
- Form-based authentication

## Potential Problems & Challenges

### 1. State Management Issues
- **Problem**: The application uses a mix of StatefulWidget local state and commented-out Riverpod state management.
- **Impact**: Inconsistent state handling that will become problematic as the app scales.
- **Solution**: Fully implement Riverpod for all state management needs.

### 2. Data Flow & Integration
- **Problem**: Heavy use of mock data instead of actual file system integration.
- **Impact**: The app cannot load real audiobook files from the user's device.
- **Solution**: Implement file system scanning to discover audio files and populate the Isar database.

### 3. Audio Service Integration
- **Problem**: Audio service dependencies exist but are not connected to UI components.
- **Impact**: No working background audio playback functionality.
- **Solution**: Integrate `audio_service` and `just_audio` with the playback screen.

### 4. Isar Database Integration
- **Problem**: Database schema exists but no actual CRUD operations implemented.
- **Impact**: No persistent storage of audiobook metadata or playback progress.
- **Solution**: Connect Isar database operations to the library and playback screens.

### 5. File System Access
- **Problem**: Directory selection and file scanning not fully implemented.
- **Impact**: Users cannot add their audiobooks to the app.
- **Solution**: Implement proper file system access with appropriate permissions.

### 6. Authentication Integration
- **Problem**: Authentication UI exists but not properly connected to backend.
- **Impact**: Login functionality is non-functional.
- **Solution**: Connect authentication providers and implement proper error handling.

### 7. Route Management Inconsistencies
- **Problem**: Different routing approaches in main.dart vs app_router.dart.
- **Impact**: Potential for navigation issues and inconsistent user experience.
- **Solution**: Standardize on a single routing approach throughout the app.

## Step-by-Step Growth Plan by Commenting Out Functionality

### Phase 1 - Core MVP
1. Comment out authentication features:
   - Login screen and related navigation
   - Account management in settings
   - Cloud sync toggles

2. Comment out advanced playback features:
   - Sleep timer functionality
   - Chapter navigation
   - Playback speed controls (keep basic play/pause only)

3. Comment out file selection features:
   - Directory selection in settings
   - Library rescan functionality
   - Focus only on hardcoded audiobook data

4. Comment out theming options:
   - Dark/light theme switch (use system default)
   - Animation preferences

### Phase 2 - Basic Playback
1. Uncomment and implement basic file system access:
   - Single hardcoded directory scanning
   - Basic audio playback using `just_audio`
   - Simple play/pause and progress tracking

2. Implement local storage:
   - Save/load audiobook metadata using Isar
   - Track playback position within audiobooks

### Phase 3 - Enhanced Library
1. Uncomment and implement directory selection:
   - File browser for selecting audiobook directories
   - Recursive scanning of directories for audio files
   - Display discovered audiobooks in the library

2. Enhance audiobook metadata:
   - Extract metadata from audio files (title, artist, etc.)
   - Download and cache cover art

### Phase 4 - Advanced Playback
1. Uncomment advanced playback features:
   - Skip forward/backward controls (10s/30s)
   - Playback speed controls
   - Sleep timer functionality

2. Implement background audio:
   - Integrate `audio_service` for background playback
   - Add notification controls

### Phase 5 - Polish & Enhance
1. Uncomment theming and preferences:
   - Dark/light theme toggle
   - Animation preferences
   - Playback defaults

2. Add authentication:
   - Basic login functionality
   - Sync progress across devices

3. Add error handling and loading states:
   - Proper error messages for file access
   - Loading indicators for async operations

## Recommended Implementation Approach

1. **Start simple**: Implement Phase 1 with hardcoded data and basic playback to validate the core architecture.

2. **Test early**: Ensure each phase works correctly before moving to the next phase.

3. **Use Riverpod consistently**: Replace all StatefulWidget local state with Riverpod providers.

4. **Implement proper error handling**: Add error handling throughout the app before adding complexity.

5. **Focus on user experience**: Add loading states and smooth transitions as functionality is uncommented.

By following this phased approach, the development team can build a stable, working MVP before adding more complex features, while identifying and resolving architectural issues early in the development process.