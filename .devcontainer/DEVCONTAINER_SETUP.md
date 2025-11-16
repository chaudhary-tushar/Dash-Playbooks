# Flutter Audiobook Player - DevContainer Development Guide

## Fixed Configuration

Your devcontainer has been reconfigured with proper support for:
- ✅ Flutter development for **Web**, **Linux**, and **Android**
- ✅ VS Code terminal integration
- ✅ All necessary build tools and SDKs
- ✅ Proper capability grants for debugging and building

## What Changed

### Features Fixed
- Removed non-existent `bash-completion:1` feature
- Added `common-utils:2` feature for development utilities
- Added git feature for version control

### Environment Variables
- Flutter is now properly in PATH including Dart SDK
- Android SDK configured with required environment variables
- Gradle home directory mounted for caching builds

### Security & Performance
- Added `SYS_PTRACE` capability for debugging
- Allocated 4GB RAM and 4 CPUs for builds
- Disabled full privileged mode (more secure)

### Terminal Support
- Configured bash as default terminal profile
- Set proper font size and user shell probing
- Full shell environment available

## Quick Start

### 1. Rebuild Container
```bash
# In VS Code, open Command Palette (Ctrl+Shift+P)
# Search for: "Dev Containers: Rebuild Container"
# Click and wait for rebuild to complete
```

### 2. Open Terminal in VS Code
```
Terminal > New Terminal (or Ctrl+`)
```

### 3. Start Developing

#### Build for Web
```bash
flutter build web --release --web-renderer canvaskit
```

#### Run Web (development mode)
```bash
flutter run -d web
```

#### Build for Linux
```bash
flutter build linux --release
```

#### Build for Android (APK)
```bash
flutter build apk --release
```

#### Run all tests
```bash
flutter test
```

#### Generate code (Isar, etc.)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Available Commands in Terminal

Once inside the devcontainer, all these should work immediately:

```bash
# Flutter commands
flutter --version
flutter doctor
flutter pub get
flutter run

# Dart commands
dart --version
dart format lib/

# Android tools
adb devices
adb logcat

# Build tools
ninja --version
cmake --version
```

## Port Forwarding

Automatically forwarded ports:
- **3000**: Flutter dev server
- **8000**: Web build server
- **8080**: Android debug bridge
- **9090**: Flutter DevTools

## Troubleshooting

### Terminal not showing Flutter commands
```bash
# Verify Flutter is in PATH
which flutter

# If not found, source the environment
source ~/.bashrc
export PATH=/opt/flutter/bin:$PATH
```

### Build fails with permission errors
The container now has proper capabilities for debugging:
```bash
# These should work without issues
flutter run -d web
flutter build linux --release
```

### Cache or dependency issues
```bash
# Clear Pub cache
flutter pub cache clean

# Get fresh dependencies
flutter pub get

# Regenerate all code
flutter pub run build_runner build --delete-conflicting-outputs
```

### Exit and reconnect
```bash
# Properly exit the devcontainer
exit

# Rebuild from scratch
# In VS Code: Command Palette > "Dev Containers: Rebuild Container"
```

## File Locations

### Inside Container
- Source code: `/workspace`
- Flutter SDK: `/opt/flutter`
- Android SDK: `/opt/android-sdk-linux`
- Pub cache: `/root/.pub-cache`
- Gradle: `/root/.gradle`

### Volume Mounts (Local `.volumes/` folder)
```
.volumes/
├── ssh/                    # SSH keys
├── pub-cache/             # Pub dependencies
├── flutter-bin/           # Flutter binaries
├── android-sdk/           # Android SDK files
└── gradle/                # Gradle build cache
```

## Extensions Installed

These VS Code extensions will be auto-installed:
- Dart Code
- Flutter
- Python
- Ruff (linter)
- Material Theme
- GitHub Copilot
- Remote Containers

## System Requirements

Minimum host requirements:
- **CPU**: 4 cores
- **RAM**: 4GB
- **Storage**: 20GB free

## Using Docker Compose (Alternative)

If you prefer docker-compose:
```bash
docker-compose up -d
docker-compose exec flutter-dev bash
```

Then run same Flutter commands as above.

## More Information

See `.devcontainer/README.md` for comprehensive documentation.
