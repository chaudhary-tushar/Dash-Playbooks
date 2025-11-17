#!/bin/bash

# Post-start script for Flutter dev container

# Ensure Flutter is in the PATH
export PATH="$PATH:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin"

# Verify Flutter installation
flutter --version

# Verify web and desktop support is enabled
flutter devices

echo "Dev container post-start complete!"