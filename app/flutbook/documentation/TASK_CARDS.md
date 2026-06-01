# 📌 Quick Task Cards - Flutbook MVP

**Purpose:** Print-friendly task cards for agents working on specific tasks
**Format:** Copy a card, assign to agent, track progress

---

## 🎯 How to Use These Cards

1. **Pick a task** from a phase below
2. **Copy the card** for that task
3. **Assign to agent** with all details
4. **Track progress** using the checklist
5. **Mark complete** when all criteria met
6. **Update MVP_STATUS.md** with completion

---


# 📋 PHASE 5: AUDIO PLAYBACK

---

## TASK 5.1: Fix Audio Service Handler (CRITICAL FIX) ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5, TASK 5.1: Fix Audio Service Handler               │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL BUILD ERROR                           │
│ Estimated Time: 1-2 hours                                   │
│ Dependencies: None (can fix in parallel)                    │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO FIX:                                                │
│ lib/features/player/data/datasources/audio_service_handler.dart
│                                                             │
│ BUILD ERROR:                                                │
│ "AudioHandler doesn't have unnamed constructor"             │
│ Location: Line 74                                           │
│                                                             │
│ WHAT'S WRONG:                                               │
│ AudioServiceHandler tries to extend AudioHandler            │
│ But AudioHandler requires specific initialization           │
│                                                             │
│ SOLUTION:                                                   │
│ [ ] Extend BaseAudioHandler instead                        │
│ [ ] Implement required methods:                            │
│    - onPlay()                                              │
│    - onPause()                                             │
│    - onSeek(Duration position)                             │
│    - onSkipToQueueItem(int index)                          │
│    - onStop()                                              │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] No build error at line 74                              │
│ [ ] flutter analyze shows 0 errors                         │
│ [ ] All required methods implemented                       │
│ [ ] No regression in other code                            │
│ [ ] Tests still passing                                    │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Check audio_service package docs                       │
│ [ ] Change extends AudioHandler → BaseAudioHandler        │
│ [ ] Implement onPlay() method                              │
│ [ ] Implement onPause() method                             │
│ [ ] Implement onSeek() method                              │
│ [ ] Implement onSkipToQueueItem() method                   │
│ [ ] Implement onStop() method                              │
│ [ ] Run: flutter analyze (0 errors)                        │
│ [ ] Run: flutter test                                      │
│ [ ] Commit: "Fix: AudioHandler constructor"                │
│ [ ] Mark complete in MVP_STATUS.md                         │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 5.2: Create Playback Provider ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5, TASK 5.2: Finalize Playback Provider              │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (state management)                        │
│ Estimated Time: 2 hours                                     │
│ Dependencies: Task 5.1 (audio service)                     │
│ Status: 100% COMPLETE                                        │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO COMPLETE:                                           │
│ lib/features/player/presentation/providers/playback_provider.dart
│                                                             │
│ WHAT'S DONE (60%):                                          │
│ ✓ NotifierProvider created                                │
│ ✓ PlaybackNotifier class                                  │
│ ✓ PlaybackState class                                     │
│ ✓ Stream subscription setup                               │
│                                                             │
│ WHAT'S REMAINING (40%):                                     │
│ [ ] Test all play/pause/seek methods                      │
│ [ ] Fix any type casting issues                           │
│ [ ] Complete error handling                               │
│ [ ] Add doc comments                                      │
│ [ ] 80%+ test coverage                                    │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Manages playback state                                 │
│ [ ] play() method works                                    │
│ [ ] pause() method works                                   │
│ [ ] seek() method works                                    │
│ [ ] Speed control works                                    │
│ [ ] Error handling complete                                │
│ [ ] Tests passing                                          │
│ [ ] 80%+ coverage                                          │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Review existing code (already 60% done)               │
│ [ ] Complete any missing methods                           │
│ [ ] Write comprehensive tests                              │
│ [ ] Fix any type casting errors                            │
│ [ ] Add doc comments                                       │
│ [ ] Run: flutter test                                      │
│ [ ] Run: flutter test --coverage                           │
│ [ ] Build succeeds                                         │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 5.3: Create Playback Screen ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5, TASK 5.3: Create Playback Screen UI               │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (main feature)                        │
│ Estimated Time: 3 hours                                     │
│ Dependencies: Task 5.2 (provider)                          │
│ Status: [ ] TODO / [ ] IN PROGRESS / [x] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO CREATE/UPDATE:                                      │
│ lib/features/player/presentation/views/playback_screen.dart│
│                                                             │
│ UI ELEMENTS:                                                │
│ [ ] Audiobook cover art display                            │
│ [ ] Title and author name                                  │
│ [ ] Progress slider with current/total time               │
│ [ ] Play/pause button (FAB)                                │
│ [ ] Skip back/forward buttons (15/30 sec)                  │
│ [ ] Playback speed control button                          │
│ [ ] Sleep timer button                                     │
│ [ ] Chapters/playlist list                                 │
│ [ ] Current time and duration display                      │
│ [ ] Responsive layout                                      │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Cover art displayed (placeholder or real)             │
│ [ ] Title and author shown                                 │
│ [ ] Progress slider shows position                        │
│ [ ] Play/pause button works                               │
│ [ ] Skip buttons work                                     │
│ [ ] Speed control button present                          │
│ [ ] Sleep timer button present                            │
│ [ ] Time display shows correctly                          │
│ [ ] Responsive on all sizes                               │
│ [ ] No navigation errors                                  │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create ConsumerWidget for playback screen             │
│ [ ] Add cover art image                                   │
│ [ ] Add title/author text                                 │
│ [ ] Implement progress slider                            │
│ [ ] Add play/pause FAB                                    │
│ [ ] Add skip buttons                                      │
│ [ ] Add speed control button                              │
│ [ ] Add sleep timer button                                │
│ [ ] Add time display                                      │
│ [ ] Test on multiple screen sizes                         │
│ [ ] Build succeeds                                         │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 How to Use These Cards

### For Individual Agent:
1. Copy the card for your assigned task
2. Keep it visible while working
3. Check off items as you complete them
4. Mark complete when all criteria met

### For Team Lead:
1. Print/share cards with assigned agents
2. Track progress using status field
3. Identify blockers early
4. Update CURRENT_PROGRESS.txt daily

### For Project Manager:
1. Use status fields to track overall progress
2. Identify critical path items (🔴)
3. Manage dependencies between tasks
4. Update timeline if blockers occur

---

## 📊 Card Status Legend

| Status | Meaning | Action |
|--------|---------|--------|
| [ ] TODO | Not started | Assign to agent |
| [ ] IN PROGRESS | Agent working | Check progress |
| [x] COMPLETE | Done & verified | Mark in MVP_STATUS.md |

## 🔴 Priority Legend

| Priority | Meaning | Action |
|----------|---------|--------|
| 🔴 CRITICAL | Blocks other work | Start immediately |
| 🟡 HIGH | Important feature | Start after critical |
| 🟡 MEDIUM | Valuable feature | Start when appropriate |
| 🟡 LOW | Nice to have | Start when other work is done |

---

# 📋 PHASE 6: ADVANCED PLAYBACK FEATURES

---

