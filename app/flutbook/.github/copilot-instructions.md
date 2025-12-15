# Flutbook MVP: AI Agent Instructions

**Project**: Flutbook - Cross-platform Flutter Audiobook Player
**Architecture**: Clean Architecture + Riverpod 3.x State Management
**Status**: MVP Phase (45% complete, 15/33 tasks)
**Last Updated**: December 15, 2025

---


## PROJECT CONTEXT
You are working on Flutbook MVP - A Flutter audiobook player with:
- Riverpod 3.x state management
- Firebase authentication
- Isar local database
- Directory scanning for audiobooks
- Audio playback with just_audio

## AGENT WORKFLOW PRINCIPLES
1. ✅ Test-Driven Development: Write tests first
2. ✅ Follow Architecture: Use case → repository → provider → screen
3. ✅ Update Documentation: Always update MVP_STATUS.md
4. ✅ Check Build: flutter analyze must show 0 new errors
5. ✅ Follow Task Cards: Complete all acceptance criteria

## CODE PATTERNS TO FOLLOW

### USE CASE PATTERN
```dart
// In: lib/features/auth/domain/usecases/login_usecase.dart
class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<Either<AuthFailure, User>> execute(String email, String password) async {
    // Validate input first
    if (!isValidEmail(email)) return Left(AuthFailure.invalidEmail());
    if (!isValidPassword(password)) return Left(AuthFailure.invalidPassword());

    // Call repository
    return await authRepository.loginWithEmail(email, password);
  }
}

## 🏗️ Architecture Overview

### Clean Architecture Layers

Flutbook implements strict clean architecture with NO circular dependencies:

```
lib/features/[feature]/
├── presentation/      # UI (ConsumerStatefulWidget + Riverpod)
├── domain/           # Business logic (Entities, UseCases, Repositories)
└── data/             # Data sources (Local DB, APIs, File I/O)
```

**Critical Rule**: Domain layer has ZERO external imports. Data layer dependencies are injected via Riverpod providers (`lib/core/provider/providers.dart`).

### Riverpod 3.x Pattern (NOT StateNotifierProvider)

Use `NotifierProvider` with `Notifier` base class. StateNotifierProvider is deprecated:

```dart
// ✅ CORRECT - Riverpod 3.x
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => initialState;
  Future<void> action() async { /* ... */ }
}
final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);

// ❌ WRONG - Riverpod 2.x (deprecated)
class MyStateNotifier extends StateNotifier<MyState> { /* ... */ }
final myProvider = StateNotifierProvider<MyStateNotifier, MyState>(...);
```

### Dependency Injection via Riverpod

All app dependencies are defined in `lib/core/provider/providers.dart`:

1. **DatabaseService** (FutureProvider) - Isar initialization
2. **Datasources** - Depend on DatabaseService
3. **UseCases** - Depend on datasources
4. **UI Providers** - Depend on use cases

**Example**: Scanning workflow shows proper DI:
- `metadataExtractionDatasourceProvider` (File I/O, no DB)
- `audiobookLocalDatasourceProvider` (DB ops, waits for DatabaseService)
- `scanLibraryUseCaseProvider` (Orchestrates both datasources)

---

## 📂 File Organization Patterns

### Feature Structure

Each feature follows this exact structure:

```
lib/features/[feature]/
├── data/
│   ├── datasources/          # External data: files, APIs, DB
│   ├── models/               # Serializable DTOs with .fromDomain()
│   └── repositories/         # Implementation of domain interfaces
├── domain/
│   ├── entities/             # Core business objects (no imports except dart:)
│   ├── repositories/         # Abstract interfaces
│   └── usecases/             # Business logic (execute() method)
└── presentation/
    ├── pages/                # Full screens
    ├── widgets/              # Reusable UI components
    └── providers/            # Riverpod NotifierProviders for state
