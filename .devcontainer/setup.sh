#!/bin/bash

# Setup script for Flutter dev container

# Ensure Flutter is in the PATH
export PATH="$PATH:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin"

# Enable Flutter web and Linux desktop support
flutter config --enable-web
flutter config --enable-linux-desktop

# Get Flutter dependencies
flutter pub get

# Activate build_runner for code generation
dart pub global activate build_runner

echo "Dev container setup complete!"