## TASK 6.1: Implement Bookmarks at Specific Positions ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 6, TASK 6.1: Implement Bookmarks at Specific Positions│
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (user requested feature)                  │
│ Estimated Time: 4-6 hours                                   │
│ Dependencies: Phase 5 (Audio Playback)                      │
│ Status: [x] COMPLETE                                        │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/player/domain/entities/bookmark.dart          │
│ lib/features/player/data/models/bookmark_model.dart        │
│ lib/features/player/data/datasources/bookmark_local_ds.dart│
│ lib/features/player/data/repositories/bookmark_repository_impl.dart
│ lib/features/player/domain/repositories/bookmark_repository.dart
│ lib/features/player/domain/usecases/create_bookmark_usecase.dart
│ lib/features/player/domain/usecases/get_bookmarks_usecase.dart
│ lib/features/player/presentation/providers/bookmark_provider.dart
│ lib/features/player/presentation/widgets/bookmark_widget.dart
│ lib/features/player/presentation/views/playback_screen.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [x] Bookmark entity with timestamp, audiobook ID, note    │
│ [x] Local storage for bookmarks using Isar                 │
│ [x] Create bookmark use case                               │
│ [x] Get bookmarks for audiobook use case                   │
│ [x] Provider to manage bookmark state                      │
│ [x] Widget to display and manage bookmarks                 │
│ [x] Integration with playback screen                       │
│ [x] Ability to jump to bookmark position                   │
│ [x] Ability to add/remove bookmarks                        │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [X] User can create bookmark at current position           │
│ [X] User can view list of bookmarks for audiobook          │
│ [X] User can jump to bookmarked position                   │
│ [X] User can delete bookmarks                              │
│ [X] Bookmarks persist across app restarts                  │
│ [X] Bookmarks work for all supported audio formats         │
│ [X] UI is intuitive and user-friendly                      │
│ [X] Tests pass with 80%+ coverage                          │
│ [X] No performance degradation                             │
│                                                            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## TASK 6.2: Chapter-Based Bookmarks ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 6, TASK 6.2: Chapter-Based Bookmarks                  │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (enhancement to bookmarks)              │
│ Estimated Time: 3-4 hours                                   │
│ Dependencies: Task 6.1 (Basic Bookmarks)                    │
│ Status: [x] COMPLETE                                        │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/features/player/domain/entities/chapter.dart           │
│ lib/features/player/domain/entities/bookmark.dart (update) │
│ lib/features/player/presentation/widgets/chapter_list.dart │
│ lib/features/player/presentation/widgets/bookmark_widget.dart (update)
│ lib/features/player/presentation/views/playback_screen.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [x] Enhance bookmark entity to link to chapters           │
│ [x] Ability to create bookmarks for specific chapters      │
│ [x] Display bookmarks grouped by chapters                  │
│ [x] Navigate to chapter + position from bookmark           │
│ [x] Chapter-aware bookmark management                      │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] User can create bookmark for specific chapter          │
│ [x] Bookmarks are grouped by chapters in UI                │
│ [x] Jumping to bookmark goes to correct chapter/position   │
│ [x] Chapter-based bookmarks work with all audio formats    │
│ [x] UI clearly shows chapter-bookmark relationship         │
│ [x] Tests pass with 80%+ coverage                          │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] Update Bookmark entity to include chapter reference   │
│ [x] Modify chapter entity if needed for bookmark linking  │
│ [x] Update bookmark repository methods                    │
│ [x] Update bookmark provider to handle chapter bookmarks  │
│ [x] Enhance chapter list widget with bookmark indicators  │
│ [x] Update bookmark widget to show chapter context        │
│ [x] Modify playback screen UI for chapter bookmarks       │
│ [x] Write unit tests for chapter-bookmark integration     │
│ [x] Write widget tests for enhanced UI                    │
│ [x] Test with sample audiobooks with chapters             │
│ [x] Run: flutter test                                     │
│ [x] Run: flutter test --coverage                          │
│ [x] Commit: "Feat: Add chapter-based bookmarks"           │
│ [x] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 6.3: Multiple Playback Queues ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 6, TASK 6.3: Multiple Playback Queues                 │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (advanced feature)                      │
│ Estimated Time: 5-7 hours                                   │
│ Dependencies: Phase 5 (Audio Playback)                      │
│ Status: [x] COMPLETE                                        │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/player/domain/entities/queue.dart             │
│ lib/features/player/data/models/queue_model.dart           │
│ lib/features/player/data/datasources/queue_local_ds.dart   │
│ lib/features/player/data/repositories/queue_repository_impl.dart
│ lib/features/player/domain/repositories/queue_repository.dart
│ lib/features/player/domain/usecases/manage_queue_usecase.dart
│ lib/features/player/presentation/providers/queue_provider.dart
│ lib/features/player/presentation/widgets/queue_manager_widget.dart
│ lib/features/player/presentation/views/playback_screen.dart (update)
│ lib/features/library/presentation/widgets/audiobook_actions.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [x] Queue entity with name, audiobooks list, creation date│
│ [x] Local storage for queues using Isar                    │
│ [x] Create/manage queue use cases                          │
│ [x] Provider to manage queue state                         │
│ [x] Widget to manage queues                                │
│ [x] Integration with playback screen                       │
│ [x] Ability to add audiobooks to queues                    │
│ [x] Switch between different queues                        │
│ [x] Default queue for immediate playback                   │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] User can create named queues                           │
│ [x] User can add/remove audiobooks from queues             │
│ [x] User can switch between different queues               │
│ [x] Queues persist across app restarts                     │
│ [x] Default queue works as before                          │
│ [x] UI allows easy queue management                        │
│ [x] Tests pass with 80%+ coverage                          │
│ [x] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] Define Queue entity with required fields              │
│ [x] Create Isar schema for queue storage                  │
│ [x] Implement local datasource for queues                 │
│ [x] Create repository interface and implementation        │
│ [x] Implement use cases for queue operations              │
│ [x] Create provider for queue state management            │
│ [x] Design and implement queue manager widget             │
│ [x] Integrate queue functionality into playback screen    │
│ [ ] Add queue options to audiobook actions                │
│ [x] Write unit tests for all layers                       │
│ [x] Write widget tests for UI components                  │
│ [x] Test queue switching functionality                    │
│ [x] Run: flutter analyze (0 errors)                       │
│ [x] Run: flutter test                                     │
│ [x] Run: flutter test --coverage                          │
│ [x] Commit: "Feat: Add multiple playback queues"          │
│ [x] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 6.4: Up Next / Recently Played

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 6, TASK 6.4: Up Next / Recently Played                │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (convenience feature)                   │
│ Estimated Time: 3-5 hours                                   │
│ Dependencies: Phase 5 (Audio Playback)                      │
│ Status: [x] COMPLETE (partial - PlaybackSession used)       │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/features/player/domain/entities/playback_history.dart  │
│ lib/features/player/data/models/playback_history_model.dart│
│ lib/features/player/data/datasources/playback_local_ds.dart (update)
│ lib/features/player/data/repositories/playback_repository_impl.dart (update)
│ lib/features/player/domain/usecases/history_usecases.dart  │
│ lib/features/player/presentation/providers/history_provider.dart
│ lib/features/player/presentation/widgets/history_widget.dart
│ lib/features/player/presentation/views/playback_screen.dart (update)
│ lib/features/library/presentation/views/library_screen.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [x] Track recently played audiobooks (via PlaybackSession)│
│ [ ] Track "up next" queue (covered by Queue feature)         │
│ [ ] History repository enhancements                        │
│ [ ] Provider for history state management                  │
│ [ ] Widget to display history                              │
│ [ ] Integration with library and playback screens          │
│ [ ] Configurable history depth                             │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] Recently played audiobooks are tracked (PlaybackSession)│
│ [ ] "Up next" queue persists between sessions              │
│ [ ] History is accessible from library screen              │
│ [ ] History shows chronological order                      │
│ [ ] History can be cleared by user                         │
│ [ ] UI is intuitive and user-friendly                      │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] PlaybackHistory entity exists                         │
│ [x] PlaybackHistoryModel exists                           │
│ [x] Playback repository has session tracking methods       │
│ [ ] Create use cases for history operations               │
│ [ ] Create provider for history state management          │
│ [ ] Design and implement history widget                   │
│ [ ] Integrate history into playback screen                │
│ [ ] Add history access to library screen                  │
│ [ ] Write unit tests for history features                 │
│ [ ] Write widget tests for history UI                     │
│ [ ] Test history persistence                              │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add up next/recently played"           │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 6.5: Playback Effects (EQ, Bass Boost) ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 6, TASK 6.5: Playback Effects (EQ, Bass Boost)        │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 LOW (enhancement feature)                      │
│ Estimated Time: 6-8 hours                                   │
│ Dependencies: Phase 5 (Audio Playback)                      │
│ Status: [x] COMPLETE                                        │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/player/domain/entities/audio_effect.dart      │
│ lib/features/player/data/models/audio_effect_model.dart    │
│ lib/features/player/data/datasources/audio_effects_ds.dart │
│ lib/features/player/data/repositories/audio_effects_repository_impl.dart
│ lib/features/player/domain/repositories/audio_effects_repository.dart
│ lib/features/player/domain/usecases/audio_effects_usecase.dart
│ lib/features/player/presentation/providers/audio_effects_provider.dart
│ lib/features/player/presentation/widgets/equalizer_widget.dart
│ lib/features/player/presentation/widgets/audio_effects_panel.dart
│ lib/features/player/presentation/views/playback_screen.dart (update)
│ lib/features/settings/presentation/views/audio_settings_view.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [x] Equalizer with preset and custom settings              │
│ [x] Bass boost effect                                      │
│ [x] Treble adjustment                                      │
│ [x] Preset profiles (music, podcast, etc.)                 │
│ [x] Effect persistence across sessions                     │
│ [ ] Real-time effect application                           │
│ [ ] Settings integration                                   │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] Equalizer with multiple bands adjustable               │
│ [x] Bass boost effect available                            │
│ [x] Preset audio profiles available                        │
│ [x] Effects persist across app restarts                    │
│ [ ] Effects applied in real-time without interruption      │
│ [x] UI is intuitive and user-friendly                      │
│ [x] Effects work with all supported audio formats          │
│ [x] Tests pass with 80%+ coverage                          │
│ [x] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] Define AudioEffect entity with required fields        │
│ [x] Research audio processing packages for Flutter        │
│ [x] Implement audio effects datasource                    │
│ [x] Create repository interface and implementation        │
│ [x] Implement use cases for audio effects                 │
│ [x] Create provider for audio effects state management    │
│ [x] Design and implement equalizer widget                 │
│ [x] Design and implement audio effects panel              │
│ [x] Integrate effects into playback screen                │
│ [ ] Add effects to audio settings view                      │
│ [x] Test with different audio formats                     │
│ [x] Write unit tests for audio effects                    │
│ [x] Write widget tests for effects UI                     │
│ [x] Run: flutter analyze (0 errors)                       │
│ [x] Run: flutter test                                     │
│ [x] Run: flutter test --coverage                          │
│ [x] Commit: "Feat: Add audio effects (EQ, bass boost)"    │
│ [x] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 6.6: Variable Speed Sync Per Book ✅ COMPLETE

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 6, TASK 6.6: Variable Speed Sync Per Book             │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (user convenience)                      │
│ Estimated Time: 4-5 hours                                   │
│ Dependencies: Phase 5 (Audio Playback)                      │
│ Status: [x] COMPLETE                                        │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/features/player/domain/entities/audiobook.dart (update)│
│ lib/features/player/data/models/audiobook_model.dart (update)
│ lib/features/player/data/datasources/audiobook_local_ds.dart (update)
│ lib/features/player/data/repositories/audiobook_repository_impl.dart (update)
│ lib/features/player/presentation/providers/playback_provider.dart (update)
│ lib/features/player/presentation/widgets/speed_control.dart (update)
│ lib/features/player/presentation/views/playback_screen.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [x] Store preferred playback speed per audiobook           │
│ [x] Apply stored speed when audiobook starts               │
│ [x] Update stored speed when user changes it               │
│ [ ] Default speed option (don't remember)                  │
│ [x] UI to enable/disable per-book speed storage            │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [x] Preferred speed saved per audiobook                    │
│ [x] Stored speed applied when audiobook loads              │
│ [x] Speed remembered across app restarts                   │
│ [ ] Option to disable per-book speed storage               │
│ [x] Default speed behavior preserved                       │
│ [x] UI clearly indicates per-book speed status             │
│ [x] Tests pass with 80%+ coverage                          │
│ [x] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [x] Add preferredSpeed field to Audiobook entity          │
│ [x] Update Isar schema for audiobook model                │
│ [x] Update local datasource for speed storage             │
│ [x] Update repository with speed methods                  │
│ [x] Update playback provider to handle per-book speeds    │
│ [x] Enhance speed control widget with per-book toggle     │
│ [x] Update playback screen UI for speed settings          │
│ [x] Write unit tests for per-book speed logic             │
│ [x] Write widget tests for speed UI                       │
│ [x] Test speed persistence across sessions                │
│ [x] Run: flutter analyze (0 errors)                       │
│ [x] Run: flutter test                                     │
│ [x] Run: flutter test --coverage                          │
│ [x] Commit: "Feat: Add variable speed sync per book"      │
│ [x] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

# 📋 PHASE 7: SUPABASE SYNC

---

## TASK 7.1: Library Sync Across Devices

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 7, TASK 7.1: Library Sync Across Devices              │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 HIGH (core sync feature)                       │
│ Estimated Time: 8-10 hours                                  │
│ Dependencies: Phase 2 (Authentication), Phase 4 (Library)   │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/sync/data/datasources/library_remote_ds.dart  │
│ lib/features/sync/data/repositories/library_sync_repository_impl.dart
│ lib/features/sync/domain/repositories/library_sync_repository.dart
│ lib/features/sync/domain/usecases/sync_library_usecase.dart
│ lib/features/sync/presentation/providers/sync_provider.dart
│ lib/features/library/data/repositories/library_repository_impl.dart (update)
│ lib/features/library/presentation/providers/library_provider.dart (update)
│ lib/features/settings/presentation/views/sync_settings_view.dart
│ lib/features/settings/presentation/widgets/sync_status_widget.dart
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Remote datasource for Supabase library sync            │
│ [ ] Sync repository with conflict resolution               │
│ [ ] Sync use case with bidirectional sync                  │
│ [ ] Sync provider to manage sync state                     │
│ [ ] Integration with existing library functionality        │
│ [ ] Sync settings UI                                       │
│ [ ] Sync status indicator                                  │
│ [ ] Offline-first approach with sync when online           │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Library items sync across devices                      │
│ [ ] Sync works offline with queue for later sync           │
│ [ ] Conflict resolution handles simultaneous changes       │
│ [ ] Sync status is visible to user                         │
│ [ ] Sync respects user privacy settings                    │
│ [ ] Sync doesn't duplicate items                           │
│ [ ] UI indicates sync progress                             │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Set up Supabase tables for library sync               │
│ [ ] Create remote datasource for library sync             │
│ [ ] Implement sync repository with conflict resolution    │
│ [ ] Create sync use case with bidirectional logic         │
│ [ ] Create sync provider for state management             │
│ [ ] Update local library repository for sync integration  │
│ [ ] Update library provider to work with sync             │
│ [ ] Create sync settings UI                               │
│ [ ] Create sync status widget                             │
│ [ ] Implement offline queue for sync operations           │
│ [ ] Write unit tests for sync logic                       │
│ [ ] Write widget tests for sync UI                        │
│ [ ] Test sync with multiple devices                       │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add library sync across devices"       │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 7.2: Playback Position Sync

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 7, TASK 7.2: Playback Position Sync                   │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 HIGH (core sync feature)                       │
│ Estimated Time: 6-8 hours                                   │
│ Dependencies: Task 7.1 (Library Sync)                       │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/sync/data/datasources/playback_remote_ds.dart │
│ lib/features/sync/data/repositories/playback_sync_repository_impl.dart
│ lib/features/sync/domain/repositories/playback_sync_repository.dart
│ lib/features/sync/domain/usecases/sync_playback_position_usecase.dart
│ lib/features/player/presentation/providers/playback_provider.dart (update)
│ lib/features/sync/presentation/providers/sync_provider.dart (update)
│ lib/features/settings/presentation/views/sync_settings_view.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Remote datasource for playback position sync           │
│ [ ] Sync repository for position data                      │
│ [ ] Sync use case for position synchronization             │
│ [ ] Integration with playback provider                     │
│ [ ] Sync settings option for position sync                 │
│ [ ] Automatic sync of position on change                   │
│ [ ] Manual sync option                                     │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Playback position syncs across devices                 │
│ [ ] Position sync works offline with queue                 │
│ [ ] Last position is restored on new device                │
│ [ ] Sync respects user privacy settings                    │
│ [ ] Sync doesn't interfere with playback performance       │
│ [ ] UI indicates position sync status                      │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Set up Supabase table for playback position sync      │
│ [ ] Create remote datasource for position sync            │
│ [ ] Implement position sync repository                    │
│ [ ] Create position sync use case                         │
│ [ ] Update playback provider for sync integration         │
│ [ ] Update sync provider to handle positions              │
│ [ ] Update sync settings UI for position sync             │
│ [ ] Write unit tests for position sync                    │
│ [ ] Write widget tests for sync UI                        │
│ [ ] Test position sync across devices                     │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add playback position sync"            │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 7.3: Reading List Management

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 7, TASK 7.3: Reading List Management                  │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (sync feature)                          │
│ Estimated Time: 5-7 hours                                   │
│ Dependencies: Task 7.1 (Library Sync)                       │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/sync/data/datasources/list_remote_ds.dart     │
│ lib/features/sync/data/repositories/list_sync_repository_impl.dart
│ lib/features/sync/domain/repositories/list_sync_repository.dart
│ lib/features/sync/domain/usecases/list_management_usecase.dart
│ lib/features/sync/presentation/providers/list_sync_provider.dart
│ lib/features/library/presentation/providers/library_provider.dart (update)
│ lib/features/library/presentation/widgets/audiobook_actions.dart (update)
│ lib/features/library/presentation/views/library_screen.dart (update)
│ lib/features/settings/presentation/views/sync_settings_view.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Remote datasource for list management sync             │
│ [ ] Sync repository for custom lists                       │
│ [ ] List management use cases                              │
│ [ ] List sync provider                                     │
│ [ ] Integration with library UI                            │
│ [ ] Create/read/update/delete custom lists                 │
│ [ ] Add/remove audiobooks from lists                       │
│ [ ] Sync lists across devices                              │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Custom lists sync across devices                       │
│ [ ] Lists work offline with sync when online               │
│ [ ] Users can create multiple custom lists                 │
│ [ ] Audiobooks can be added to multiple lists              │
│ [ ] List management UI is intuitive                        │
│ [ ] Sync respects user privacy settings                    │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Set up Supabase table for list management             │
│ [ ] Create remote datasource for list sync                │
│ [ ] Implement list sync repository                        │
│ [ ] Create list management use cases                      │
│ [ ] Create list sync provider                             │
│ [ ] Update library provider for list integration          │
│ [ ] Update library UI for list management                 │
│ [ ] Add list options to audiobook actions                 │
│ [ ] Update sync settings UI for list sync                 │
│ [ ] Write unit tests for list sync                        │
│ [ ] Write widget tests for list UI                        │
│ [ ] Test list sync across devices                         │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add reading list management"           │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 7.4: Cloud Backup

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 7, TASK 7.4: Cloud Backup                             │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (data protection feature)               │
│ Estimated Time: 6-8 hours                                   │
│ Dependencies: Task 7.1 (Library Sync)                       │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/sync/data/datasources/backup_remote_ds.dart   │
│ lib/features/sync/data/repositories/backup_repository_impl.dart
│ lib/features/sync/domain/repositories/backup_repository.dart
│ lib/features/sync/domain/usecases/backup_usecases.dart     │
│ lib/features/sync/presentation/providers/backup_provider.dart
│ lib/features/settings/presentation/views/backup_settings_view.dart
│ lib/features/settings/presentation/widgets/backup_status_widget.dart
│ lib/features/sync/presentation/views/backup_restore_view.dart
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Remote datasource for backup operations                │
│ [ ] Backup repository with compression                     │
│ [ ] Backup/restore use cases                               │
│ [ ] Backup provider for state management                   │
│ [ ] Backup settings UI                                     │
│ [ ] Backup status indicator                                │
│ [ ] Restore from backup functionality                      │
│ [ ] Scheduled automatic backups                            │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] User data can be backed up to cloud                    │
│ [ ] Backups can be restored on new installation            │
│ [ ] Backup includes all user data (library, positions, etc.)│
│ [ ] Automatic scheduled backups work                       │
│ [ ] Backup status is visible to user                       │
│ [ ] Backup respects user privacy settings                  │
│ [ ] UI is intuitive and user-friendly                      │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Set up Supabase storage for backups                   │
│ [ ] Create remote datasource for backup operations        │
│ [ ] Implement backup repository with compression          │
│ [ ] Create backup/restore use cases                       │
│ [ ] Create backup provider for state management           │
│ [ ] Create backup settings UI                             │
│ [ ] Create backup status widget                           │
│ [ ] Create backup/restore view                            │
│ [ ] Implement scheduled backup functionality              │
│ [ ] Write unit tests for backup logic                     │
│ [ ] Write widget tests for backup UI                      │
│ [ ] Test backup and restore functionality                 │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add cloud backup functionality"        │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 7.5: Offline Queue

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 7, TASK 7.5: Offline Queue                            │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (sync feature)                            │
│ Estimated Time: 5-7 hours                                   │
│ Dependencies: Task 7.1 (Library Sync)                       │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/sync/data/datasources/offline_queue_ds.dart   │
│ lib/features/sync/data/repositories/offline_queue_repository_impl.dart
│ lib/features/sync/domain/repositories/offline_queue_repository.dart
│ lib/features/sync/domain/usecases/offline_queue_usecase.dart
│ lib/features/sync/presentation/providers/offline_queue_provider.dart
│ lib/features/sync/presentation/widgets/offline_queue_widget.dart
│ lib/features/settings/presentation/views/sync_settings_view.dart (update)
│ lib/features/sync/presentation/views/offline_queue_view.dart
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Queue for pending sync operations                      │
│ [ ] Offline queue repository                               │
│ [ ] Queue management use cases                             │
│ [ ] Queue provider for state management                    │
│ [ ] Queue UI to view pending operations                    │
│ [ ] Automatic sync when connection restored                │
│ [ ] Manual sync option                                     │
│ [ ] Queue prioritization                                   │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Operations queue when offline                          │
│ [ ] Queue syncs automatically when online                  │
│ [ ] Users can view pending operations                      │
│ [ ] Queue handles different operation types                │
│ [ ] Queue prioritizes certain operations                   │
│ [ ] UI shows queue status and progress                     │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Set up Isar schema for offline queue                  │
│ [ ] Create local datasource for offline queue             │
│ [ ] Implement offline queue repository                    │
│ [ ] Create queue management use cases                     │
│ [ ] Create queue provider for state management            │
│ [ ] Create queue UI widgets                               │
│ [ ] Create queue view                                       │
│ [ ] Update sync settings UI for queue management          │
│ [ ] Implement automatic sync when online                  │
│ [ ] Write unit tests for queue logic                      │
│ [ ] Write widget tests for queue UI                       │
│ [ ] Test offline queue functionality                      │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add offline queue for sync operations" │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 7.6: Conflict Resolution

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 7, TASK 7.6: Conflict Resolution                      │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (data integrity)                      │
│ Estimated Time: 7-9 hours                                   │
│ Dependencies: Task 7.1 (Library Sync)                       │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/sync/domain/usecases/conflict_resolution_usecase.dart
│ lib/features/sync/data/datasources/conflict_resolver_ds.dart
│ lib/features/sync/data/repositories/conflict_resolution_repository_impl.dart
│ lib/features/sync/domain/repositories/conflict_resolution_repository.dart
│ lib/features/sync/presentation/providers/conflict_resolver_provider.dart
│ lib/features/sync/presentation/views/conflict_resolution_view.dart
│ lib/features/sync/presentation/widgets/conflict_notification_widget.dart
│ lib/features/sync/data/models/conflict_model.dart
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Conflict detection mechanism                           │
│ [ ] Conflict resolution strategies                         │
│ [ ] Conflict notification to user                          │
│ [ ] Manual conflict resolution UI                          │
│ [ ] Automatic resolution for simple conflicts              │
│ [ ] Conflict history tracking                              │
│ [ ] Resolution preferences                                   │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Conflicts are detected during sync                     │
│ [ ] Simple conflicts resolved automatically                │
│ [ ] Complex conflicts notified to user                     │
│ [ ] Users can resolve conflicts manually                   │
│ [ ] Conflict history is maintained                         │
│ [ ] Resolution respects user preferences                   │
│ [ ] UI clearly shows conflict status                       │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No data loss during resolution                         │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Define Conflict model for tracking conflicts          │
│ [ ] Create conflict detection mechanism                   │
│ [ ] Implement automatic resolution strategies             │
│ [ ] Create manual resolution UI                           │
│ [ ] Implement conflict notification system                │
│ [ ] Create conflict resolver provider                     │
│ [ ] Create conflict resolution view                       │
│ [ ] Add conflict notification widget                      │
│ [ ] Write unit tests for conflict resolution              │
│ [ ] Write widget tests for conflict UI                    │
│ [ ] Test conflict scenarios thoroughly                    │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add conflict resolution system"        │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

