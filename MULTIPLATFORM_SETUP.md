# Flutter Audiobook Player - Multi-Platform Setup Guide

## Overview

This project is set up as a cross-platform audiobook player application for mobile, web, and Linux. This document explains how to properly configure the project to support all these platforms.

## Setting up Multi-Platform Support

If you're experiencing issues with web or Linux builds, it's likely because the project wasn't initially created with multi-platform support. Follow these steps to properly set up the project:

### 1. Back up your code
First, back up your lib/ directory and pubspec.yaml file, as we'll need to recreate the project structure:

```bash
cp -r lib/ lib_backup/
cp pubspec.yaml pubspec_backup.yaml
```

### 2. Recreate the project with multi-platform support
```bash
flutter create --platforms=android,ios,web,linux,macos,windows .
```

### 3. Restore your code
After recreating the project, restore your Dart code and update your pubspec.yaml:

```bash
cp -r lib_backup/* lib/
cp pubspec_backup.yaml pubspec.yaml
```

### 4. Update dependencies
Make sure to update any platform-specific dependencies after recreating the project:

```bash
flutter pub get
```

## Building for Different Platforms

### Web
```bash
flutter build web
```

### Linux
```bash
flutter build linux
```

### Android
```bash
flutter build apk
```

## Docker Builds

The project includes a build script for creating builds within Docker containers:

```bash
# For web
./build_flutter_audiobooks.sh -t web

# For Linux
./build_flutter_audiobooks.sh -t linux

# For Android
./build_flutter_audiobooks.sh -t android
```

## Troubleshooting

### Web Build Issues
- If you encounter Firebase web compatibility issues, consider using conditional imports or platform-specific implementations
- Make sure to run `flutter config --enable-web` in your environment

### Linux Build Issues
- Ensure you've run `flutter config --enable-linux-desktop`
- The Docker container should have the necessary Linux build dependencies
- Check that the `linux` directory exists with proper CMake files

### Android Build Issues
- Make sure you have Android SDK and build-tools installed
- Run `flutter doctor` to verify Android setup
- Ensure the `android` directory exists with proper Gradle files

## Dev Container Setup

The project includes a Dev Container configuration for consistent development environments:

1. Open the project in VS Code
2. When prompted, reopen in container
3. Or use "Dev Containers: Rebuild Container" from the command palette

The dev container includes all necessary dependencies for building for all platforms.

## Configuration Notes

- The project uses Isar for local database storage
- Firebase Firestore is used for cloud sync
- The audiobook player uses just_audio for playback