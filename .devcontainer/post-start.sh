#!/bin/bash
# Post-start script - runs every time container starts

set -e

cd /workspace

echo "Flutter Audiobook Player Development Environment Ready"
echo "======================================================="
echo ""
echo "Quick Start:"
echo "  • Web:     flutter run -d web"
echo "  • Linux:   flutter run -d linux"
echo "  • Tests:   flutter test"
echo ""
echo "Ports Forwarded:"
echo "  • 3000: Development Server"
echo "  • 8000: Web Server (Testing)"
echo "  • 8080: Android Debug"
echo "  • 9090: Flutter DevTools"
echo ""

# Check if pubspec.lock exists
if [ ! -f "pubspec.lock" ]; then
    echo "Running flutter pub get..."
    flutter pub get
fi