```

### Barrel Files (Exports)

Each layer has an `index.dart` or `[feature].dart` that re-exports public types:

```dart
// lib/features/library/library.dart
export 'domain/entities/audiobook.dart';
export 'domain/usecases/...dart';
export 'presentation/providers/...dart';
```

---

## 🔄 Workflows & Commands

### Build & Analyze

```bash
flutter analyze              # Check for errors (should have 0 new errors)
dart run build_runner build --delete-conflicting-outputs  # Generate code
```

### Testing

```bash
flutter test test/features/[feature]/    # Run tests for a feature
very_good test --coverage                # Full coverage report
genhtml coverage/lcov.info -o coverage/  # View HTML report
```

### Running the App

```bash
# Development flavor (enabled debugging, hot reload)
flutter run --flavor development --target lib/main_development.dart

# Production flavor
flutter run --flavor production --target lib/main_production.dart
```

### Code Generation

Some files are auto-generated. Modify the `.dart` file, then:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files include:
- `*.freezed.dart` (from freezed_annotation)
- `*.g.dart` (from json_serializable, isar_community_generator)

---

## 🎯 Current Project State

### Completed Phases
- ✅ **Phase 1 (Splash)**: Entry point, theming, localization
- ✅ **Phase 3 (Directory Scanning)**: File scanning, metadata extraction, Isar persistence

### In Progress
- 🔄 **Phase 2 (Authentication)**: Firebase Auth, login/signup
- 🔄 **Phase 4 (Library)**: Display audiobooks, filtering, search
- 🔄 **Phase 5 (Playback)**: Audio playback, progress tracking, UI controls

### Key Integration Points

**Database**: Isar community (local-first, embedded)
- Located: `lib/core/services/database_service.dart`
- Entities: `lib/features/library/data/models/audiobook_model.dart`
- Initialize early in bootstrap (already done)

**Authentication**: Firebase Auth + Google Sign-In
- Google credential config in `android/app/build.gradle.kts`
- Provider: `lib/core/provider/providers.dart` (will be added for Phase 2)

**Audio Playback**: audio_service + just_audio
- Playback logic: `lib/features/player/domain/`
- Provider: `lib/features/player/presentation/providers/playback_provider.dart`

---

## 💻 Code Standards

### Imports Organization

```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:riverpod/riverpod.dart';

// 4. Relative imports (this project)
import 'package:flutbook/features/...dart';
```

### Naming Conventions

| Item | Pattern | Example |
|------|---------|---------|
| Files | `snake_case.dart` | `playback_provider.dart` |
| Classes | `PascalCase` | `PlaybackNotifier`, `AudiobookModel` |
| Variables | `camelCase` | `currentTrack`, `isPlaying` |
| Constants | `camelCase` (private) or `UPPER_CASE` (public) | `_defaultTimeout`, `const MAX_SIZE = 1000` |
| Providers | `camelCase` + `Provider` | `playbackProvider`, `scanLibraryUseCaseProvider` |

### Error Handling

Flutbook defines custom exceptions in `lib/core/error/exceptions.dart`:

```dart
// Define exceptions for each error case
class DatabaseException implements Exception {
  DatabaseException(this.message);
  final String message;
}

// In datasources, throw specific exceptions
Future<void> save(Audiobook book) async {
  try {
    await _isar.writeTxn(() async { /* ... */ });
  } catch (e) {
    throw DatabaseException('Failed to save: $e');
  }
}

// In presentation layer, map exceptions to UI states
// Use AsyncValue.guard() for automatic error handling in Riverpod
```

### Testing Approach

- **Unit tests**: Test datasources, usecases, notifiers in isolation
- **Widget tests**: Use `WidgetTester.pumpApp()` helper from `test/helpers/pump_app.dart`
- **Mocking**: Use `mocktail` package for mocking dependencies
- **Coverage target**: Minimum 80% for new code

Test file location: Mirror the feature structure under `test/features/[feature]/`

---

## 🔍 Critical Patterns

### Handling Async Operations in Riverpod

Use `FutureProvider` for one-time async work, `AsyncValue` for state:

```dart
// ✅ One-time initialization (DatabaseService, dependency setup)
final databaseServiceProvider = FutureProvider<DatabaseService>((ref) async {
  final service = DatabaseService();
  await service.init();
  return service;
});