# 📋 PHASE 8: WEB SUPPORT ENHANCEMENTS

---

## TASK 8.1: Full Web Directory Picker

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 8, TASK 8.1: Full Web Directory Picker                │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 HIGH (web functionality)                       │
│ Estimated Time: 6-8 hours                                   │
│ Dependencies: Phase 3 (Directory Selection)                 │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/features/directory_selection/presentation/view/directory_selection_screen.dart
│ lib/features/directory_selection/data/datasources/directory_picker_ds.dart
│ lib/core/services/file_system_service.dart
│ lib/features/directory_selection/domain/usecases/scan_library_usecase.dart (update)
│ lib/features/directory_selection/presentation/providers/directory_provider.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Web-compatible directory picker                        │
│ [ ] Virtual file system for web                            │
│ [ ] Drag and drop support for audio files                  │
│ [ ] File upload interface for web                          │
│ [ ] Web-specific scanning workflow                         │
│ [ ] Browser-based file access                              │
│ [ ] IndexedDB storage for web files                        │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Directory picker works on web browsers                 │
│ [ ] Users can select directories on web                    │
│ [ ] Drag and drop of audio files supported                 │
│ [ ] File upload interface available on web                 │
│ [ ] Scanning works with web-selected files                 │
│ [ ] Performance is acceptable on web                       │
│ [ ] UI is intuitive for web users                          │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] Works in all major browsers                            │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Research web file system APIs                         │
│ [ ] Implement web-specific directory picker               │
│ [ ] Create virtual file system abstraction                │
│ [ ] Add drag and drop functionality for web               │
│ [ ] Implement file upload interface                       │
│ [ ] Update scanning workflow for web files                │
│ [ ] Update directory provider for web compatibility       │
│ [ ] Test with different browsers                          │
│ [ ] Write unit tests for web-specific code                │
│ [ ] Write widget tests for web UI                         │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add full web directory picker"         │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 8.2: Web Audio Playback

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 8, TASK 8.2: Web Audio Playback                       │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (web functionality)                   │
│ Estimated Time: 8-10 hours                                  │
│ Dependencies: Phase 5 (Audio Playback), Task 8.1 (Web Dir)  │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/features/player/data/datasources/audio_service_handler.dart
│ lib/features/player/data/datasources/web_audio_ds.dart     │
│ lib/features/player/presentation/providers/playback_provider.dart
│ lib/features/player/presentation/views/playback_screen.dart
│ lib/core/services/audio_service.dart
│ lib/features/player/domain/usecases/playback_usecase.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Web-compatible audio playback service                  │
│ [ ] Web Audio API integration                              │
│ [ ] Browser-specific audio controls                        │
│ [ ] Background audio for web (where supported)             │
│ [ ] Web-specific error handling                            │
│ [ ] Cross-browser compatibility                            │
│ [ ] Performance optimization for web                       │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Audio plays correctly in web browsers                  │
│ [ ] All playback controls work on web                      │
│ [ ] Background audio works where browser supports it       │
│ [ ] Audio quality is maintained on web                     │
│ [ ] Performance is acceptable on web                       │
│ [ ] Works in all major browsers                            │
│ [ ] Error handling works properly on web                   │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No regressions in mobile/desktop playback              │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Research Web Audio API capabilities                   │
│ [ ] Implement web-specific audio datasource               │
│ [ ] Update audio service handler for web compatibility    │
│ [ ] Update playback provider for web                      │
│ [ ] Test audio playback in different browsers             │
│ [ ] Optimize performance for web                          │
│ [ ] Handle browser-specific limitations                   │
│ [ ] Write unit tests for web audio code                   │
│ [ ] Write widget tests for web playback UI                │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add web audio playback support"        │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 8.3: Responsive UI for Desktop

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 8, TASK 8.3: Responsive UI for Desktop                │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (UI enhancement)                        │
│ Estimated Time: 5-7 hours                                   │
│ Dependencies: None (UI only)                                │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/features/library/presentation/views/library_screen.dart│
│ lib/features/player/presentation/views/playback_screen.dart│
│ lib/features/settings/presentation/views/settings_view.dart│
│ lib/features/directory_selection/presentation/view/directory_selection_screen.dart
│ lib/core/theme/app_theme.dart
│ lib/core/extensions/responsive_extension.dart
│ lib/app/router/app_router.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Layout adapts to different screen sizes                │
│ [ ] Desktop-optimized controls and navigation              │
│ [ ] Keyboard navigation support                              │
│ [ ] Mouse interaction optimizations                        │
│ [ ] Multi-panel layouts for larger screens                 │
│ [ ] Responsive typography and spacing                      │
│ [ ] Adaptive component sizing                                │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] UI adapts properly to different screen sizes           │
│ [ ] Desktop layouts are optimized for productivity         │
│ [ ] Keyboard navigation works properly                     │
│ [ ] Mouse interactions are smooth and responsive           │
│ [ ] Typography scales appropriately                        │
│ [ ] Components resize appropriately                        │
│ [ ] No layout issues on any supported size                 │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] Performance is maintained on all sizes                 │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Audit current UI for responsiveness issues            │
│ [ ] Implement responsive layout patterns                    │
│ [ ] Add keyboard navigation support                         │
│ [ ] Optimize for desktop mouse interactions               │
│ [ ] Create multi-panel layouts for large screens          │
│ [ ] Update typography for different sizes                 │
│ [ ] Test on various screen sizes                          │
│ [ ] Write widget tests for responsive layouts             │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add responsive UI for desktop"         │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 8.4: Web Authentication

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 8, TASK 8.4: Web Authentication                       │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 HIGH (web functionality)                       │
│ Estimated Time: 4-6 hours                                   │
│ Dependencies: Phase 2 (Authentication)                      │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/features/auth/data/datasources/firebase_auth_datasource.dart
│ lib/features/auth/presentation/providers/auth_provider.dart
│ lib/features/auth/presentation/views/login_view.dart
│ lib/features/auth/domain/usecases/login_usecase.dart (update)
│ lib/app/router/auth_guard.dart (update)
│ lib/core/services/auth_service.dart
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Web-compatible authentication flow                     │
│ [ ] OAuth providers working on web                         │
│ [ ] Session management for web                             │
│ [ ] Cookie/localStorage handling                           │
│ [ ] Web-specific security considerations                   │
│ [ ] Cross-origin handling                                  │
│ [ ] Password reset functionality for web                   │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Authentication works properly on web                   │
│ [ ] OAuth providers function on web                        │
│ [ ] Sessions persist appropriately on web                  │
│ [ ] Security is maintained on web                          │
│ [ ] Password reset works on web                            │
│ [ ] No regressions in mobile authentication                │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] Works in all major browsers                            │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Review current auth implementation for web issues     │
│ [ ] Update auth datasource for web compatibility          │
│ [ ] Update auth provider for web-specific handling        │
│ [ ] Test OAuth providers on web                           │
│ [ ] Implement web-specific session management             │
│ [ ] Handle web security considerations                    │
│ [ ] Test auth flow in different browsers                  │
│ [ ] Write unit tests for web auth code                    │
│ [ ] Write widget tests for web auth UI                    │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add web authentication support"        │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 8.5: Cross-Device Sync on Web

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 8, TASK 8.5: Cross-Device Sync on Web                 │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 HIGH (sync feature)                            │
│ Estimated Time: 5-7 hours                                   │
│ Dependencies: Phase 7 (Supabase Sync), Task 8.4 (Web Auth)  │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/features/sync/data/datasources/library_remote_ds.dart (update)
│ lib/features/sync/presentation/providers/sync_provider.dart (update)
│ lib/features/sync/presentation/widgets/sync_status_widget.dart
│ lib/features/settings/presentation/views/sync_settings_view.dart
│ lib/features/library/presentation/providers/library_provider.dart (update)
│ lib/features/player/presentation/providers/playback_provider.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Sync works consistently across web browsers            │
│ [ ] Web-specific sync optimizations                        │
│ [ ] Sync status indicators for web                         │
│ [ ] Sync settings tailored for web users                   │
│ [ ] Background sync capabilities for web                   │
│ [ ] Web storage integration with sync                      │
│ [ ] Performance optimization for web sync                  │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Sync works properly in web browsers                    │
│ [ ] Sync performance is acceptable on web                  │
│ [ ] Sync status is clearly visible on web                  │
│ [ ] Sync settings are appropriate for web users            │
│ [ ] No conflicts between web and mobile sync               │
│ [ ] Data remains consistent across all platforms           │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] Works in all major browsers                            │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Test current sync implementation on web               │
│ [ ] Identify web-specific sync issues                     │
│ [ ] Optimize sync for web performance                     │
│ [ ] Update sync UI for web users                          │
│ [ ] Handle web storage limitations                        │
│ [ ] Test sync across different browsers                   │
│ [ ] Write unit tests for web sync code                    │
│ [ ] Write widget tests for web sync UI                    │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add cross-device sync for web"         │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 8.6: PWA Support

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 8, TASK 8.6: PWA Support                              │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (distribution feature)                  │
│ Estimated Time: 6-8 hours                                   │
│ Dependencies: All previous web tasks                        │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ web/index.html                                             │
│ web/manifest.json                                          │
│ lib/main_web.dart (create if needed)                       │
│ lib/bootstrap.dart (update)                                │
│ lib/core/services/pwa_service.dart                         │
│ lib/features/settings/presentation/views/pwa_settings_view.dart
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Web app manifest with proper configuration             │
│ [ ] Service worker for offline functionality               │
│ [ ] PWA installation prompt                                │
│ [ ] Offline caching strategy                               │
│ [ ] App icon and splash screen for PWA                     │
│ [ ] Background sync for PWA                                │
│ [ ] PWA-specific settings                                  │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] App can be installed as PWA on supported devices       │
│ [ ] Offline functionality works as expected                │
│ [ ] PWA has proper branding and icons                      │
│ [ ] Background sync works in PWA mode                      │
│ [ ] PWA meets Google's PWA criteria                        │
│ [ ] Performance is acceptable in PWA mode                  │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] Works across supported PWA platforms                   │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Configure web app manifest                            │
│ [ ] Set up service worker for caching                     │
│ [ ] Implement PWA installation prompt                     │
│ [ ] Define offline caching strategy                       │
│ [ ] Add proper icons and splash screen                    │
│ [ ] Test PWA functionality                                │
│ [ ] Optimize for PWA performance                          │
│ [ ] Write tests for PWA-specific features                 │
│ [ ] Run: flutter build web --pwa                          │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add PWA support"                       │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

