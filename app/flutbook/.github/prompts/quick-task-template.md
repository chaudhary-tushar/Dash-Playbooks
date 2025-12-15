# Quick Task Assignment Template (5-Minute Version)

Use this streamlined template for rapid task assignments when you have less time.

---

## Quick Template

```
Subject: TASK: [Phase #]-[Task #] - [Title]

[Agent Name],

📋 **Task**: [Task Title]
⏱️ **Time**: [X hours]  |  🎯 **Priority**: [CRITICAL|HIGH|MEDIUM|LOW]

## What to Build
[1-2 sentence description of deliverable]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Architecture Reference
Follow: `[lib/features/existing-feature]` pattern
Use: `[Riverpod NotifierProvider | BLoC | GetX]`

## Code Example
```dart
[1-2 line code snippet showing the pattern]
```

## Files to Read
- AGENT_INSTRUCTIONS.md (code patterns section)
- [Phase-specific docs]

## Start Here
1. Read AGENT_INSTRUCTIONS.md (20 min)
2. Review example in `[path/to/similar/feature]`
3. Implement following that pattern
4. Update MVP_STATUS.md when done

Questions? Check DOCUMENTATION_INDEX.md FAQ

Deadline: [Date/Time]
```

---

## Worked Examples

### Example 1: UI Widget (1-2 hours)

```
Subject: TASK: Phase 1-3 - Splash Screen Logo Animation

Alex,

📋 **Task**: Add animated logo to splash screen
⏱️ **Time**: 2 hours  |  🎯 **Priority**: HIGH

## What to Build
Animated logo that fades in over 2 seconds when app launches. Should animate from 0% to 100% opacity.

## Acceptance Criteria
- [ ] Logo file placed in assets/images/
- [ ] Animation uses Flutter's AnimationController
- [ ] Fade duration is exactly 2 seconds
- [ ] Animation fires on screen init
- [ ] Unit test verifies animation timing
- [ ] No new build errors

## Architecture Reference
Follow: `lib/presentation/widgets/animated_logo.dart` pattern
Use: `AnimatedOpacity` widget

## Code Example
```dart
class AnimatedLogo extends StatefulWidget {
  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(seconds: 2), vsync: this);
    _controller.forward();
  }
}
```

## Start Here
1. Check similar animation in Phase 1 splash code
2. Create widget file
3. Implement using example above
4. Write unit test
5. Update MVP_STATUS.md

Deadline: Today, 5pm
```

### Example 2: Provider Implementation (2-3 hours)

```
Subject: TASK: Phase 2-1 - Login State Provider

Sam,

📋 **Task**: Create login state provider with error handling
⏱️ **Time**: 3 hours  |  🎯 **Priority**: CRITICAL

## What to Build
Riverpod NotifierProvider that manages login form state, validation, and Firebase auth calls.

## Acceptance Criteria
- [ ] Provider handles email validation
- [ ] Password requirements enforced (8+ chars, 1 uppercase)
- [ ] Firebase authentication called on submit
- [ ] Errors surface to UI (enum-based)
- [ ] Loading state prevents double-submit
- [ ] 85%+ test coverage with mocked Firebase
- [ ] No build errors

## Architecture Reference
Follow: `lib/features/auth/presentation/providers/` pattern
Use: `Riverpod 3.x NotifierProvider`

## Code Example
```dart
class LoginNotifier extends Notifier<AsyncValue<AuthResult>> {
  @override
  AsyncValue<AuthResult> build() => const AsyncValue.loading();

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
      ref.read(firebaseAuthProvider).signIn(email, password)
    );
  }
}
```

## Start Here
1. Read Phase 2 section of AGENT_INSTRUCTIONS.md
2. Check Phase 1 completed provider for pattern
3. Create domain layer first (entity, usecase)
4. Implement provider
5. Write tests using Riverpod testing utilities
6. Update MVP_STATUS.md

Deadline: 4 hours from now
```

### Example 3: Full Feature (4-8 hours)

```
Subject: TASK: Phase 4-2 - Book Library Display

Jordan,

📋 **Task**: Complete book library view with filtering
⏱️ **Time**: 6 hours  |  🎯 **Priority**: HIGH

## What to Build
Library page showing list of user's books with category filter, sort options, and book detail navigation.

## Acceptance Criteria
- [ ] Fetch books from Firestore (data layer)
- [ ] Filter by category (state in provider)
- [ ] Sort by date/title (provider state)
- [ ] Display 12 books per page with pagination
- [ ] Tap book → navigate to detail page
- [ ] Loading skeleton while fetching
- [ ] Error state with retry button
- [ ] 80%+ test coverage for all layers
- [ ] Follows clean architecture pattern

## Architecture Reference
Follow: `lib/features/library/` complete structure
- `data/datasources/` - Firestore queries
- `domain/repositories/` - Abstract interface
- `presentation/providers/` - Riverpod state
- `presentation/pages/` - UI

## Code Example
```dart
// Domain
abstract class LibraryRepository {
  Future<List<Book>> getBooks({required String? category});
  Future<void> setCategory(String category);
}

// Provider
class LibraryNotifier extends Notifier<AsyncValue<List<Book>>> {
  @override
  AsyncValue<List<Book>> build() => const AsyncValue.loading();

  void setCategory(String category) {
    // Filter logic
  }
}
```

## Start Here
1. Read AGENT_INSTRUCTIONS.md section on Feature Structure
2. Review Phase 3 complete feature as template
3. Implement in order: domain → data → presentation
4. Test each layer independently
5. Wire up in provider
6. Update MVP_STATUS.md

Deadline: Tomorrow, 2pm
```

---

## How to Use This Template

### For Managers
1. Pick a task from MVP_STATUS.md
2. Choose appropriate complexity level (1-2, 2-4, or 4-8 hours)
3. Fill in the bracketed sections
4. Add 1-2 code examples
5. Send with supporting docs

### For Agents
1. Read all sections (5 minutes)
2. Check code example - matches pattern you'll use
3. Start implementation immediately
4. Update MVP_STATUS.md when done

---

## Time Estimates by Task Type

| Task Type | Time | Complexity |
|-----------|------|-----------|
| Single widget/component | 1-2 hrs | LOW |
| Provider with basic logic | 2-3 hrs | LOW-MED |
| Single domain layer (entity+usecase) | 2-3 hrs | MED |
| Full feature (all 3 layers) | 4-8 hrs | HIGH |
| Bug fix/refactor | 1-4 hrs | VAR |
| UI polish/animations | 2-4 hrs | MED |

---

## Checklist Before Sending

- [ ] Task is specific (not vague)
- [ ] Time estimate is realistic
- [ ] All acceptance criteria listed
- [ ] Code example provided
- [ ] Related existing code referenced
- [ ] Supporting files listed
- [ ] Clear deadline given

---

## Version

- **v1.0** - Quick template for rapid assignments
- **Created**: December 15, 2025
- **Status**: Ready for use
