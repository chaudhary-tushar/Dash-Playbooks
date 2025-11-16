# Implementation Plan: Cross-Platform Audiobook Player

**Branch**: `001-cross-platform-audiobook-player` | **Date**: 2025-11-15 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-cross-platform-audiobook-player/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Build a cross-platform, offline-first audiobook player using Flutter targeting Android, Linux, and Web. The application follows a layered architecture with shared Dart business logic and platform-specific integrations. Core functionality includes directory scanning, metadata extraction, audio playback with progress tracking, and optional cloud synchronization for authenticated users. The app uses Isar database with proper schema and indexing for local offline data, JSON files for settings, and Firebase for authenticated user synchronization. The UI implements Material 3 design principles for consistent cross-platform experience with full accessibility support. Proper error handling is implemented for all edge cases identified in the specification with clear messages and no raw stack traces in UI per constitution requirements.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.x
**Primary Dependencies**:
- just_audio (audio playback)
- audio_service (background playback)
- file_picker (directory selection)
- isar (local storage)
- isar_flutter_libs (Isar dependencies)
- isar_schema (Isar schema generator)
- firebase_auth, cloud_firestore (authentication and sync)
- flutter_isolate (heavy parsing operations)
- path_provider (file system access)
- shared_preferences (settings storage)
- flutter_riverpod (state management)
- material_3 (UI components)
- flutter_localizations (internationalization)
- flutter_lints (linting)
**Storage**: Local Isar database for offline data with proper schema and indexing as per data model, JSON files for settings, Firebase Firestore for cloud sync
**Testing**: flutter_test (unit/widget tests), integration_test (integration tests)
**Target Platform**: Android, Linux, Web (iOS/Windows to be added later)
**Project Type**: Single Flutter application with shared codebase
**Performance Goals**:
- Library scan: 1000+ files in < 3 seconds
- Cold start: < 2 seconds on mid-range Android device
- Audio playback: Gapless, minimal buffering
**Constraints**:
- Offline-first architecture (all core features work without internet)
- Cross-platform UI consistency with Material 3 design
- Background playback support
- Efficient memory usage for large audio files
- Strict adherence to Material 3 theming across all platforms
- Isar database with proper schema and indexing for efficient queries as per data model requirements
- Accessibility features including scalable text, color contrast, and screen readers per constitution
- Cross-platform consistency required for all UI elements
- Proper error handling for all edge cases mentioned in specification
- Docker-based development and CI/CD pipeline required per constitution
- Isar schema must be properly configured with indexes for title, author, completed status, and lastPlayedAt fields
- Error handling must be implemented for all edge cases: unsupported audio files, large files (>10GB), file moved/deleted after scan, insufficient storage, network unavailability, authentication failures, corrupted files
**Scale/Scope**: Single-user application, thousands of audiobooks per library

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Code Quality Principles**:
- ✅ Single Source of Truth: Core logic in shared Dart modules (domain layer)
- ✅ Layered Architecture: domain/, data/, presentation/, platform/ structure with proper separation
- ✅ State Management: Using Riverpod for explicit state management
- ✅ Isar Database: Proper schema and indexing for efficient queries as per data model

**Coding Style & Linting**:
- ✅ Formatter: dart format will be used
- ✅ Linting: flutter_lints and very_good_analysis lint ruleset
- ✅ Naming: Intent-revealing names (NowPlayingScreen, LibraryRepository)

**Testing Standards**:
- ✅ Unit Tests: Domain logic, playback state transitions
- ✅ Widget Tests: UI components and screens
- ✅ Integration Tests: Cross-layer flows
- ✅ Coverage: Target 80%+ for critical logic
- ✅ Docker-based CI: Pipeline runs tests and analysis

**UX Consistency**:
- ✅ Cross-Platform Design: Material 3 design system implemented with consistency across platforms
- ✅ Audio UX: Consistent semantics for playback controls
- ✅ Accessibility: Scalable text, color contrast, screen reader support per constitution

**Performance Requirements**:
- ✅ Responsiveness: Cold start <2s target
- ✅ Memory: Avoid holding large audio buffers, efficient caching
- ✅ Battery: Efficient APIs for background playback

**Docker-Based Development**:
- ✅ No Host Dependency: Flutter/Dart in containers
- ✅ Devcontainer: VS Code setup with all dependencies
- ✅ CI/CD: Docker-based pipeline required