// ✅ Async state management (use case execution)
class SearchNotifier extends Notifier<AsyncValue<List<Audiobook>>> {
  @override
  AsyncValue<List<Audiobook>> build() => const AsyncValue.loading();

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
      ref.read(searchUseCaseProvider).execute(query)
    );
  }
}

// ✅ In UI: Handle AsyncValue states
ref.watch(provider).when(
  data: (data) => Text('${data.length} results'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

### Scanning Workflow (Reference Pattern)

The directory scanning feature demonstrates the complete clean architecture:

1. **User selects directory** → DirectorySelectionScreen
2. **Use case orchestrates**: ScanLibraryUseCaseImpl
   - Calls metadataExtractionDatasourceProvider (extracts from files)
   - Calls audiobookLocalDatasourceProvider (saves to DB)
3. **Result persists** → Isar database
4. **Auto-navigate** to LibraryScreen showing results

This pattern applies to all new features.

---

## ⚠️ Common Pitfalls to Avoid

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Circular dependencies | Data layer imports domain logic | Only inject dependencies via Riverpod, not imports |
| StateNotifierProvider | Deprecated in Riverpod 3.x | Use `NotifierProvider` + `Notifier` class |
| Synchronous database access | Blocks UI | Always use `async`/`await`, wrap in `FutureProvider` |
| Domain layer imports | Creates external dependencies | Keep domain pure: only dart:core imports |
| Missing error handling | Crashes propagate to users | Define exceptions, use `try`/`catch`, map to UI states |
| Hardcoded values | Not configurable, breaks testing | Use providers, environment flags, or config files |

---

## 📚 Key Files to Reference

| File | Purpose |
|------|---------|
| `lib/core/provider/providers.dart` | All Riverpod DI setup (start here for dependencies) |
| `lib/features/directory_selection/` | Complete scanning example (reference for new features) |
| `lib/features/library/domain/usecases/` | UseCase pattern (business logic orchestration) |
| `lib/core/services/database_service.dart` | Isar initialization & configuration |
| `lib/features/player/presentation/providers/playback_provider.dart` | Riverpod 3.x NotifierProvider example |
| `test/helpers/pump_app.dart` | Widget test helper |
| `analysis_options.yaml` | Code style rules (very_good_analysis) |

---

## 📋 Checklist for New Features

When implementing a new feature or phase:

- [ ] Create feature folder: `lib/features/[name]/{data,domain,presentation}`
- [ ] Define domain entities (no external imports)
- [ ] Define domain repository interfaces (abstract classes)
- [ ] Implement repository in data layer (concrete classes)
- [ ] Create datasources for external operations (DB, APIs, files)
- [ ] Implement use cases in domain layer (business logic)
- [ ] Add Riverpod providers to `lib/core/provider/providers.dart`
- [ ] Create presentation layer (pages, widgets, Riverpod notifiers)
- [ ] Write unit tests for domain & data layers (80%+ coverage)
- [ ] Write widget tests for UI
- [ ] Update `MVP_STATUS.md` with task completion
- [ ] Run `flutter analyze` (0 new errors)
- [ ] Run `flutter test` (all passing)

---

## 🚀 Quick Start for New Agents

1. Read: `documentation/START_HERE.md` (5 min overview)
2. Understand: `documentation/AGENT_INSTRUCTIONS.md` (20 min deep dive)
3. Reference: This file for architecture questions
4. Find your task in: `documentation/MVP_STATUS.md`
5. Check similar feature in: `lib/features/[completed-feature]/`
6. Implement following the patterns above
7. Test before pushing: `flutter analyze && flutter test`
8. Update status: `documentation/MVP_STATUS.md` when done

---

## 📞 When Stuck

1. **Architecture question**: Check this file + `documentation/IMPLEMENTATION_SUMMARY.md`
2. **Code pattern**: Look for similar code in completed features (Phase 1, 3)
3. **Build error**: Run `dart run build_runner build --delete-conflicting-outputs`
4. **Test failure**: Check `test/helpers/pump_app.dart` for test patterns
5. **Dependency issue**: Reference `lib/core/provider/providers.dart` for DI setup

---

**Last Updated**: December 15, 2025
**Status**: Ready for agent deployment
**Maintained By**: Flutbook Development Team
