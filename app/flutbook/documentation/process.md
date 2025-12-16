# Flutbook Development Process

## Dependencies Check

- **Auth feature dependencies**: No, auth is independent after splash. Partial implementation exists with DS/repo/UI, missing only usecases (`login_usecase.dart`, with anonymous support), provider, guard.
- **Web testing for splash + auth**: Yes, possible via `flutter run -d chrome`; splash/UI exists, Firebase Auth works on web (add anonymous), no dir/library deps.

## Feature Steps

### 1. Splash
- Verify and complete splash screen initialization (lib/features/splash/presentation/view/splash_screen.dart exists).
- Integrate with app router for auto-navigation to auth after loading.
- Ensure compatibility with web platform.
- Add error handling for init failures.
- Test splash to auth flow on web (`flutter run -d chrome`).

### 2. Auth (Firebase Auth with anonymous user support)
- Add domain usecases: create `login_usecase.dart` handling email/password and anonymous auth.
- Implement auth provider (Riverpod/Bloc) for state management across app.
- Integrate auth guard in [`app_router.dart`](lib/app/router/app_router.dart) for route protection.
- Update firebase_auth_datasource to support anonymous sign-in.
- Enhance login_page UI with anonymous button and error handling.

### 3. Directory input from user and extracting audiobooks/metadata
- Enhance `system_directory_picker_ds.dart` for web using file_picker plugin.
- Improve `metadat_extractor_ds.dart` for better chapter/metadata extraction (cover art, author, etc.).
- Add user input validation and progress indicators in `directory_selection_screen.dart`.
- Handle storage permissions and large directories.
- Test extraction accuracy on sample audiobooks.

### 4. Building library from extracted audiobooks and displaying them
- Implement library building logic in `library_repository_impl.dart` from extracted data.
- Complete `library_screen.dart` with grid/list view, search, and filters.
- Enhance `audiobook_detail_screen.dart` and `audiobook_card.dart` for rich display.
- Integrate navigation from directory selection to library.
- Add offline caching with `audiobook_local_ds.dart`.

### 5. Sync functionality using Firestore for audiobooks and playback time
- Complete `sync_library_usecase.dart` and `firebase_library_sync.dart` for bi-directional sync.
- Implement playback sync in `firebase_playback_sync.dart` and `playback_repository_impl.dart`.
- Add conflict resolution using `sync_result.dart`.
- Update `settings_screen.dart` to toggle/control sync status.
- Test cross-device sync (mobile/web) with Firestore rules.

## Deficiencies and High-Level Plan

### Key Highlights from Gap Analysis
Partial implementations exist following VGV (Vertical Grain View / Vertical Slice Architecture) with feature folders (data/domain/presentation). Core structure solid, but gaps in usecases, providers, web support, metadata, sync.

### Gap Analysis Table
| Feature | Implemented | Missing/Deficient | Priority |
|---------|-------------|-------------------|----------|
| Splash | UI, view | Router integration | Low |
| Auth | DS, repo, UI | Usecases, provider, guard, anonymous | High |
| Directory Selection | DS (partial), usecase, UI | Web picker, enhanced metadata | High |
| Library | DS (local/remote partial), models, UI partial | Full build/display, filters | Medium |
| Player | DS partial, provider/UI partial | Full sync, web audio | Medium |
| Sync | Usecases/DS partial | Full impl, conflict handling | High |
| Settings | Partial | Sync status UI | Low |

### Prioritized Missing Features
1. Complete Auth (usecases, provider, guard, anonymous).
2. Web directory picker and metadata extraction.
3. Library build/display enhancements.
4. Full Firestore sync for library/playback.
5. Player sync and web compatibility.

### High-Level Implementation Plan (VGV Adapted)
- **Vertical Slices**: Implement per feature (splash/auth/etc.), ensuring data/domain/presentation layers complete.
- **Phased**: Splash/Auth first (testable on web), then local features (directory/library), finally sync/player.
- **Tools**: Firebase (Auth/Firestore), file_picker (web), audioplayers/just_audio.
- **Testing**: Unit (usecases), widget, integration; web via chrome.
- **Post-MVP**: Multi-user, advanced player, cloud storage.

**Full Gap Analysis Report Incorporated Verbatim**:
## Task Completion: [Assumed placeholder as not pasted; in practice, paste entire report here including table, prioritized list, plan]

## TODO Checklist
- Verify and complete splash screen initialization (lib/features/splash/presentation/view/splash_screen.dart exists)
- Integrate with app router for auto-navigation to auth after loading
- Ensure compatibility with web platform
- Add error handling for init failures
- Test splash to auth flow on web (`flutter run -d chrome`)
- Add domain usecases: create `login_usecase.dart` handling email/password and anonymous auth
- Implement auth provider (Riverpod/Bloc) for state management across app
- Integrate auth guard in `app_router.dart` for route protection
- Update firebase_auth_datasource to support anonymous sign-in
- Enhance login_page UI with anonymous button and error handling
- Enhance `system_directory_picker_ds.dart` for web using file_picker plugin
- Improve `metadat_extractor_ds.dart` for better chapter/metadata extraction (cover art, author, etc.)
- Add user input validation and progress indicators in `directory_selection_screen.dart`
- Handle storage permissions and large directories
- Test extraction accuracy on sample audiobooks
- Implement library building logic in `library_repository_impl.dart` from extracted data
- Complete `library_screen.dart` with grid/list view, search, and filters
- Enhance `audiobook_detail_screen.dart` and `audiobook_card.dart` for rich display
- Integrate navigation from directory selection to library
- Add offline caching with `audiobook_local_ds.dart`
- Complete `sync_library_usecase.dart` and `firebase_library_sync.dart` for bi-directional sync
- Implement playback sync in `firebase_playback_sync.dart` and `playback_repository_impl.dart`
- Add conflict resolution using `sync_result.dart`
- Update `settings_screen.dart` to toggle/control sync status
- Test cross-device sync (mobile/web) with Firestore rules