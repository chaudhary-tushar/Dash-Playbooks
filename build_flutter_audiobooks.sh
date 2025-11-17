#!/usr/bin/env bash

# Script: build_flutter_audiobooks.sh
# Purpose: Build the Flutter Audiobook Player Docker image with all necessary configurations
# Usage: ./build_flutter_audiobooks.sh [OPTIONS]

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Default values
IMAGE_NAME="flutter-audiobook-player"
CONTAINER_NAME="audiobook-player-build"
BUILD_TYPE="web"  # Default build type (web, android, linux)
OUTPUT_DIR="output"

# Print usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -t, --type TYPE      Build type: web, android, linux (default: web)"
    echo "  -o, --output DIR     Output directory (default: output)"
    echo "  -i, --image NAME     Docker image name (default: flutter-audiobook-player)"
    echo "  -c, --container NAME Container name (default: audiobook-player-build)"
    echo "  -h, --help           Show this help message"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -i|--image)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -c|--container)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Print header
echo "======================================"
echo "Building Flutter Audiobook Player"
echo "Build Type: $BUILD_TYPE"
echo "Output Dir: $OUTPUT_DIR"
echo "Image Name: $IMAGE_NAME"
echo "======================================"

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(web|android|linux)$ ]]; then
    echo "Error: Invalid build type '$BUILD_TYPE'. Valid options: web, android, linux"
    exit 1
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to build Docker image
build_image() {
    echo "Building Docker image: $IMAGE_NAME"

    # Check if Dockerfile.build exists, create it if needed
    if [[ ! -f "Dockerfile.build" ]]; then
        echo "Creating Dockerfile.build for Flutter build..."
        cat > Dockerfile.build << 'EOF'
FROM flutter-audiobook-player:dev

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml .

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Pre-build Isar schema
RUN flutter packages pub run build_runner build --delete-conflicting-outputs

# Build the application based on target
ARG BUILD_TARGET=web
ENV BUILD_TARGET=${BUILD_TARGET}

RUN if [ "$BUILD_TARGET" = "web" ]; then \
        flutter build web --release --web-renderer canvaskit; \
    elif [ "$BUILD_TARGET" = "linux" ]; then \
        flutter build linux --release; \
    elif [ "$BUILD_TARGET" = "android" ]; then \
        flutter build apk --release; \
    fi

EXPOSE 3000

CMD ["bash"]
EOF
    fi

    # Build the Docker image based on the target
    docker build \
        --build-arg BUILD_TARGET="$BUILD_TYPE" \
        --tag "$IMAGE_NAME" \
        --file Dockerfile.build . || {
        echo "Error: Docker image build failed"
        exit 1
    }
}

# Function to build and extract artifacts
build_and_extract_artifacts() {
    echo "Building $BUILD_TYPE application..."

    # Run container to perform build
    container_id=$(docker create "$IMAGE_NAME" bash)

    echo "Container created: $container_id"

    # Copy build artifacts from container
    if [[ "$BUILD_TYPE" == "web" ]]; then
        docker cp "$container_id:/app/build/web/." "$OUTPUT_DIR/"
        echo "Web build artifacts copied to: $OUTPUT_DIR/"
        echo "To serve locally: cd $OUTPUT_DIR && python3 -m http.server 8000"
    elif [[ "$BUILD_TYPE" == "linux" ]]; then
        docker cp "$container_id:/app/build/linux/x64/release/bundle/." "$OUTPUT_DIR/"
        echo "Linux build artifacts copied to: $OUTPUT_DIR/"
        echo "To run: cd $OUTPUT_DIR && ./flutter_audiobooks"
    elif [[ "$BUILD_TYPE" == "android" ]]; then
        docker cp "$container_id:/app/build/app/outputs/flutter-apk/app-release.apk" "$OUTPUT_DIR/"
        echo "Android APK copied to: $OUTPUT_DIR/app-release.apk"
        echo "To install on device: adb install $OUTPUT_DIR/app-release.apk"
    fi

    # Clean up
    docker rm -v "$container_id" > /dev/null
}

# Function to run web server for testing UI
serve_web_ui() {
    if [[ "$BUILD_TYPE" == "web" ]]; then
        echo ""
        echo "====================================="
        echo "SERVING WEB APPLICATION FOR TESTING"
        echo "====================================="
        echo "Navigate to: http://localhost:8000"
        echo "Press Ctrl+C to stop server"
        echo ""
        cd "$OUTPUT_DIR"
        python3 -m http.server 8000
    fi
}

# Build the Docker image
build_image

# Build and extract artifacts
build_and_extract_artifacts

# Serve web UI if that was the build target
if [[ "$BUILD_TYPE" == "web" ]]; then
    echo ""
    echo "BUILD COMPLETE!"
    echo "Web artifacts are in: $OUTPUT_DIR/"
    echo ""
    read -p "Would you like to serve the web UI for testing? (y/n): " -n 1 -r REPLY
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        serve_web_ui
    else
        echo "Build artifacts are ready in: $OUTPUT_DIR/"
        echo "To serve manually: cd $OUTPUT_DIR && python3 -m http.server 8000"
    fi
else
    echo ""
    echo "BUILD COMPLETE!"
    echo "Artifacts are in: $OUTPUT_DIR/"
fi