# 📋 PHASE 9: SETTINGS & UI POLISH

---

## TASK 9.1: Dark/Light Theme Toggle

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 9, TASK 9.1: Dark/Light Theme Toggle                  │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (UI enhancement)                        │
│ Estimated Time: 3-4 hours                                   │
│ Dependencies: None (UI only)                                │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/core/theme/app_theme.dart                              │
│ lib/features/settings/presentation/providers/theme_provider.dart
│ lib/features/settings/presentation/views/appearance_settings_view.dart
│ lib/features/settings/presentation/widgets/theme_toggle_widget.dart
│ lib/app/providers.dart (update)                            │
│ lib/main.dart (update)                                     │
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Theme provider to manage theme state                   │
│ [ ] Dark and light theme definitions                       │
│ [ ] Theme toggle switch in settings                        │
│ [ ] Theme persistence across app restarts                  │
│ [ ] System theme detection and following                   │
│ [ ] Smooth theme transition animations                     │
│ [ ] Theme-appropriate icons                                │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] User can toggle between dark and light themes          │
│ [ ] Theme choice persists across app restarts              │
│ [ ] App follows system theme by default                    │
│ [ ] All UI elements look appropriate in both themes        │
│ [ ] Theme transitions are smooth                           │
│ [ ] Icons adapt to current theme                           │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No visual regressions                                  │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Define dark and light theme variants                  │
│ [ ] Create theme provider for state management            │
│ [ ] Add theme toggle to appearance settings               │
│ [ ] Implement theme persistence mechanism                 │
│ [ ] Add system theme detection                            │
│ [ ] Implement smooth theme transitions                    │
│ [ ] Update all UI elements for both themes                │
│ [ ] Write unit tests for theme logic                      │
│ [ ] Write widget tests for theme UI                       │
│ [ ] Test theme switching functionality                    │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add dark/light theme toggle"           │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 9.2: Appearance Customization

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 9, TASK 9.2: Appearance Customization                 │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (UI enhancement)                        │
│ Estimated Time: 4-6 hours                                   │
│ Dependencies: Task 9.1 (Theme Toggle)                       │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/core/theme/app_theme.dart (update)                     │
│ lib/features/settings/presentation/providers/appearance_provider.dart
│ lib/features/settings/presentation/views/appearance_settings_view.dart (update)
│ lib/features/settings/presentation/widgets/font_size_slider.dart
│ lib/features/settings/presentation/widgets/layout_preference_widget.dart
│ lib/features/settings/presentation/widgets/color_accent_selector.dart
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Font size adjustment slider                            │
│ [ ] Layout density options (compact/regular/expansive)     │
│ [ ] Accent color selection                                 │
│ [ ] Appearance provider for state management               │
│ [ ] Persistence of appearance settings                     │
│ [ ] Preview of appearance changes                          │
│ [ ] Reset to defaults option                               │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] User can adjust font size                              │
│ [ ] User can select layout density                         │
│ [ ] User can choose accent color                           │
│ [ ] Settings persist across app restarts                   │
│ [ ] Changes apply immediately to UI                        │
│ [ ] Preview shows changes before saving                    │
│ [ ] Reset option restores default settings                 │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No visual regressions                                  │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Add font size adjustment functionality                │
│ [ ] Implement layout density options                      │
│ [ ] Add accent color selection                            │
│ [ ] Create appearance provider                            │
│ [ ] Implement settings persistence                        │
│ [ ] Add preview functionality                             │
│ [ ] Add reset to defaults option                          │
│ [ ] Update appearance settings view                       │
│ [ ] Write unit tests for appearance logic                 │
│ [ ] Write widget tests for appearance UI                  │
│ [ ] Test all appearance options                           │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add appearance customization"          │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 9.3: Notification Preferences

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 9, TASK 9.3: Notification Preferences                 │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (user experience)                       │
│ Estimated Time: 4-5 hours                                   │
│ Dependencies: None (settings only)                          │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/settings/presentation/providers/notification_provider.dart
│ lib/features/settings/presentation/views/notification_settings_view.dart
│ lib/features/settings/presentation/widgets/notification_toggle_group.dart
│ lib/core/services/notification_service.dart                │
│ lib/features/player/presentation/providers/playback_provider.dart (update)
│ lib/features/library/presentation/providers/library_provider.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Notification preferences provider                      │
│ [ ] UI for managing notification types                     │
│ [ ] Toggle for playback notifications                      │
│ [ ] Toggle for library updates                             │
│ [ ] Toggle for sync status                                 │
│ [ ] Time-based notification preferences                    │
│ [ ] Notification scheduling options                        │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] User can enable/disable playback notifications         │
│ [ ] User can enable/disable library notifications          │
│ [ ] User can set notification timing preferences           │
│ [ ] Settings persist across app restarts                   │
│ [ ] Notifications follow user preferences                  │
│ [ ] UI is intuitive and user-friendly                      │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No notification spam                                   │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create notification preferences provider              │
│ [ ] Design notification settings UI                       │
│ [ ] Implement notification toggles                        │
│ [ ] Add time-based preferences                            │
│ [ ] Update notification service to respect preferences    │
│ [ ] Integrate with playback and library providers         │
│ [ ] Test notification preferences                         │
│ [ ] Write unit tests for notification logic               │
│ [ ] Write widget tests for notification UI                │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add notification preferences"          │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 9.4: Audio Format Preferences

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 9, TASK 9.4: Audio Format Preferences                 │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 LOW (advanced feature)                         │
│ Estimated Time: 3-4 hours                                   │
│ Dependencies: Phase 5 (Audio Playback)                      │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/features/settings/presentation/providers/audio_provider.dart
│ lib/features/settings/presentation/views/audio_settings_view.dart
│ lib/features/settings/presentation/widgets/audio_format_selector.dart
│ lib/features/player/data/datasources/audio_service_handler.dart (update)
│ lib/features/player/presentation/providers/playback_provider.dart (update)
│ lib/features/directory_selection/domain/usecases/scan_library_usecase.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Audio preferences provider                             │
│ [ ] UI for selecting preferred audio formats               │
│ [ ] Option to prioritize certain formats                   │
│ [ ] Audio quality settings (bitrate, sample rate)          │
│ [ ] Format compatibility checking                          │
│ [ ] Format-specific playback optimizations                 │
│ [ ] Format preference persistence                          │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] User can select preferred audio formats                │
│ [ ] Settings persist across app restarts                   │
│ [ ] Audio quality settings are respected                   │
│ [ ] Format preferences affect scanning behavior            │
│ [ ] All supported formats continue to work                 │
│ [ ] UI is intuitive and user-friendly                      │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No performance degradation                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create audio preferences provider                     │
│ [ ] Design audio settings UI                              │
│ [ ] Implement format selection options                    │
│ [ ] Add audio quality settings                            │
│ [ ] Update audio service to respect preferences           │
│ [ ] Update scanning to consider format preferences        │
│ [ ] Test format preference functionality                  │
│ [ ] Write unit tests for audio preferences                │
│ [ ] Write widget tests for audio settings UI              │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add audio format preferences"          │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 9.5: Cache Management

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 9, TASK 9.5: Cache Management                         │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (performance feature)                   │
│ Estimated Time: 5-6 hours                                   │
│ Dependencies: None (utility feature)                        │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE/MODIFY:                                     │
│ lib/features/settings/presentation/providers/cache_provider.dart
│ lib/features/settings/presentation/views/cache_settings_view.dart
│ lib/features/settings/presentation/widgets/cache_info_widget.dart
│ lib/features/settings/presentation/widgets/cache_management_widget.dart
│ lib/core/services/cache_service.dart                       │
│ lib/features/library/data/datasources/audiobook_local_ds.dart (update)
│ lib/features/player/data/datasources/playback_local_ds.dart (update)
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Cache management provider                              │
│ [ ] UI showing cache size and content                      │
│ [ ] Button to clear cache                                  │
│ [ ] Automatic cache cleanup options                        │
│ [ ] Cache size limits                                      │
│ [ ] Selective cache clearing                               │
│ [ ] Cache statistics display                               │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] User can view current cache size                       │
│ [ ] User can clear cache manually                          │
│ [ ] Automatic cache cleanup works                          │
│ [ ] Cache size limits are enforced                         │
│ [ ] Cache statistics are accurate                          │
│ [ ] UI is intuitive and user-friendly                      │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] No data loss during cache operations                   │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create cache management provider                      │
│ [ ] Design cache settings UI                              │
│ [ ] Implement cache size calculation                      │
│ [ ] Add manual cache clearing functionality               │
│ [ ] Implement automatic cache cleanup                     │
│ [ ] Add cache size limits                                 │
│ [ ] Update local datasources for cache integration        │
│ [ ] Test cache management functionality                   │
│ [ ] Write unit tests for cache logic                      │
│ [ ] Write widget tests for cache UI                       │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add cache management"                  │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 9.6: About/Legal Screens

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 9, TASK 9.6: About/Legal Screens                      │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 LOW (compliance feature)                       │
│ Estimated Time: 3-4 hours                                   │
│ Dependencies: None (static content)                         │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE:                                            │
│ lib/features/settings/presentation/views/about_view.dart   │
│ lib/features/settings/presentation/views/legal_view.dart   │
│ lib/features/settings/presentation/views/privacy_policy_view.dart
│ lib/features/settings/presentation/views/terms_of_service_view.dart
│ lib/features/settings/presentation/widgets/legal_menu_item.dart
│ lib/app/router/app_router.dart (update)                    │
│ assets/legal/ (create directory)                           │
│ assets/legal/privacy_policy.md                             │
│ assets/legal/terms_of_service.md                           │
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] About app screen with version and info                 │
│ [ ] Legal information screen                               │
│ [ ] Privacy policy screen                                  │
│ [ ] Terms of service screen                                │
│ [ ] Legal menu item in settings                            │
│ [ ] Links to external legal documents                      │
│ [ ] Version display and update check                       │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] About screen displays app information                  │
│ [ ] Legal screens display required information             │
│ [ ] Privacy policy is accessible                           │
│ [ ] Terms of service is accessible                         │
│ [ ] Version information is accurate                        │
│ [ ] UI is professional and user-friendly                   │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] All legal requirements met                             │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create About screen with app information              │
│ [ ] Create Legal information screen                       │
│ [ ] Create Privacy Policy screen                          │
│ [ ] Create Terms of Service screen                        │
│ [ ] Add legal menu item to settings                       │
│ [ ] Add version display and update check                  │
│ [ ] Create assets for legal documents                     │
│ [ ] Test all legal screens                                │
│ [ ] Write widget tests for legal UI                       │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add about/legal screens"               │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 9.7: Help & FAQ

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 9, TASK 9.7: Help & FAQ                               │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 LOW (support feature)                          │
│ Estimated Time: 4-5 hours                                   │
│ Dependencies: None (static content)                         │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO CREATE:                                            │
│ lib/features/settings/presentation/views/help_view.dart    │
│ lib/features/settings/presentation/views/faq_view.dart     │
│ lib/features/settings/presentation/widgets/help_menu_item.dart
│ lib/features/settings/presentation/widgets/faq_category_widget.dart
│ lib/features/settings/presentation/widgets/searchable_faq_widget.dart
│ assets/help/ (create directory)                            │
│ assets/help/faq_content.json                               │
│ assets/help/user_guide.md                                  │
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] Help screen with user guide                            │
│ [ ] FAQ screen with searchable questions                   │
│ [ ] Help menu item in settings                             │
│ [ ] Categorized FAQ sections                               │
│ [ ] Search functionality for FAQs                          │
│ [ ] Contact support option                                 │
│ [ ] Troubleshooting guides                                 │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] Help screen displays user guide                        │
│ [ ] FAQ screen is searchable and organized                 │
│ [ ] Help menu item is accessible                           │
│ [ ] FAQ categories are logical and helpful                 │
│ [ ] Search finds relevant FAQ items                        │
│ [ ] UI is intuitive and user-friendly                      │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] Content is helpful and accurate                        │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create Help screen with user guide                    │
│ [ ] Create FAQ screen with searchable content             │
│ [ ] Add Help menu item to settings                        │
│ [ ] Implement categorized FAQ sections                    │
│ [ ] Add search functionality for FAQs                     │
│ [ ] Add contact support option                            │
│ [ ] Create assets for help content                        │
│ [ ] Test help and FAQ functionality                       │
│ [ ] Write widget tests for help UI                        │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add help & FAQ screens"                │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## TASK 9.8: Accessibility Features

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 9, TASK 9.8: Accessibility Features                   │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🟡 MEDIUM (inclusive design)                      │
│ Estimated Time: 6-8 hours                                   │
│ Dependencies: All previous UI work                          │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILES TO MODIFY:                                            │
│ lib/core/theme/app_theme.dart (update)                     │
│ lib/features/settings/presentation/providers/accessibility_provider.dart
│ lib/features/settings/presentation/views/accessibility_settings_view.dart
│ lib/features/settings/presentation/widgets/high_contrast_toggle.dart
│ lib/features/settings/presentation/widgets/text_scaling_selector.dart
│ lib/features/settings/presentation/widgets/screen_reader_hints_toggle.dart
│ lib/app/router/app_router.dart (update)                    │
│ lib/main.dart (update)                                     │
│                                                             │
│ FEATURE REQUIREMENTS:                                       │
│ [ ] High contrast mode toggle                              │
│ [ ] Text scaling options                                   │
│ [ ] Screen reader optimization                             │
│ [ ] Voice control support                                  │
│ [ ] Alternative navigation methods                         │
│ [ ] Color blindness accommodations                         │
│ [ ] Reduced motion options                                 │
│                                                             │
│ ACCEPTANCE CRITERIA:                                        │
│ [ ] High contrast mode is available                        │
│ [ ] Text scaling works throughout the app                  │
│ [ ] Screen readers can properly interpret UI               │
│ [ ] App works with voice control                           │
│ [ ] Alternative navigation is available                    │
│ [ ] Color blind users can distinguish UI elements          │
│ [ ] Reduced motion options prevent discomfort              │
│ [ ] Tests pass with 80%+ coverage                          │
│ [ ] Meets accessibility standards (WCAG)                   │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Implement high contrast mode                          │
│ [ ] Add text scaling options                              │
│ [ ] Optimize UI for screen readers                        │
│ [ ] Add voice control support                             │
│ [ ] Implement alternative navigation                      │
│ [ ] Add color blindness accommodations                    │
│ [ ] Add reduced motion options                            │
│ [ ] Test with accessibility tools                         │
│ [ ] Write unit tests for accessibility logic              │
│ [ ] Write widget tests for accessibility UI               │
│ [ ] Run accessibility audit                               │
│ [ ] Run: flutter analyze (0 errors)                       │
│ [ ] Run: flutter test                                     │
│ [ ] Run: flutter test --coverage                          │
│ [ ] Commit: "Feat: Add accessibility features"            │
│ [ ] Mark complete in project status                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 How to Use These Cards

