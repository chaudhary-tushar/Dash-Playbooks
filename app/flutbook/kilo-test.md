Subject: TASK ASSIGNMENT: Phase 2, Task 2.2 - Anonymous Login Use Case

Hi Agent,

You're assigned to Task 2.3 (2.3: Firebase Auth Datasource )
Priority: CRITICAL | Estimated Time: 2 hours
Status: NOT STARTED

## What You're Building
**Status:** [ ] Pending
**File:** `lib/features/auth/presentation/providers/auth_provider.dart` (NEW)

**Description:**
Create a Riverpod provider for managing authentication state across the app.

**Acceptance Criteria:**
- [ ] Riverpod `StateNotifier` or `AsyncNotifier` pattern
- [ ] Exposes `isAuthenticated` boolean
- [ ] Manages login/logout state
- [ ] Persists auth state to local storage
- [ ] Has getter for current user profile

**Code Example:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider.autoDispose<
    AuthNotifier,
    AsyncValue<AuthState>
>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthNotifier(userRepository);
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier(this._userRepository) : super(const AsyncValue.loading());

  final UserRepository _userRepository;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _userRepository.loginWithEmail(email, password);
    // Handle result and update state
  }

  Future<void> loginAnonymously() async {
    state = const AsyncValue.loading();
    final result = await _userRepository.loginAnonymously();
    // Handle result and update state
  }
}
```
---

# TASK 2.4: Auth State Provider

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2, TASK 2.4: Create Auth State Provider              │
├─────────────────────────────────────────────────────────────┤
│ Priority: 🔴 CRITICAL (state management)                    │
│ Estimated Time: 2-3 hours                                   │
│ Dependencies: Tasks 2.1, 2.2, 2.3                          │
│ Status: [ ] TODO / [ ] IN PROGRESS / [ ] COMPLETE          │
├─────────────────────────────────────────────────────────────┤
│ FILE TO CREATE:                                             │
│ lib/features/auth/presentation/providers/auth_provider.dart│
│                                                             │
│ DESCRIPTION:                                                │
│ Create Riverpod provider for managing authentication state  │
│                                                             │
│ REQUIREMENTS:                                               │
│ [ ] NotifierProvider pattern (Riverpod 3.x)               │
│ [ ] Exposes isAuthenticated boolean                        │
│ [ ] Manages login/logout state                             │
│ [ ] Persists auth state to local storage                   │
│ [ ] Has getter for current user profile                    │
│                                                             │
│ METHODS NEEDED:                                             │
│ - login(email, password) → Future<void>                    │
│ - loginAnonymously() → Future<void>                        │
│ - logout() → Future<void>                                  │
│ - getCurrentUser() → User?                                 │
│ - isAuthenticated() → bool                                 │
│                                                             │
│ ARCHITECTURE:                                               │
│ Provider pattern from IMPLEMENTATION_SUMMARY.md             │
│ Use NotifierProvider (NOT StateNotifierProvider!)           │
│                                                             │
│ CHECKLIST:                                                  │
│ [ ] Create AuthNotifier class                              │
│ [ ] Implement build() method                               │
│ [ ] Add login() method                                     │
│ [ ] Add loginAnonymously() method                          │
│ [ ] Add logout() method                                    │
│ [ ] Create AuthState class                                 │
│ [ ] Write tests for all methods                            │
│ [ ] Build succeeds (0 new errors)                          │
│ [ ] Commit & mark complete                                 │
└─────────────────────────────────────────────────────────────┘
```

---
## Technical Implementation

### Architecture Pattern
Follow the Feature folder pattern from Phase 1:
```
lib/features/auth/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    └── providers/
```

### Code Standards
- Use Riverpod 3.x NotifierProvider (see example below)
- Test using test package with mocks
- Follow naming conventions from AGENT_INSTRUCTIONS.md


## Files You'll Need
1. START_HERE.md
2. AGENT_INSTRUCTIONS.md
3. IMPLEMENTATION_SUMMARY.md (Phase 2 section)

Deadline: 3 hours from now
Update MVP_STATUS.md when complete
```

---

## Tips for Effective Prompts

### Do's ✅
- Include actual file paths and line numbers
- Show real code examples, not pseudocode
- Be specific about "done" (include all acceptance criteria)
- Link to related tasks and dependencies
- Provide 2-3 code pattern examples

### Don'ts ❌
- Don't be vague ("make it work", "implement auth")
- Don't assume knowledge of the codebase
- Don't omit acceptance criteria
- Don't skip code examples
- Don't make tasks too large (>8 hours)

### Task Sizing Guide
- **1-2 hours**: Single file, no dependencies (e.g., new widget)
- **2-4 hours**: Feature component with tests (e.g., login page)
- **4-8 hours**: Complete feature domain (data + domain + presentation)
- **8+ hours**: Too large, split into smaller tasks

---

## File Checklist

When creating a task assignment, always include:
- [ ] Clear priority level (CRITICAL/HIGH/MEDIUM/LOW)
- [ ] Realistic time estimate
- [ ] Specific acceptance criteria (testable)
- [ ] Architecture pattern reference
- [ ] Code examples (1-3 snippets)
- [ ] List of supporting files to read
- [ ] Known blockers/workarounds
- [ ] Completion verification checklist

---

## Version & History

- **v1.0** - Initial template based on Flutbook MVP documentation
- **Created**: December 15, 2025
- **Last Updated**: December 15, 2025
- **Status**: Ready for use

---

## Quick Links

@MVP_STATUS.md
@TASK_CARDS.md
@AGENT_INSTRUCTIONS.md
@START_HERE.md