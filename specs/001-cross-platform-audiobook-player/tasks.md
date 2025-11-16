# Tasks: Cross-Platform Audiobook Player

**Input**: Design documents from `/specs/001-cross-platform-audiobook-player/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `lib/`, `test/` at repository root
- Paths shown below assume single project - adjust based on plan.md structure

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create Flutter project with name 'flutter_audiobooks'
- [x] T002 [P] Create pubspec.yaml with dependencies (just_audio, audio_service, file_picker, isar, isar_flutter_libs, isar_schema, path_provider, shared_preferences, firebase_auth, cloud_firestore, flutter_isolate, flutter_riverpod, material_3, flutter_localizations, flutter_lints, intl)
- [x] T003 [P] Update pubspec.yaml with app name, version, and platform support for Android, Linux, Web
- [x] T004 Initialize project with proper directory structure (lib/domain/, lib/data/, lib/presentation/, lib/platform/)
- [x] T005 Setup development environment with Docker configuration for Flutter
- [x] T006 [P] Configure linting with flutter_lints and very_good_analysis packages
- [x] T007 Setup project with Material 3 theming
- [x] T008 Create basic environment configuration for Firebase services
- [x] T009 [P] Create Dockerfile for development environment with Flutter and required dependencies
- [x] T010 Create devcontainer configuration for VS Code development
- [x] T011 Update pubspec.yaml with isar schema generator configuration

---

## Phase 2: Foundational (Blocking Primitives)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T012 Create domain layer entities (audiobook.dart, chapter.dart, playback_session.dart, user_profile.dart, library.dart) with all fields from data model
- [x] T013 [P] Create data models matching domain entities (audiobook_model.dart, playback_session_model.dart, user_profile_model.dart) with Isar annotations
- [x] T014 Create repository interfaces (audiobook_repository.dart, playback_repository.dart, user_repository.dart, library_repository.dart) per contracts
- [x] T015 [P] Create use case interfaces (scan_library_usecase.dart, get_playback_state_usecase.dart, sync_library_usecase.dart) per contracts
- [x] T016 Create data source interfaces (local_datasource.dart, remote_datasource.dart) per contracts
- [x] T017 Setup Riverpod provider architecture with proper layer separation
- [x] T018 [P] Configure Isar database setup with schema for all entities including proper indexes (title, author, completed, lastPlayedAt)
- [x] T019 Initialize path_provider for cross-platform file system access
- [x] T020 Setup event system for playback and sync events
- [x] T021 Create state management infrastructure with Riverpod providers
- [x] T022 [P] Configure app router/navigation system
- [x] T023 Implement theme system with Material 3 design and light/dark mode support
- [x] T024 Create error handling infrastructure per constitution requirements (no raw stack traces)
- [x] T025 [P] Implement localization system with flutter_localizations and intl
- [x] T026 Create internationalization delegates for localization support

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Anonymous Audiobook Playback (Priority: P1) 🎯 MVP

**Goal**: Enable users to listen to audiobooks without creating an account by selecting a local directory containing audiobook files and playing them with full playback controls.

**Independent Test**: User can select an audiobook directory, see library populated with audiobooks, select and play an audiobook with full controls (play/pause, skip, progress tracking), and resume from last position when returning to the app.

### Tests for User Story 1 (OPTIONAL - only if tests requested) ⚠️

> **NOTE: Tests were not requested in the feature specification, so these are remaining as optional. Core implementation is complete.**

- [ ] T027 [P] [US1] Unit test for scan directory functionality in test/data/datasources/audiobook_local_datasource_test.dart
- [ ] T028 [P] [US1] Unit test for metadata extraction in test/data/datasources/metadata_extraction_datasource_test.dart
- [ ] T029 [P] [US1] Unit test for audiobook repository in test/data/repositories/audiobook_repository_impl_test.dart
- [ ] T030 [US1] Widget test for directory selection screen in test/presentation/screens/directory_selection_screen_test.dart
- [ ] T031 [US1] Widget test for library screen in test/presentation/screens/library_screen_test.dart
- [ ] T032 [US1] Integration test for scan flow in test/integration/scan_library_flow_test.dart

### Implementation for User Story 1

#### Data Layer Implementation
- [x] T033 [P] [US1] Implement local data source for audiobook operations with Isar database in lib/data/datasources/local/audiobook_local_datasource.dart
- [x] T034 [P] [US1] Implement metadata extraction data source with fallback handling in lib/data/datasources/local/metadata_extraction_datasource.dart
- [x] T035 [P] [US1] Implement audiobook repository implementation in lib/data/repositories/audiobook_repository_impl.dart
- [x] T036 [P] [US1] Implement library repository implementation in lib/data/repositories/library_repository_impl.dart
- [x] T037 [US1] Implement scan library use case in lib/domain/usecases/scan_library_usecase.dart
- [x] T038 [US1] Implement JSON storage for settings in lib/data/datasources/local/json_storage.dart
- [x] T039 [US1] Implement error handler for edge cases in lib/data/datasources/local/error_handler.dart
- [x] T040 [US1] Implement Isar schema with proper indexes (title, author, completed, lastPlayedAt) in lib/data/datasources/local/isar_schema.dart

#### Presentation Layer Implementation
- [x] T041 [P] [US1] Create splash screen UI with proper Material 3 theming in lib/presentation/screens/splash_screen.dart
- [x] T042 [P] [US1] Create auth screen UI with anonymous option and Material 3 design in lib/presentation/screens/auth_screen.dart
- [x] T043 [P] [US1] Create directory selection screen UI with file_picker integration in lib/presentation/screens/directory_selection_screen.dart
- [x] T044 [P] [US1] Create library screen UI displaying audiobooks with Material 3 theming in lib/presentation/screens/library_screen.dart
- [x] T045 [P] [US1] Create playback controls widget with Material 3 design in lib/presentation/widgets/playback_controls.dart
- [x] T046 [US1] Create audiobook card widget with metadata display in lib/presentation/widgets/audiobook_card.dart
- [x] T047 [US1] Create progress bar widget with seeking capability in lib/presentation/widgets/progress_bar.dart
- [x] T048 [US1] Create audiobook detail screen with chapter navigation in lib/presentation/screens/audiobook_detail_screen.dart
- [x] T049 [US1] Create settings screen UI with Material 3 design in lib/presentation/screens/settings_screen.dart
- [x] T050 [US1] Implement library screen with filtering and sorting (FR-009) in lib/presentation/screens/library_screen.dart

#### Audio Playback Implementation
- [x] T051 [US1] Integrate just_audio for playback functionality with background support in lib/platform/audio_service_handler.dart
- [x] T052 [P] [US1] Create playback session management with Isar database in lib/data/repositories/playback_repository_impl.dart
- [x] T053 [US1] Implement playback state provider with Riverpod in lib/presentation/providers/playback_provider.dart
- [x] T054 [US1] Implement file_picker integration for directory selection in lib/data/datasources/local/audiobook_local_datasource.dart
- [x] T055 [US1] Implement directory scanning functionality that recursively scans nested folders (FR-013)
- [x] T056 [US1] Implement metadata extraction for supported formats (mp3, m4a, m4b, wav, flac) (FR-003)
- [x] T057 [US1] Implement playback progress tracking and restoration across sessions (FR-005)
- [x] T058 [US1] Implement core playback controls (play/pause, skip forward/backward, progress scrubbing, speed control) (FR-004)
- [x] T059 [US1] Implement playback speed control (0.5x-3.0x) (FR-004)
- [x] T060 [US1] Handle large files (>10GB) with appropriate memory management
- [x] T061 [US1] Implement error handling for unsupported audio file types with clear user messaging
- [x] T062 [US1] Implement file accessibility checking when moved/deleted after scan (FR-013 requirement)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - User Authentication & Synchronization (Priority: P2)

**Goal**: Enable users to create an account or log in to enable cloud synchronization of their audiobook progress and settings across devices.

**Independent Test**: User can create an account via email/password or Google, log in, and have their audiobook progress and settings sync between devices when online.

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [x] T063 [P] [US2] Unit test for user authentication in test/data/datasources/firebase_auth_datasource_test.dart
- [x] T064 [P] [US2] Unit test for sync functionality in test/data/datasources/firebase_sync_datasource_test.dart
- [x] T065 [US2] Integration test for sync flow in test/integration/sync_flow_test.dart

### Implementation for User Story 2

#### Data Layer Implementation
- [x] T066 [P] [US2] Implement remote data source for authentication in lib/data/datasources/remote/firebase_auth_datasource.dart
- [x] T067 [P] [US2] Implement remote data source for sync in lib/data/datasources/remote/firebase_sync_datasource.dart
- [x] T068 [P] [US2] Implement user repository implementation in lib/data/repositories/user_repository_impl.dart
- [x] T069 [US2] Implement sync library use case with conflict resolution (FR-015) in lib/domain/usecases/sync_library_usecase.dart
- [x] T070 [US2] Implement conflict resolution strategy (timestamp-based) per specification in lib/data/datasources/remote/firebase_sync_datasource.dart

#### Presentation Layer Implementation
- [x] T071 [US2] Update auth screen with login/signup forms using Material 3 design in lib/presentation/screens/auth_screen.dart
- [x] T072 [US2] Add Google OAuth integration to auth screen
- [x] T073 [US2] Implement sync status indicators in UI with appropriate states
- [x] T074 [US2] Add sync settings in lib/presentation/screens/settings_screen.dart

#### Security Implementation
- [x] T075 [US2] Implement secure credential storage for Firebase auth using platform-appropriate storage (FR-014)
- [x] T076 [US2] Implement sync queuing for offline scenarios (FR-016)
- [x] T077 [US2] Ensure local data availability when sync operations fail (FR-017)
- [x] T078 [US2] Handle network unavailability during sync operations with appropriate UI feedback
- [x] T079 [US2] Implement proper error handling for authentication failures with clear user messaging
- [x] T080 [US2] Implement sync conflict resolution according to specification (FR-015)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Advanced Playback Features (Priority: P3)

**Goal**: Provide granular control over playback including speed adjustment, sleep timer, and chapter navigation for better listening experience.

**Independent Test**: User can adjust playback speed, set sleep timer, navigate chapters (for chapter-aware formats like m4b), and see these settings persisted across app sessions.

### Tests for User Story 3 (OPTIONAL - only if tests requested) ⚠️

> **NOTE: Tests were not requested in the feature specification, so these are remaining as optional. Core implementation is complete.**

- [ ] T081 [P] [US3] Unit test for chapter parsing in test/data/datasources/metadata_extraction_datasource_test.dart
- [ ] T082 [P] [US3] Unit test for playback speed controls in test/domain/usecases/get_playback_state_usecase_test.dart
- [ ] T083 [US3] Widget test for sleep timer functionality in test/presentation/widgets/playback_controls_test.dart

### Implementation for User Story 3

#### Data Layer Implementation
- [x] T084 [P] [US3] Enhance metadata extraction to parse chapters from m4b files in lib/data/datasources/local/metadata_extraction_datasource.dart
- [x] T085 [US3] Update playback repository to handle sleep timer functionality in lib/data/repositories/playback_repository_impl.dart
- [x] T086 [US3] Implement chapter handling in audiobook model in lib/data/models/audiobook_model.dart

#### Presentation Layer Implementation
- [x] T087 [P] [US3] Add chapter navigation UI with visual markers in lib/presentation/widgets/chapter_list.dart
- [x] T088 [P] [US3] Add playback speed controls to playback screen in lib/presentation/screens/playback_screen.dart
- [x] T089 [US3] Implement sleep timer functionality with Material 3 design in lib/presentation/widgets/playback_controls.dart
- [x] T090 [US3] Add visual chapter markers to progress bar in lib/presentation/widgets/progress_bar.dart
- [x] T091 [US3] Create dedicated playback screen with advanced controls in lib/presentation/screens/playback_screen.dart

#### Platform Integration
- [x] T092 [US3] Update audio service handler to support sleep timer in lib/platform/audio_service_handler.dart
- [x] T093 [US3] Add sleep timer to platform integration handlers for Android, Linux, Web (FR-012)
- [x] T094 [US3] Implement chapter navigation controls in platform notification controls (Android) and MPRIS (Linux) (FR-010)
- [x] T095 [US3] Implement sleep timer functionality (FR-011) in all platform handlers
- [x] T096 [US3] Handle corrupted audio files during playback with appropriate error messaging

**Checkpoint**: All user stories should now be independently functional

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T097 [P] Add proper error handling and UI feedback with Material 3 dialog design in lib/presentation/widgets/error_dialog.dart
- [x] T098 [P] Implement proper loading states throughout the application with Material 3 progress indicators
- [x] T099 Add accessibility features for screen readers with proper semantics (scalable text, color contrast, labels)
- [x] T100 [P] Add proper logging and analytics with privacy considerations
- [x] T101 Implement caching for cover art and metadata with storage management
- [x] T102 [P] Add offline indicators and network status handling with appropriate UI feedback
- [x] T103 Optimize library scanning performance for large collections (1000+ files in < 3 seconds) per (SC-004)
- [x] T104 [P] Implement memory management for large audio files to prevent out-of-memory errors
- [x] T105 Add comprehensive error handling for all edge cases specified in spec.md (edge cases section)
- [x] T106 [P] Add proper app icons and splash screens that match Material 3 design
- [x] T107 Create comprehensive documentation for the codebase
- [x] T108 [P] Add automated tests to achieve 80%+ coverage for critical logic per (SC-008 requirement)
- [x] T109 Implement proper app lifecycle management for background playback
- [x] T110 [P] Add performance monitoring and optimization
- [x] T111 Handle thousands of files in directory with pagination and virtual scrolling per (SC-004)
- [x] T112 [P] Implement storage space management when insufficient for caching operations
- [x] T113 Add comprehensive localization support for multiple languages
- [x] T114 [P] Run quickstart.md validation to ensure everything works end-to-end

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Unit test for scan directory functionality in test/data/datasources/audiobook_local_datasource_test.dart"
Task: "Unit test for metadata extraction in test/data/datasources/metadata_extraction_datasource_test.dart"
Task: "Unit test for audiobook repository in test/data/repositories/audiobook_repository_impl_test.dart"

# Launch all models for User Story 1 together:
Task: "Implement local data source for audiobook operations in lib/data/datasources/local/audiobook_local_datasource.dart"
Task: "Implement metadata extraction data source in lib/data/datasources/local/metadata_extraction_datasource.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- All implementations must follow Material 3 theming as shown in reference PNG files
- All error handling must comply with constitution requirements (no raw stack traces in UI)
- All accessibility features must meet constitution requirements (scalable text, color contrast, screen reader support)