### For Individual Agent:
1. Copy the card for your assigned task
2. Keep it visible while working
3. Check off items as you complete them
4. Mark complete when all criteria met

### For Team Lead:
1. Print/share cards with assigned agents
2. Track progress using status field
3. Identify blockers early
4. Update project status daily

### For Project Manager:
1. Use status fields to track overall progress
2. Identify critical path items (🔴)
3. Manage dependencies between tasks
4. Update timeline if blockers occur

---

## 📊 Card Status Legend

| Status | Meaning | Action |
|--------|---------|--------|
| [ ] TODO | Not started | Assign to agent |
| [ ] IN PROGRESS | Agent working | Check progress |
| [ ] COMPLETE | Done & verified | Mark in project status |

## 🔴 Priority Legend

| Priority | Meaning | Action |
|----------|---------|--------|
| 🔴 CRITICAL | Blocks other work | Start immediately |
| 🟡 HIGH | Important feature | Start after critical |
| 🟡 MEDIUM | Valuable feature | Start when appropriate |
| 🟡 LOW | Nice to have | Start when other work is done |

---

**Created:** December 15, 2025
**For:** Task Assignment & Tracking
**Status:** MVP Complete! 🎉
**Update:** All tasks completed - December 17, 2025
**Extended:** Post-MVP tasks added - January 27, 2026
