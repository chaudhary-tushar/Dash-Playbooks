# Flutbook MVP - Code Index & Documentation

## Project Overview
**Project:** Flutter Audiobook Player Application  
**Version:** MVP 1.0  
**Status:** In Progress (Phases 1-3 ~70% Complete, Phases 4-5 Starting)

## Directory Structure
```
lib/
├── app/
│   ├── router/
│   │   └── app_router.dart
│   └── app.dart
├── core/
│   ├── constants/
│   ├── di/
│   ├── errors/
│   ├── logger/
│   ├── provider/
│   ├── services/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── directory_selection/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── library/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── player/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── splash/
│       └── presentation/
├── l10n/
├── presentation/
├── shared/
│   ├── models/
│   ├── theme/
│   └── widgets/
├── bootstrap.dart
├── main.dart
├── main_development.dart
├── main_staging.dart
└── main_production.dart
```

## Feature Breakdown

### 1. Splash Feature
**Status:** ✅ Complete  
**Location:** `lib/features/splash/`  
**Purpose:** App entry screen that auto-navigates to auth/library

#### Files:
- `lib/features/splash/presentation/splash_screen.dart` - Main splash screen UI

### 2. Authentication Feature
**Status:** ⏳ In Progress  
**Location:** `lib/features/auth/`  
**Purpose:** User authentication (email/password and guest access)

#### Domain Layer:
- `lib/features/auth/domain/usecases/login_usecase.dart` - NEW (Task 2.1)
- `lib/features/auth/domain/usecases/anonymous_login_usecase.dart` - NEW (Task 2.2)

#### Data Layer:
- `lib/features/auth/data/datasources/firebase_auth_datasource.dart` - UPDATE (Task 2.3)

#### Presentation Layer:
- `lib/features/auth/presentation/providers/auth_provider.dart` - NEW (Task 2.4)
- `lib/features/auth/presentation/login.dart` - UPDATE (Task 2.5)

#### Additional:
- `lib/app/router/auth_guard.dart` - NEW (Task 2.6)

### 3. Directory Selection & Scanning Feature
**Status:** ✅ ~85% Complete  
**Location:** `lib/features/directory_selection/`  
**Purpose:** Allow users to select a directory and scan for audiobooks

#### Domain Layer:
- `lib/features/directory_selection/domain/usecases/scan_library_usecase.dart`
- `lib/features/directory_selection/domain/usecases/select_directory_usecase.dart`

#### Data Layer:
- `lib/features/directory_selection/data/datasources/system_directory_picker_ds.dart` - Contains Task 3.5 (Handle Storage Permissions)
- `lib/features/directory_selection/data/repositories/directory_repository_impl.dart`

#### Presentation Layer:
- `lib/features/directory_selection/presentation/views/directory_selection_screen.dart`
- `lib/features/directory_selection/presentation/providers/directory_provider.dart`

### 4. Library Management Feature
**Status:** ⏳ ~40% Complete  
**Location:** `lib/features/library/`  
**Purpose:** Display and manage the user's audiobook library

#### Domain Layer:
- `lib/features/library/domain/repositories/library_repository.dart`
- `lib/features/library/domain/usecases/get_audiobooks_usecase.dart`

#### Data Layer:
- `lib/features/library/data/repositories/library_repository_impl.dart` - Contains Task 4.1 (Build Library from Scanned Audiobooks)

#### Presentation Layer:
- `lib/features/library/presentation/views/library_screen.dart` - Contains Task 4.2 (Create Library Screen)
- `lib/features/library/presentation/widgets/audiobook_card.dart` - Contains Task 4.3 (Create Audiobook Card Widget)
- `lib/features/library/presentation/providers/library_provider.dart` - Contains Task 4.4 (Implement Search Functionality)

### 5. Audio Playback Feature
**Status:** ⏳ ~30% Complete  
**Location:** `lib/features/player/`  
**Purpose:** Implement full audio playback with controls, progress tracking, and state management

#### Data Layer:
- `lib/features/player/data/datasources/audio_service_handler.dart` - Contains Task 5.1 (Set Up Audio Service)

#### Domain Layer:
- `lib/features/player/domain/entities/playback_session.dart`
- `lib/features/player/domain/repositories/playback_repository.dart`

#### Presentation Layer:
- `lib/features/player/presentation/providers/playback_provider.dart` - Contains Task 5.2 (Create Playback Provider)
- `lib/features/player/presentation/views/playback_screen.dart` - Contains Task 5.3 (Create Playback Screen)
- `lib/features/player/presentation/providers/playback_notifier.dart` - Contains Task 5.4 (Implement Play/Pause Controls)

### 6. Settings Feature
**Status:** ⏳ Not Started  
**Location:** `lib/features/settings/`  
**Purpose:** App settings and preferences

## Core Components

### App Entry Points
- `lib/main.dart` - Production app entry
- `lib/main_development.dart` - Development flavor
- `lib/main_staging.dart` - Staging flavor
- `lib/bootstrap.dart` - App initialization and dependency injection