## Post-Design Constitution Check

**Code Quality Principles**:
- ✅ Architecture validated: Clear separation of domain, data, presentation, and platform layers
- ✅ Entity definitions follow immutable patterns as required
- ✅ Repository pattern implemented as required
- ✅ Isar database with proper schema and indexing for efficient queries: indexes configured for title, author, completed, and lastPlayedAt fields

**UX Consistency**:
- ✅ Material 3 theming implemented consistently across all platforms
- ✅ Design system ensures cross-platform consistency as required
- ✅ Accessibility features implemented per constitution (scalable text, color contrast, screen readers)

**Testing Standards**:
- ✅ Test interfaces defined for all repository and use case classes
- ✅ Contract tests will validate repository interfaces
- ✅ Integration points identified for testing
- ✅ Docker-based CI pipeline required per constitution

**Performance Requirements**:
- ✅ Design addresses memory constraints with lazy loading
- ✅ Background playback architecture supports efficiency requirements
- ✅ Storage solutions selected for optimal performance (Isar with proper indexing)

**Error Handling & Edge Cases**:
- ✅ All edge cases from specification addressed: unsupported files, large files (>10GB), files moved/deleted, insufficient storage, network unavailability, auth failures, corrupted files
- ✅ Error handling implemented per constitution: clear messages, no raw stack traces in UI

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── domain/              # Core business logic (entities, use-cases, repositories)
│   ├── entities/
│   │   ├── audiobook.dart
│   │   ├── playback_session.dart
│   │   ├── user_profile.dart
│   │   └── library.dart
│   ├── repositories/
│   │   ├── audiobook_repository.dart
│   │   ├── playback_repository.dart
│   │   ├── user_repository.dart
│   │   └── library_repository.dart
│   └── usecases/
│       ├── scan_library_usecase.dart
│       ├── get_playback_state_usecase.dart
│       └── sync_library_usecase.dart
├── data/                # Concrete implementations (storage, APIs, file IO)
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── audiobook_local_datasource.dart
│   │   │   ├── isar_storage.dart
│   │   │   ├── isar_schema.dart
│   │   │   ├── json_storage.dart
│   │   │   ├── preferences_datasource.dart
│   │   │   └── error_handler.dart
│   │   └── remote/
│   │       ├── firebase_auth_datasource.dart
│   │       ├── firebase_sync_datasource.dart
│   │       └── metadata_extraction_datasource.dart
│   ├── models/
│   │   ├── audiobook_model.dart
│   │   ├── playback_session_model.dart
│   │   └── user_profile_model.dart
│   ├── repositories/
│   │   ├── audiobook_repository_impl.dart
│   │   ├── playback_repository_impl.dart
│   │   └── user_repository_impl.dart
│   └── providers/
│       ├── audiobook_provider.dart
│       ├── playback_provider.dart
│       └── sync_provider.dart
├── presentation/        # Flutter widgets, state management, navigation
│   ├── providers/
│   │   ├── audiobook_provider.dart
│   │   ├── playback_provider.dart
│   │   └── ui_state_provider.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth_screen.dart
│   │   ├── library_screen.dart
│   │   ├── playback_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── playback_controls.dart
│   │   ├── audiobook_card.dart
│   │   ├── progress_bar.dart
│   │   ├── chapter_list.dart
│   │   └── error_dialog.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── material_3_theme.dart
│   ├── i18n/
│   │   ├── app_localizations.dart
│   │   └── localization_delegates.dart
│   └── navigation/
│       └── app_router.dart
└── platform/            # Platform integrations (notifications, background playback)
    ├── android/
    │   └── audio_service_handler.dart
    ├── linux/
    │   └── mpris_handler.dart
    └── web/
        └── media_session_handler.dart
```

**Structure Decision**: Single Flutter application following layered architecture as required by constitution. Domain layer contains pure Dart business logic, data layer handles storage and external APIs with proper Isar schema configuration, presentation layer manages UI with Material 3 theming and accessibility features, and platform layer handles platform-specific integrations. Isar database chosen with proper schema and indexing for fast performance with large audiobook libraries. Error handling implemented per constitution requirements with clear messages and no raw stack traces in UI.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
