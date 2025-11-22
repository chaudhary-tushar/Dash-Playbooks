# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Structure
- Main application code resides in `app/flutbook/`, not in project root
- Dual entry points: `lib/main.dart` (root) and `app/flutbook/lib/main.dart` (main app)

## Build Requirements
- Isar schema generation must be run before building: generates `app/flutbook/lib/data/datasources/local/isar_schema.g.dart`
- Custom build script with Docker support for multi-platform builds
- Platform-specific setup script: `./add_platforms.sh`

## Bootstrap & Architecture
- Bootstrap pattern using `app/flutbook/lib/bootstrap.dart` with custom Riverpod observer
- Firebase integration is optional and commented out in code

## Web Builds
- Docker builds default to CanvasKit renderer for web

## Testing & Analysis
- Tests use very_good test runner with specific flags
- Code analysis excludes generated files with special headers