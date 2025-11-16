<!-- 
SYNC IMPACT REPORT
Version change: N/A -> 1.0.0
Modified principles: N/A (new constitution)
Added sections: All principles from user input
Removed sections: N/A
Templates requiring updates: ⚠ pending - .specify/templates/plan-template.md, .specify/templates/spec-template.md, .specify/templates/tasks-template.md, .qwen/commands/*.toml
Follow-up TODOs: None
-->

# Flutter Audiobooks Constitution

## Core Principles

### Code Quality Principles
**Single Source of Truth for Logic**: Core playback, library management, settings, and sync logic must live in shared Dart modules, not inside platform-specific code. Platform channels (Android, Linux, web) should be thin adapters around the core domain logic.

**Layered Architecture**: Suggested layers:
- domain/ – pure Dart: entities, use-cases, repositories (abstract).
- data/ – concrete implementations: storage, APIs, file IO.
- presentation/ – Flutter widgets, state management, navigation.
- platform/ – platform integrations (notifications, background playback, file pickers).

No cross-layer "shortcuts": UI → Data directly is not allowed; always go through domain.

**State Management**: Use a single, explicit state management solution across the app (e.g. Riverpod, Bloc, or Provider). State must be:
- Serializable where possible (for debugging and persistence).
- Immutable by default (copyWith-style updates).

### Coding Style & Linting
**Formatter**: All code must pass dart format. No manual bikeshedding on style.

**Linting**: Use a strict lint ruleset (e.g. very_good_analysis or custom). CI must fail if flutter analyze or dart analyze fails.

**Naming & Structure**: Classes, widgets, and files must express their intent: NowPlayingScreen, LibraryRepository, AudioPositionService, etc. Avoid "god" classes with too many responsibilities.

### Code Review Expectations
Every PR should:
- Have a clear description of the change and the user impact.
- Include tests for non-trivial logic (domain and data layer).
- Not exceed a "mental load threshold":
  - Large refactors should be broken into multiple PRs:
  - e.g. "Introduce new abstraction" ➜ "Migrate feature A" ➜ "Migrate feature B".

Reviewers should:
- Check for readability & maintainability, not just "does it work".
- Ask: "Would I understand and safely modify this in 6 months?"

### Testing Standards
**Types of Tests**:
- **Unit Tests**: Target domain logic, playback state transitions, chapter logic, progress tracking.
  - Examples: Given a track length of 1 hour, and current position 10 min, "skip 30 seconds" results in 10:30. Bookmark creation and deletion works as expected.
- **Widget Tests**: Target individual UI components and simple screens.
  - Examples: "Play/Pause" button toggles icons and triggers callbacks. Chapter list renders correct number of items given mock data.
- **Integration / End-to-End Tests**: Target flows across multiple layers (e.g. load library → select book → start playback → seek → resume app).
  - For web: ensure playback UI behaves in browsers and basic navigation works.

**Coverage & Enforcement**: 
- Minimum coverage: Start with a realistic baseline (e.g. 40–50%), then raise over time.
- Critical logic (playback, progress, library management) should approach 80%+ coverage.

**CI Requirements**: Docker-based CI pipeline must run flutter test (or dart test for pure Dart) and flutter analyze. A PR should not merge if tests fail or coverage drops below the configured threshold for core modules.

**Test Data & Repeatability**: Use fixtures for sample audiobook metadata, mock file paths, various playback states (paused, playing, seeking). Tests must be deterministic: avoid real network or file system access in unit tests, use in-memory or mock implementations.

### User Experience (UX) Consistency
**Cross-Platform Design Rules**: Use a consistent design system for Android, Linux, and Web with same color palette, typography, spacing, and component usage. Platform-specific variations allowed only where it improves familiarity (e.g. different default scroll behaviors or context menus). Responsive layout must adapt to small screens (phones), medium screens (tablets / small desktop windows), large screens (desktop) with layout breakpoints and behavior defined centrally (e.g. layout_config.dart).

**Audio UX Principles**: Playback Controls must be:
- Always discoverable (clear play/pause control).
- Large enough for thumb operation on mobile.
- With consistent semantics (Tap ▶️: play or resume from last position, Tap ⏸: pause without resetting position).

**Progress & Chapters**: Show current time / total duration and chapter name or index when applicable. Seeking: Provide fixed skip intervals (e.g. +/- 10s, 30s). Ensure drag on the progress bar is smooth and predictable. Error States: Clear messages for missing files, unsupported codec/format, permission issues (file access, storage). No raw stack traces in UI.

**Accessibility & Internationalization**: UI must support scalable text (respect system font size), use sufficient color contrast for text and controls, provide labels for screen readers on buttons and key elements. Strings: Centralized in a localization system (e.g. intl / Flutter localization). No hard-coded user-facing strings in business logic.

## Performance Requirements

### Startup & Responsiveness
**Cold Start**: Time from app launch to showing the library or last-played screen should be minimized:
- Target: < 2 seconds on a mid-range Android device.

Use lazy-loading for thumbnails and detailed metadata (only when viewing details).

**Main Thread**: No heavy work on the UI thread:
- Large file IO operations must be offloaded to isolate(s) or async APIs.
- Metadata indexing or library scanning should show progress and not freeze UI.

### Memory & Storage
**Memory**: Avoid holding large decoded audio buffers in memory. Keep only the current / nearby segment in memory when needed.

**Caching**: Cache thumbnails and parsed metadata. Provide a way to clear caches from settings.

**Storage Requirements**: Support external storage (SD cards) where possible on Linux/Android. Prevent unnecessary duplication of audio files: By default, read from user-specified locations, not copy unless explicitly configured.

### Battery & CPU Usage
**Background Playback**: Background playback must use efficient APIs and avoid unnecessary polling. No tight loops or frequent timers for UI updates: Use streams or periodic updates at reasonable intervals (e.g. 4–10 times per second max for progress).

**Idle Behavior**: When playback is paused: Release player resources when possible, stop unnecessary updates and timers.

## Docker-Based Development & Build Principles

### Development Environment
No Host Flutter/Dart Dependency - all Flutter/Dart tooling runs inside containers: docker run -v $PWD:/app ... flutter build ... Dev containers / VS Code devcontainers for interactive development.

Single Source of Truth for Toolchain: Define versions for Flutter SDK, Dart SDK, Android SDK / NDK (as needed) with version pinning done in Dockerfile (or docker-compose.yml).

### Devcontainer Setup (High-Level Principle)
Devcontainer should:
- Mount the project directory as a volume (/workspace / /app).
- Include Flutter SDK, Dart SDK, Required OS dependencies for Android, Linux, and Web builds.
- Run flutter pub get automatically on first attach (or via a task).

All common commands like flutter run, flutter build apk, flutter test must be runnable inside the devcontainer without host setup.

### Artifact Builds
CI builds use the same Docker image as local devcontainer. Generated artifacts (APKs, Linux bundles, and web builds) are created under build/ and exported via mounted volumes. No "it works on my machine": If it doesn't build in Docker, it's considered broken.

## Governance
Constitution supersedes all other practices. Amendments require documentation, approval, migration plan. All PRs/reviews must verify compliance. Complexity must be justified.

**Version**: 1.0.0 | **Ratified**: 2025-11-15 | **Last Amended**: 2025-11-15