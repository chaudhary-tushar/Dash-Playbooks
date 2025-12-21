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
| 🟢 MEDIUM | Nice to have | Start when blocked |

---

**Created:** December 15, 2025
**For:** Task Assignment & Tracking
**Status:** MVP Complete! 🎉
**Update:** All tasks completed - December 17, 2025
