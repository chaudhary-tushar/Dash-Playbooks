# Migration Plan for Feature-Based Architecture

This document outlines the tasks to migrate files from the monolithic `domain`, `data`, and `presentation` directories into feature-specific directories under `features/`. The goal is to achieve separation of concerns by grouping related functionality into specific features.

## Identified Features

Based on the current codebase analysis, the following features have been identified:

1. **Auth** - User authentication and profile management
2. **Library** - Audiobook library management, scanning, and metadata
3. **Playback** - Audio playback controls and session management
4. **Directory Selection** - Directory/folder selection for library sources
5. **Settings** - Application settings
6. **Splash** - Application splash screen

## Migration Tasks

### Auth Feature

#### Domain Layer
- Move `domain/entities/user_profile.dart` to `features/auth/domain/entities/user_profile.dart`
- Move `domain/repositories/user_repository.dart` to `features/auth/domain/repositories/user_repository.dart`

#### Data Layer
- Move `data/datasources/remote/firebase_auth_datasource.dart` to `features/auth/data/datasources/firebase_auth_datasource.dart`
- Move `data/models/user_profile_model.dart` to `features/auth/data/models/user_profile_model.dart`
- Move `data/models/user_profile_model.g.dart` to `features/auth/data/models/user_profile_model.g.dart`
- Move `data/repositories/user_repository_impl.dart` to `features/auth/data/repositories/user_repository_impl.dart`

#### Presentation Layer
- Move `presentation/screens/auth_screen.dart` to `features/auth/presentation/views/auth_screen.dart`
- The following login-related files are already in `features/auth/presentation/`:
  - `widgets/login_buttons.dart`
  - `widgets/login_form.dart`
  - `widgets/login_header.dart`
  - `widgets/login_illustration.dart`
  - `login.dart`
  - `views/login_page.dart`

### Library Feature

#### Domain Layer
- Move `domain/entities/audiobook.dart` to `features/library/domain/entities/audiobook.dart`
- Move `domain/entities/chapter.dart` to `features/library/domain/entities/chapter.dart`
- Move `domain/entities/filter.dart` to `features/library/domain/entities/filter.dart`
- Move `domain/entities/library.dart` to `features/library/domain/entities/library.dart`
- Move `domain/repositories/audiobook_repository.dart` to `features/library/domain/repositories/audiobook_repository.dart`
- Move `domain/repositories/library_repository.dart` to `features/library/domain/repositories/library_repository.dart`
- Move `domain/usecases/scan_library_usecase.dart` to `features/library/domain/usecases/scan_library_usecase.dart`
- Move `domain/usecases/sync_library_usecase.dart` to `features/library/domain/usecases/sync_library_usecase.dart`

#### Data Layer
- Move `data/datasources/local/audiobook_local_datasource.dart` to `features/library/data/datasources/audiobook_local_datasource.dart`
- Move `data/datasources/local/metadata_extraction_datasource.dart` to `features/library/data/datasources/metadata_extraction_datasource.dart`
- Move `data/datasources/local/json_storage.dart` to `features/library/data/datasources/json_storage.dart`
- Move `data/datasources/remote/firebase_sync_datasource.dart` to `features/library/data/datasources/firebase_sync_datasource.dart`
- Move `data/models/audiobook_model.dart` to `features/library/data/models/audiobook_model.dart`
- Move `data/models/audiobook_model.g.dart` to `features/library/data/models/audiobook_model.g.dart`
- Move `data/repositories/audiobook_repository_impl.dart` to `features/library/data/repositories/audiobook_repository_impl.dart`
- Move `data/repositories/library_repository_impl.dart` to `features/library/data/repositories/library_repository_impl.dart`

#### Presentation Layer
- Move `presentation/screens/library_screen.dart` to `features/library/presentation/views/library_screen.dart`
- Move `presentation/screens/audiobook_detail_screen.dart` to `features/library/presentation/views/audiobook_detail_screen.dart`
- Move `presentation/widgets/audiobook_card.dart` to `features/library/presentation/widgets/audiobook_card.dart`
- Move `presentation/widgets/chapter_list.dart` to `features/library/presentation/widgets/chapter_list.dart`
- Move `presentation/widgets/error_dialog.dart` to `features/library/presentation/widgets/error_dialog.dart`

### Playback Feature

#### Domain Layer
- Move `domain/entities/playback_session.dart` to `features/playback/domain/entities/playback_session.dart`
- Move `domain/repositories/playback_repository.dart` to `features/playback/domain/repositories/playback_repository.dart`
- Move `domain/usecases/get_playback_state_usecase.dart` to `features/playback/domain/usecases/get_playback_state_usecase.dart`

#### Data Layer
- Move `data/models/playback_session_model.dart` to `features/playback/data/models/playback_session_model.dart`
- Move `data/models/playback_session_model.g.dart` to `features/playback/data/models/playback_session_model.g.dart`
- Move `data/repositories/playback_repository_impl.dart` to `features/playback/data/repositories/playback_repository_impl.dart`

#### Presentation Layer
- Move `presentation/providers/playback_provider.dart` to `features/playback/presentation/state/playback_provider.dart`
- Move `presentation/screens/playback_screen.dart` to `features/playback/presentation/views/playback_screen.dart`
- Move `presentation/widgets/playback_controls.dart` to `features/playback/presentation/widgets/playback_controls.dart`
- Move `presentation/widgets/progress_bar.dart` to `features/playback/presentation/widgets/progress_bar.dart`

### Directory Selection Feature

#### Presentation Layer
- Move `presentation/screens/directory_selection_screen.dart` to `features/directory_selection/presentation/views/directory_selection_screen.dart`

### Settings Feature

#### Presentation Layer
- Move `presentation/screens/settings_screen.dart` to `features/settings/presentation/views/settings_screen.dart`

### Splash Feature

#### Presentation Layer
- Move `presentation/screens/splash_screen.dart` to `features/splash/presentation/views/splash_screen.dart`

## Shared/Common Files (Not Migrated to Features)

The following files are considered shared across features and should remain in their current locations or be moved to a `core` or `shared` directory if needed:

- `data/datasources/local/error_handler.dart`
- `data/datasources/local/isar_schema.dart`
- `data/datasources/local/isar_schema.g.dart`
- `data/datasources/local_datasource.dart`
- `data/datasources/remote_datasource.dart`
- `presentation/navigation/app_router.dart`
- `presentation/providers/ui_state_provider.dart`
- `presentation/theme/app_theme.dart`
- `presentation/theme/material_3_theme.dart`
- `presentation/i18n/` (localization files)

## Post-Migration Tasks

1. Update all import statements in moved files to reflect new paths
2. Update any references to moved classes/repositories in remaining files
3. Ensure Isar schema generation still works after moves
4. Test all features to verify functionality
5. Remove empty directories from `domain/`, `data/`, and `presentation/` after migration
6. Update any documentation or configuration files that reference the old paths

## Notes

- Some files in `features/` directories already exist and contain code; these should be reviewed to avoid conflicts during migration
- Generated files (`.g.dart`) should be regenerated after migration
- If a target file already exists in the features directory, merge content or resolve conflicts as appropriate
- The `app/` and `core/` directories are not part of this migration as they appear to be application-level concerns