# Firebase Project Structure for FlutBook Audiobook App

## Overview
This document describes the recommended Firebase project structure and services for the FlutBook cross-platform audiobook player application. Based on the analysis of the codebase, several Firebase services are required for optimal functionality.

## Required Firebase Services

### 1. Firebase Authentication
- **Purpose**: User authentication with support for email/password, anonymous sign-in, and Google Sign-In
- **Configuration needed**: Enable Email/Password, Anonymous, and Google sign-in methods
- **Integration**: Used through `firebase_auth` package in `FirebaseAuthDatasource`

### 2. Cloud Firestore
- **Purpose**: Store user profiles, audiobook metadata, and playback progress data
- **Integration**: Used through `cloud_firestore` package in `firebase_library_sync.dart` and `firebase_playback_sync.dart` files
- **Data types stored**: User profiles, audiobook information, playback history, library data

### 3. Firebase Storage
- **Purpose**: Store audiobook files, cover art images, and other media content
- **Integration**: Will be integrated via the `firebase_storage` package (currently referenced in documentation plans)
- **Data types stored**: Audiobook files (.mp3, .m4b, etc.), cover art images (.jpg, .png)

### 4. Firebase Analytics (Optional)
- **Purpose**: Track user engagement and app usage
- **Integration**: Through `firebase_analytics` package

### 5. Firebase Crashlytics (Optional)
- **Purpose**: Monitor app crashes and reporting
- **Integration**: Through `firebase_crashlytics` package

## Firestore Database Schema

### Collections Structure

#### 1. `users`
- Document ID: Firebase Authentication UID
- Fields:
  - `uid` (string) - User ID (same as document ID)
  - `email` (string) - User's email address
  - `displayName` (string) - User's display name
  - `photoURL` (string, optional) - User's profile photo URL
  - `createdAt` (timestamp) - Account creation time
  - `lastLoginAt` (timestamp) - Last login time
  - `settings` (map) - User preferences and settings

#### 2. `libraries`
- Document ID: Auto-generated ID
- Fields:
  - `userId` (string) - Reference to the user who owns this library
  - `audiobookIds` (array of strings) - List of audiobook IDs in this library
  - `createdAt` (timestamp) - Creation timestamp
  - `updatedAt` (timestamp) - Last update timestamp

#### 3. `audiobooks`
- Document ID: Auto-generated ID or UUID
- Fields:
  - `id` (string) - Unique identifier
  - `userId` (string) - Owner of this audiobook
  - `title` (string) - Audiobook title
  - `author` (string) - Author name
  - `album` (string) - Album/series name
  - `coverArtPath` (string) - Path to cover art in Firebase Storage
  - `duration` (number) - Duration in seconds
  - `filePath` (string) - Path to audiobook file in Firebase Storage
  - `chapters` (array of objects) - Chapter information
  - `createdAt` (timestamp) - Upload timestamp
  - `lastPlayedAt` (timestamp) - Last played timestamp
  - `completed` (boolean) - Whether the audiobook is completed
  - `totalSize` (number) - File size in bytes

#### 4. `playback_sessions`
- Document ID: Auto-generated ID
- Fields:
  - `userId` (string) - User ID
  - `audiobookId` (string) - Associated audiobook
  - `position` (number) - Current playback position in seconds
  - `speed` (number) - Playback speed (e.g., 1.0, 1.25)
  - `updatedAt` (timestamp) - Last updated timestamp
  - `completed` (boolean) - Whether the audiobook is completed

## Authentication Configuration

### Enabled Providers
1. **Email/Password Authentication**: For traditional account creation
2. **Anonymous Authentication**: For trial access without signup
3. **Google Sign-In**: For convenient social authentication

### Authentication Flow
- The app supports both registered users and anonymous users
- Anonymous users can access basic features with data being migrated to a permanent account if they later register
- User state is managed using Riverpod with `auth_provider.dart`

