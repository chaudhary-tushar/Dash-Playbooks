# Docker & DevContainer Setup Guide

This project includes Docker and DevContainer configurations for a consistent development and testing environment.

## Quick Start with DevContainer (Recommended for VS Code)

### Prerequisites
- VS Code installed
- Docker Desktop installed and running
- VS Code Remote - Containers extension installed

### Setup
1. Open the project in VS Code
2. VS Code will detect `.devcontainer/devcontainer.json` and prompt to "Reopen in Container"
3. Click "Reopen in Container"
4. Wait for the container to build and setup complete
5. Start developing!

## Docker Compose (Local Development)

### Build and Start
```bash
docker-compose up -d
```

### Enter the Development Container
```bash
docker-compose exec flutter-dev bash
```

### Build for Different Targets

Inside the container, use these commands:

```bash
# Web build (default)
flutter build web --release --web-renderer canvaskit

# Linux build
flutter build linux --release

# Android APK
flutter build apk --release
```

## Manual Docker Build

### Build Image
```bash
docker build -t flutter-audiobook-player:dev .
```

### Run Container
```bash
docker run -it \
  -v $(pwd):/workspace \
  -v flutter-pub-cache:/root/.pub-cache \
  -p 3000:3000 \
  -p 8000:8000 \
  -p 8080:8080 \
  -p 9090:9090 \
  flutter-audiobook-player:dev
```

## Available Development Targets

### Web Development
```bash
flutter run -d web
# Then navigate to http://localhost:3000
```

### Linux Desktop
```bash
flutter run -d linux
```

### Android Emulator
```bash
flutter run -d emulator-5554
```

### Run Tests
```bash
flutter test
```

## Code Generation

After modifying models or data classes that need code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Ports

- **3000**: Flutter development server
- **8000**: Web server for built artifacts
- **8080**: Android Debug Bridge
- **9090**: Flutter DevTools

## VS Code Extensions (Auto-installed in DevContainer)

- Dart Code
- Flutter
- Python
- Ruff (Linter)
- Material Theme
- GitHub Copilot

## Troubleshooting

### Cache Issues
```bash
# Clear pub cache
docker-compose exec flutter-dev flutter pub cache clean

# Rebuild all generated files
docker-compose exec flutter-dev flutter pub run build_runner build --delete-conflicting-outputs
```

### Container Issues
```bash
# Rebuild image without cache
docker-compose build --no-cache

# Remove all containers and volumes
docker-compose down -v
```

### Slow Performance
- Use named volumes for better I/O performance
- Check Docker Desktop resource allocation (Memory, CPU)

## Building for Production

### Web Release
```bash
docker run -it \
  -v $(pwd):/workspace \
  -v flutter-pub-cache:/root/.pub-cache \
  flutter-audiobook-player:dev \
  bash -c "flutter build web --release --web-renderer canvaskit"
```

The built files will be in `build/web/` directory.

### Extract Artifacts
```bash
docker cp <container-id>:/workspace/build/web/. ./output/
```

## Environment Variables

Inside the container, these are automatically set:

- `FLUTTER_ROOT=/opt/flutter`
- `ANDROID_HOME=/opt/android-sdk-linux`
- `ANDROID_SDK_ROOT=/opt/android-sdk-linux`
- `PUB_CACHE=/root/.pub-cache`
