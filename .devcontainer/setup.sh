#!/bin/bash
# Setup script for Flutter Audiobook Player development environment

set -e

echo "=========================================="
echo "Setting up Flutter Audiobook Player"
echo "=========================================="

cd /workspace

# Check Flutter installation
echo "Checking Flutter installation..."
flutter --version
flutter doctor

# Get dependencies
echo "Getting pub dependencies..."
flutter pub get

# Generate code (Isar, etc.)
echo "Running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

# Enable web platform
echo "Enabling web platform..."
flutter config --enable-web

# Enable Linux desktop
echo "Enabling Linux desktop..."
flutter config --enable-linux-desktop

# Install global packages
echo "Installing global packages..."
flutter pub global activate build_runner
flutter pub global activate devtools

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Available commands:"
echo "  flutter run                   - Run app on available device/emulator"
echo "  flutter run -d web            - Run web version"
echo "  flutter build web --release   - Build web release"
echo "  flutter build linux --release - Build Linux release"
echo "  flutter build apk --release   - Build Android APK"
echo "  flutter test                  - Run tests"
echo "  flutter pub run build_runner build --delete-conflicting-outputs - Regenerate code"
echo ""
