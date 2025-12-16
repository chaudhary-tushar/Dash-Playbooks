# How to Test & Configure the Audiobook Player App

## Testing the UI

### Testing the Web Build (Recommended for UI Testing)
1. Run the build script to build the web version:
   ```bash
   ./build_flutter_audiobooks.sh --type web --output ./web-output
   ```

2. The script will create a web build and offer to serve it locally. If you chose 'y', the app will be available at:
   - http://localhost:8000

3. If you declined the automated serving, manually serve the web build:
   ```bash
   cd web-output/
   python3 -m http.server 8000
   ```
   Then navigate to: http://localhost:8000

### Testing with Flutter (Direct Method)
Alternatively, you can test the UI directly without Docker:
1. Navigate to your project directory:
   ```bash
   cd /home/romeo/Desktop/flutter-audiobooks
   ```

2. Run for web:
   ```bash
   flutter run -d chrome
   ```

3. Run for other platforms:
   ```bash
   flutter run -d android  # For Android emulator/device
   flutter run -d linux    # For Linux desktop (if set up)
   ```

## Configuring Backend Variables (Firebase)

### 1. Environment Configuration File
Create a `.env` file in the project root with your Firebase credentials:

```
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_AUTH_DOMAIN=your_auth_domain_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here
FIREBASE_APP_ID=your_app_id_here
```

### 2. Flutter Configuration File
You need to create a Firebase options file for Flutter. Add this to `lib/config/firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get firebaseOptions {
    if (kIsWeb) {
      // Web configuration
      return const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
        authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: ''),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: ''),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: ''),
        messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
        appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: ''),
      );
    } else {
      // Mobile/Desktop configuration
      return const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
        authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: ''),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: ''),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: ''),
        messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
        appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: ''),
      );
    }
  }
}
```

### 3. Update pubspec.yaml
Add environment variables support to your pubspec.yaml:

```yaml
flutter:
  uses-material-design: true
  generate: true

# Add this to enable environment variable replacement
flutter_gen:
  # Configuration for flutter_gen

# Environment variables are processed at build time
# For web builds, you may need to use build-time constants
# For mobile, you can use the .env file + environment variables
```

### 4. For Docker Builds with Environment Variables
When building with Docker and you want to include Firebase configuration:

```bash
# Option 1: Build with environment variables passed to container
docker build --build-arg FIREBASE_API_KEY=your_key \
             --build-arg FIREBASE_AUTH_DOMAIN=your_domain \
             --build-arg FIREBASE_PROJECT_ID=your_project_id \
             --build-arg FIREBASE_STORAGE_BUCKET=your_bucket \
             --build-arg FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
             --build-arg FIREBASE_APP_ID=your_app_id \
             --tag flutter-audiobook-player .

# Option 2: Create a secure build context with a .env file
# (Don't commit the .env file to git!)
# You can mount it during container execution:
FLUTTER_RUN_ARGS=""
while IFS='=' read -r key value; do
    FLUTTER_RUN_ARGS="$FLUTTER_RUN_ARGS --dart-define=$key=$value"
done < ".env"

# Then run flutter with these arguments
```

### 5. Secure Credential Storage
For production usage, credentials are securely stored using platform-appropriate methods:
- Android: Encrypted Shared Preferences or Android Keystore
- iOS: Keychain Services
- Web: Browser's secure storage
- Linux: Secret Service API or GNOME keyring

The application handles this automatically via the Firebase SDKs and the secure storage implementations specified in the requirements.

## Running the Built Application

### Web Application
After building for web, the output is in the `web-output/` directory:
1. Serve with the python server (port 8000)
2. Or deploy to a web server by copying the directory contents

### Linux Application
After building for Linux, the output is in the `linux-output/` directory:
1. Navigate to the output directory
2. Run the executable: `./flutter_audiobooks`

### Android APK
After building for Android, the APK is available at:
- `android-output/app-release.apk`
- Install on a device using: `adb install android-output/app-release.apk`

## Docker Development Environment

For ongoing development with Docker:
```bash
# Build development image
docker build -t audiobook-dev -f Dockerfile.dev .

# Run development container
docker run -it -v $(pwd):/app -w /app -p 3000:3000 -p 8080:8080 audiobook-dev

# Inside the container you can run:
flutter run -d chrome
flutter run -d android
flutter doctor
flutter analyze
flutter test
```

## Testing Edge Cases

The application handles these edge cases as specified in the requirements:
- Very large audiobooks (>10GB)
- Directories with thousands of files
- Missing or corrupted metadata
- Insufficient storage space
- Network unavailability during sync
- Authentication failures
- Corrupted audio files during playback

You can test these by creating test scenarios with large files, empty directories, or by temporarily disabling network connectivity.