### App Structure
- `lib/app/app.dart` - Main app widget
- `lib/app/router/app_router.dart` - App routing configuration

### Core Services
- `lib/core/services/` - Shared services (database, network, etc.)
- `lib/core/provider/` - Global state providers
- `lib/core/utils/` - Utility functions
- `lib/core/errors/` - Error handling
- `lib/core/logger/` - Logging utilities
- `lib/core/di/` - Dependency injection setup

## Testing Structure
```
test/
├── features/
│   ├── auth/
│   ├── directory_selection/
│   ├── library/
│   ├── player/
│   └── splash/
├── core/
└── shared/
```

### Test Files for Each Task:
- **Task 3.5:** `test/features/directory_selection/data/datasources/system_directory_picker_ds_test.dart`
- **Task 3.6:** `test/features/directory_selection/domain/usecases/scan_library_usecase_test.dart`, `test/features/directory_selection/presentation/view/directory_selection_screen_test.dart`
- **Task 4.1:** `test/features/library/data/repositories/library_repository_impl_test.dart`
- **Task 4.2:** `test/features/library/presentation/views/library_screen_test.dart`
- **Task 4.3:** `test/features/library/presentation/widgets/audiobook_card_test.dart`
- **Task 4.4:** `test/features/library/presentation/providers/library_provider_test.dart`
- **Task 4.5:** `test/features/library/presentation/views/library_screen_test.dart`
- **Task 4.6:** `test/features/library/domain/usecases/get_audiobooks_usecase_test.dart`, `test/features/library/presentation/views/library_screen_test.dart`
- **Task 5.1:** `test/features/player/data/datasources/audio_service_handler_test.dart`
- **Task 5.2:** `test/features/player/presentation/providers/playback_provider_test.dart`
- **Task 5.3:** `test/features/player/presentation/views/playback_screen_test.dart`
- **Task 5.4:** `test/features/player/presentation/providers/playback_notifier_test.dart`
- **Task 5.5:** `test/features/player/presentation/widgets/progress_bar_test.dart`
- **Task 5.6:** `test/features/player/presentation/widgets/playback_controls_test.dart`
- **Task 5.7:** `test/features/player/presentation/providers/playback_provider_test.dart`
- **Task 5.8:** `test/features/player/data/repositories/playback_repository_impl_test.dart`
- **Task 5.9:** `test/features/player/presentation/widgets/chapters_list_test.dart`
- **Task 5.10:** `test/features/player/domain/usecases/play_audiobook_usecase_test.dart`, `test/features/player/presentation/views/playback_screen_test.dart`

## Architecture Patterns

### Clean Architecture Layers
1. **Domain Layer** - Business logic, entities, use cases, repository interfaces
2. **Data Layer** - Repository implementations, data sources, models
3. **Presentation Layer** - UI, state management, providers, widgets

### State Management
- **Riverpod 3.x** - For state management
- **Providers** - Located in `presentation/providers/`
- **Notifiers** - For complex state management

### Data Persistence
- **Isar** - Local database
- **Firebase** - Cloud synchronization

### Audio Playback
- **just_audio** - Audio processing
- **audio_service** - Background audio service

## Key Dependencies
- Flutter SDK
- Riverpod 3.x
- Isar Database
- Firebase Auth
- just_audio
- audio_service
- file_picker
- path_provider

## Development Commands
```bash
# Setup
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run --flavor development --target lib/main_development.dart

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format lib/
```

## Current Status Summary
- **Phase 1 (Splash):** ✅ Complete
- **Phase 2 (Auth):** ⏳ In Progress (Tasks 2.1-2.8 pending)
- **Phase 3 (Directory):** ✅ ~85% Complete (Tasks 3.5-3.6 pending)
- **Phase 4 (Library):** ⏳ ~40% Complete (Tasks 4.1-4.6 pending)
- **Phase 5 (Playback):** ⏳ ~30% Complete (Tasks 5.1-5.10 pending)

## Critical Build Issues to Address
1. AudioHandler constructor issue (1 error)
2. Type casting in sync code (6 errors)
3. Type casting in playback code (3 errors)

## Next Priority Tasks
1. **Phase 2, Task 2.1:** Create Login Use Case
2. **Phase 2, Task 2.2:** Create Anonymous Login Use Case
3. **Phase 2, Task 2.3:** Update Firebase Auth Datasource
4. **Phase 2, Task 2.4:** Create Auth Provider
5. **Phase 2, Task 2.5:** Update Login Page UI

## Documentation References
- `plan-flutbookMVP.prompt.md` - Complete MVP specification
- `IMPLEMENTATION_SUMMARY.md` - Architecture patterns
- `MVP_STATUS.md` - Task tracking
- `AGENT_INSTRUCTIONS.md` - Development workflow
- `CURRENT_PROGRESS.txt` - Metrics dashboard