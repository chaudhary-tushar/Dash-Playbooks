#!/bin/bash

# On-create script for Flutter dev container

# Ensure Flutter is in the PATH
export PATH="$PATH:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin"

# Get Flutter dependencies
flutter pub get

# Run build runner to generate code
flutter pub run build_runner build --delete-conflicting-outputs

echo "Dev container on-create complete!"