## Firebase Storage Structure

### Bucket Structure
```
gs://<your-firebase-storage-bucket>/  # Root bucket
├── audiobooks/                       # User-uploaded audiobook files
│   ├── <user-id>/                   # Files organized by user
│   │   ├── <audiobook-id>.mp3       # Individual audiobook files
│   │   └── <audiobook-id>.m4b
│   └── ...
└── covers/                          # Cover art images
    ├── <user-id>/                  # Organized by user
    │   ├── <audiobook-id>.jpg      # Individual cover art
    │   └── <audiobook-id>.png
    └── ...
```

### Access Policy
- Files are secured with Firebase Security Rules
- Users can only access their own files
- Public access is disabled by default

## Security Rules

### Firestore Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Libraries are accessible only by owner
    match /libraries/{libraryId} {
      allow read, write: 
        if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }

    // Audiobooks are accessible only by owner
    match /audiobooks/{audiobookId} {
      allow read, write: 
        if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }

    // Playback sessions are accessible only by owner
    match /playback_sessions/{sessionId} {
      allow read, write: 
        if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### Storage Security Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /audiobooks/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /covers/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Setup Instructions

### 1. Create a Firebase Project
- Go to Firebase Console (console.firebase.google.com)
- Click "Add Project" and follow the wizard
- Name your project (e.g., "flutbook-audiobooks")

### 2. Configure Firebase Authentication
- In Firebase Console, navigate to Authentication
- Click "Get Started"
- Enable Email/Password, Anonymous, and Google sign-in methods
- For Google sign-in, add your app's SHA-1 fingerprint for Android and OAuth client IDs for iOS/Web

### 3. Configure Firestore Database
- In Firebase Console, navigate to Firestore Database
- Click "Create Database"
- Choose "Start in production mode" (with security rules) for production or "Start in test mode" for development
- Once created, implement the security rules described above

### 4. Configure Firebase Storage
- In Firebase Console, navigate to Storage
- Click "Get Started"
- Set up default Cloud Storage bucket
- Implement the security rules described above

### 5. Add Firebase Configuration to Your App
- For Android: Download `google-services.json` and place in `android/app/`
- For iOS: Download `GoogleService-Info.plist` and add to `ios/Runner/`
- Run `flutterfire configure` to generate `firebase_options.dart` with your project configuration
- Add required Firebase packages to `pubspec.yaml`:
  ```
  dependencies:
    firebase_core: ^4.3.0
    firebase_auth: ^6.1.2
    cloud_firestore: ^6.1.0
    firebase_storage: ^12.4.0
  ```

### 6. Environment Configuration
For secure deployment, store Firebase configuration in environment variables:

Create `.env` file in the project root:
```
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_AUTH_DOMAIN=your_auth_domain_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here
FIREBASE_APP_ID=your_app_id_here
```

## Testing Considerations

### Emulator Suite
Consider using Firebase Emulator Suite for local development:
- Firestore emulator
- Authentication emulator  
- Storage emulator
- Functions emulator (for future extension)

To enable emulators in development mode, add appropriate flags to your Firebase configuration.

## Performance Optimization

### Firestore Optimization
- Use indexes for compound queries
- Implement pagination for large collections
- Cache frequently accessed data in Isar (local database)
- Use Firestore transactions for consistent updates

### Storage Optimization
- Compress audiobook files before upload
- Use appropriate cover art sizes
- Implement progressive loading for large files

## Future Extensions

### Cloud Functions
Potential use cases:
- Metadata extraction from uploaded audiobook files
- Generating cover art thumbnails
- Sending notifications for sync operations
- Backup and synchronization triggers

### Additional Analytics
- Track user listening habits
- Monitor popular audiobooks
- Analyze app usage patterns

This Firebase structure is designed to support your app's offline-first architecture, with local Isar database as the primary data store and Firebase services for synchronization and user authentication across devices.
