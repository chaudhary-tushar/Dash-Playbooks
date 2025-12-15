# Agent Task Assignment Prompt Template

## Overview
This is a reusable prompt template for assigning development tasks to AI agents working on the Flutbook MVP project. It provides a standardized structure for clear, unambiguous task delegation with complete context and acceptance criteria.

---

## Template Structure

### Header
```
Subject: TASK ASSIGNMENT: [Phase #], Task [Task #] - [Task Title]

Hi ,

You're assigned to Task [Task #] ([Task Title])
Priority: [CRITICAL | HIGH | MEDIUM | LOW] | Estimated Time: [X hours]
Status: [NOT STARTED | IN PROGRESS | BLOCKED | COMPLETE]
```

### Task Overview
```
## What You're Building

[Clear, concise description of what needs to be implemented]

### Context
- Current Phase: [Phase Name]
- Dependency Status: [Dependencies that must be complete first]
- Related Tasks: [Link to other related tasks]
```

### Detailed Requirements
```
## Requirements

### Must Have (Acceptance Criteria)
- [ ] [Specific, testable requirement #1]
- [ ] [Specific, testable requirement #2]
- [ ] [Specific, testable requirement #3]

### Nice to Have (Optional)
- [ ] [Optional enhancement #1]
- [ ] [Optional enhancement #2]

### Non-Goals
- [Explicitly state what NOT to do]
```

### Technical Guidance
```
## Technical Implementation Guide

### Architecture Pattern
[Describe the pattern to follow: Riverpod Provider, Feature structure, etc.]

### Code Standards
- Follow patterns from: [Reference existing code file/example]
- Testing approach: [Unit tests, widget tests, integration tests]
- Code review checklist: [Specific things to verify]

### Dependencies
```
[List of files/packages to reference]
```

### Example Implementation
[Show 1-2 code examples if helpful]
```

### Supporting Files
```
## Files You'll Need

1. **START_HERE.md** - Project onboarding (5 min read)
2. **AGENT_INSTRUCTIONS.md** - Workflow standards and code patterns (20 min read)
3. **IMPLEMENTATION_SUMMARY.md** - Architecture overview
4. **Documentation for this phase** - Phase-specific details
5. **CURRENT_PROGRESS.txt** - Check status before starting

### Reference Files
- [Code pattern examples from existing features]
- [Test examples]
- [Configuration templates]
```

### Workflow
```
## Your Workflow

1. **Setup** (15 min)
   - Read START_HERE.md
   - Read AGENT_INSTRUCTIONS.md
   - Review IMPLEMENTATION_SUMMARY.md

2. **Plan** (30 min)
   - Create feature folder structure if needed
   - Outline key files you'll create/modify
   - Identify tests you'll write

3. **Implement** (2-4 hours)
   - Code following standards from AGENT_INSTRUCTIONS.md
   - Write tests concurrently
   - Commit regularly with clear messages

4. **Verify** (30 min)
   - Check all acceptance criteria are met
   - Run tests and analyzer
   - Self-review against code standards

5. **Report** (10 min)
   - Update MVP_STATUS.md with completion status
   - Document any blockers or dependencies
   - Link to PR/commits
```

### Questions & Blocking
```
## If You Get Stuck

1. **Check First**: DOCUMENTATION_INDEX.md (FAQ section)
2. **Reference**: Look at similar completed tasks
3. **Ask**: Provide specific context: "In [file], when trying to [action], I get [error] because [theory]"

### Known Issues & Workarounds
[Document any known blockers and workarounds]
```

### Completion Checklist
```
## How to Know You're Done

- [ ] All acceptance criteria are met
- [ ] No new build errors introduced
- [ ] All new code has tests (min 80% coverage)
- [ ] Code follows AGENT_INSTRUCTIONS.md standards
- [ ] MVP_STATUS.md updated with task status
- [ ] Related documentation updated (if applicable)
- [ ] Ready for code review
```

---

## Usage Instructions

### For Task Assignment (Manager)

1. **Gather Information**
   - Identify the specific task from MVP_STATUS.md
   - Get task details from TASK_CARDS.md
   - Identify supporting files needed

2. **Customize Template**
   - Replace all [bracketed placeholders]
   - Add specific code examples for this task
   - Include actual file paths and line numbers
   - Specify exact acceptance criteria

3. **Attach Supporting Files**
   - Always include: START_HERE.md, AGENT_INSTRUCTIONS.md
   - Phase-specific documentation
   - Relevant code examples
   - Link to MVP_STATUS.md for tracking

4. **Send & Track**
   - Give clear deadline (ideally 3 hours for small, 8 hours for large)
   - Agent updates MVP_STATUS.md upon completion
   - You verify acceptance criteria, then mark complete

### For Agent (Developer)

1. **Read in Order** (45 min total)
   - START_HERE.md (5 min)
   - AGENT_INSTRUCTIONS.md (20 min)
   - This task assignment (20 min)

2. **Implement** (2-4 hours)
   - Follow the workflow section above
   - Use code examples provided
   - Test thoroughly

3. **Complete** (10 min)
   - Verify all checkboxes in "How to Know You're Done"
   - Update MVP_STATUS.md
   - Commit with message: "Complete: Task [#] - [Title]"

---

## Real Example

### Example Assignment
```
Subject: TASK ASSIGNMENT: Phase 2, Task 2.1 - Login Use Case

Hi Agent,

You're assigned to Task 2.1 (Login Use Case)
Priority: CRITICAL | Estimated Time: 3 hours
Status: NOT STARTED

## What You're Building

Implement the login screen and authentication flow. This is the critical path item that unblocks Phase 4 (Library Management).

### Context
- Current Phase: Phase 2 - Authentication
- Dependencies: None (can start immediately)
- Related Tasks: Task 2.2 (SignUp), Task 2.3 (Password Reset)

## Requirements

### Must Have
- [ ] Login screen UI with email/password fields
- [ ] Email validation (RFC 5322)
- [ ] Firebase Auth integration
- [ ] Error handling and user feedback
- [ ] Successful login → redirect to library
- [ ] All logic unit tested (80%+ coverage)

### Nice to Have
- [ ] "Remember me" functionality
- [ ] Login success animation
- [ ] Biometric auth skeleton (for future)

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

### Example Pattern
```dart
// providers/login_provider.dart
class LoginNotifier extends Notifier<AsyncValue<User>> {
  @override
  AsyncValue<User> build() => const AsyncValue.loading();

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
      _authRepository.login(email, password)
    );
  }
}

final loginProvider = NotifierProvider<LoginNotifier, AsyncValue<User>>(
  () => LoginNotifier(),
);
```

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

- [MVP_STATUS.md](../../documentation/MVP_STATUS.md) - Task tracking
- [TASK_CARDS.md](../../documentation/TASK_CARDS.md) - All task cards
- [AGENT_INSTRUCTIONS.md](../../documentation/AGENT_INSTRUCTIONS.md) - Code standards
- [START_HERE.md](../../documentation/START_HERE.md) - Onboarding guide

@MVP_STATUS.md
@TASK_CARDS.md
@AGENT_INSTRUCTIONS.md
@START_HERE.md