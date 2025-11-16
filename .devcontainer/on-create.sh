#!/bin/bash
# On-create script - runs after container is created but before initialization

set -e

echo "Initializing Flutter development environment..."

# Wait for package managers to be ready
sleep 2

# Ensure Flutter is properly configured
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found in PATH, checking /opt/flutter..."
    export PATH="/opt/flutter/bin:$PATH"
fi

# Pre-cache common dependencies
flutter config --enable-web --no-analytics
flutter config --enable-linux-desktop

echo "Flutter environment initialized"
