# Agent Management & Coordination Template

Strategic prompt for managing multiple agents and coordinating work across phases.

---

## Manager's Daily Briefing Template

Use this when briefing agents on their daily work and coordinating between team members.

```
## Team Daily Briefing - [Date]

### 🎯 Today's Mission
Complete [X tasks] across [Y phases] to reach [Z% completion] by EOD.

### 📊 Current Status
- Overall Progress: [X/33 tasks complete]
- Build Health: [X errors, trending ↑/↓]
- Critical Path: Phase [X] - [Status]
- Timeline to MVP: [X days]

### 👥 Team Assignments

**Agent 1 [Name]**: Phase [X], Tasks [A-B]
- Task A-1: [Title] (Priority: CRITICAL)
- Task A-2: [Title] (Priority: HIGH)
- Blocker Check: ✅ Ready to start
- Dependency: Unblocked by [completed task]

**Agent 2 [Name]**: Phase [Y], Tasks [C-D]
- Task C-1: [Title] (Priority: HIGH)
- Task C-2: [Title] (Priority: MEDIUM)
- Blocker Check: ⚠️ Waiting for [dependency]
- Start: After Agent 1 completes Task A-1

**Agent 3 [Name]**: Phase [Z], Tasks [E]
- Task E-1: [Title] (Priority: MEDIUM)
- Blocker Check: ✅ Ready to start
- Dependency: Can start independently

### ⚡ Quick Start Checklist
- [ ] Each agent has received task assignment
- [ ] Supporting files: START_HERE.md, AGENT_INSTRUCTIONS.md, Phase docs
- [ ] MVP_STATUS.md shared and agents know how to update it
- [ ] Blockers identified and communicated
- [ ] Deadlines set: Agent 1 ([time]), Agent 2 ([time]), Agent 3 ([time])

### 🚨 Blockers & Coordination
1. **[Blocker 1]**: Resolved when [Agent X] completes [Task Y]
2. **[Blocker 2]**: Workaround: [Quick solution], full fix in Sprint [N]

### 📅 Milestones Today
- [Time]: Agent 1 completes Task A-1 → Agent 2 unblocked
- [Time]: Mid-day sync (async update in MVP_STATUS.md)
- [Time]: EOD verification of acceptance criteria

### 💬 Communication Plan
- **Updates**: Async via MVP_STATUS.md (no meetings)
- **Blockers**: Mention in #dev-chat immediately
- **Questions**: Check DOCUMENTATION_INDEX.md FAQ first
- **Sync time**: EOD standup 5-10 min (optional, only if blocked)

### 📞 Escalation Path
- Documentation Q: DOCUMENTATION_INDEX.md FAQ
- Code Pattern Q: Check similar completed feature
- Blocker: Message [Manager] immediately
- Stuck 30+ min: Pair with [Senior Agent]
```

---

## Parallel Execution Coordinator Template

Use when running multiple agents on parallel tasks.

```
## Parallel Execution Plan - [Initiative Name]

### 🎯 Objective
Complete MVP features [X, Y, Z] in [X days] by running [N] agents in parallel.

### 📋 Phase Dependencies

```
Phase 1: Splash ✅ (Complete)
    ↓
Phase 2: Auth ← [CRITICAL PATH]
    ├─→ Phase 4: Library (can start after Auth domain)
    └─→ Phase 5: Playback (can start after Auth domain)

Phase 3: Scanning ✅ (83% complete)

Phases 4 & 5 are BLOCKED until Phase 2 Auth Domain completes
```

### 👥 Agent Allocation Strategy

**Sprint 1 (Day 1-2)**: Serial (Sequential)
- Agent 1: Phase 2 Tasks 2.1-2.4 (Auth domain layer)
  - 2.1: Login Use Case (3 hrs)
  - 2.2: SignUp Use Case (3 hrs)
  - 2.3: Email Validation (2 hrs)
  - 2.4: State Management (3 hrs)
  - ✅ Unblocks everything

**Sprint 2 (Day 3)**: Parallel (Agents run simultaneously)
- Agent 1: Phase 2 Tasks 2.5-2.8 (Auth UI)
- Agent 2: Phase 4 Tasks 4.1-4.3 (Library feature) [Starts when Agent 1 finishes 2.4]
- Agent 3: Phase 3 finishing (Scanning) [Independent]

**Sprint 3 (Day 4)**: Full Parallel
- Agent 1: Phase 2 final polish
- Agent 2: Phase 4 continuation
- Agent 3: Phase 5 (Playback) [Starts when Agent 1 finishes core Auth]

**Sprint 4 (Day 5-6)**: Integration & Polish
- All agents: Testing, bug fixes, polish
- Release preparation

### 📊 Task Dependencies Matrix

| Task | Phase | Duration | Dependencies | Start After |
|------|-------|----------|--------------|------------|
| 2.1: Login | Auth | 3 hrs | None | Immediately |
| 2.2: SignUp | Auth | 3 hrs | None | Immediately |
| 2.3: Password Reset | Auth | 2 hrs | None | Immediately |
| 2.4: Auth State | Auth | 3 hrs | 2.1, 2.2, 2.3 | When all complete |
| 4.1: Library UI | Library | 4 hrs | 2.4 | When 2.4 done |
| 4.2: Book Filtering | Library | 3 hrs | 4.1 | When 4.1 done |
| 5.1: Playback UI | Playback | 4 hrs | 2.4 | When 2.4 done |

### 🎬 Start Coordination

**T+0 (Now)**
- Send Agent 1: [Task 2.1, 2.2, 2.3 assignment] + [5 supporting files]
- Send Agent 2: [Task waiting message] - You start when Agent 1 completes 2.4
- Send Agent 3: [Task 3.x assignment] - Run independently

**T+6 hours** (Agent 1 nears Task 2.4)
- Prepare Agent 2: Task 4.1 assignment, have files ready
- Check Agent 3: Any blockers?

**T+9 hours** (Agent 1 completes 2.4)
- ✅ Launch Agent 2 on Phase 4
- Send Agent 3: Task 5.1 assignment (if no Phase 4 blocker)

### 📈 Progress Tracking

Daily check-in (5 min):
```
Morning: Open MVP_STATUS.md
- Agents completed: [Tasks]
- In progress: [Tasks]
- Blockers: [None / List items]
- On track for: [X% completion today]
```

Update at EOD:
```
✅ Completed: [List tasks]
⏳ In Progress: [List tasks]
⚠️ Blocked: [If any, note blocker & workaround]
↗️ Next: [Tomorrow's assignments]
```

### 🚨 Blocker Resolution

If Agent 2 gets blocked waiting for Agent 1:

**Option A: Provide Workaround (Recommended)**
```
Task 4.1 blocked waiting for Auth module.
Workaround: Use mock auth data for testing.

File: lib/features/library/test/mocks/auth_mock.dart

Agent 2 continues with mocked auth
→ Agent 1 finishes real auth
→ Agent 2 swaps in real auth (1-2 min change)
```

**Option B: Reassign (if workaround not possible)**
```
Agent 2: Switch to Phase 3 Task 3.4 (independent)
Later: Return to Phase 4 when Agent 1 unblocks
```

**Option C: Pair (if critical path)**
```
Agent 1 + Agent 2 pair on core auth module
Accelerates completion
Then split for UI implementation
```

### 📊 Coordination Checklist

**Before Launch**
- [ ] All task assignments prepared
- [ ] Dependencies documented
- [ ] Agents reviewed their blocking tasks
- [ ] Supporting files copied to each agent
- [ ] MVP_STATUS.md shared and explained
- [ ] Deadlines communicated

**During Execution**
- [ ] MVP_STATUS.md updated as tasks progress
- [ ] Blockers identified within 1 hour
- [ ] Workarounds provided or reassignment done
- [ ] No agent idle due to unclear requirements

**On Completion**
- [ ] Acceptance criteria verified for each task
- [ ] Integration testing between agent work
- [ ] Knowledge shared (any new patterns)
- [ ] Retrospective on coordination (5 min)

### 🎯 Success Metrics

- **On Time**: All agents finish assigned tasks by deadline
- **Quality**: 0 acceptance criteria missed per task
- **Zero Blockers**: Any blocker resolved within 30 min
- **Integration**: Combined work integrates with 0 build errors
- **Coverage**: 80%+ test coverage across all new code
```

---

## Escalation & Unblocking Template

Use when an agent is blocked or needs help.

```
## 🚨 BLOCKER: [Agent Name] - [Task Title]

### Issue
[Clear description of what's blocked]

### Impact
- Task: [Task #]
- Time Lost: [X minutes]
- Downstream Impact: Blocks [other tasks/agents]
- Timeline Risk: [Potentially miss deadline by X hours]

### Root Cause
[What's preventing progress]

### Solution Option A: Workaround (Recommended)
[Quick fix to unblock work immediately]
Implementation: [1-2 steps]
Time to implement: [X min]
Trade-off: [Any issues with workaround]

### Solution Option B: Escalation
[Ask for help from senior team member]
Effort: [X min pair programming]
Cost: [Pauses other work]

### Solution Option C: Reassignment
Switch to alternative task: [Task Y]
Reason: [Original task dependent on X]
Resume original after: [When dependency available]

### Chosen Resolution
✅ Option [A/B/C]
Actions: [Step by step]
ETA to unblock: [X minutes]
Agent resumes at: [Time]
```

---

## Mid-Sprint Adjustment Template

Use when you need to replan due to progress/blockers.

```
## 📋 Mid-Sprint Adjustment - [Date, Time]

### Original Plan
[Tasks assigned, agents, timeline]

### Actual Progress
- Completed: [Tasks ✅]
- In Progress: [Tasks 🔄]
- Blocked: [Tasks ⚠️]
- Burned Time: [X hours unexpected]

### Analysis
**What Went Well** ✅
- [Achievement]
- [Achievement]

**What Slowed Us** ⚠️
- [Issue] → Solution: [Brief fix]
- [Issue] → Solution: [Brief fix]

**Revised Timeline**
- Original ETA: [Date]
- New ETA: [Date]
- Slip: [+X hours]

### Adjusted Plan (Remaining [X hours])

**Option 1**: Reduce Scope (Ship core, defer nice-to-haves)
- Keep: [Critical tasks]
- Defer: [Nice-to-have tasks]
- Result: MVP in [X hours]

**Option 2**: Add Resources (Bring in additional agent)
- New Agent: [Task assignments]
- Overlap: [Coordination needs]
- Result: MVP in [X hours]

**Option 3**: Increase Parallel Work
- Reassign: [Task from blocked agent to available agent]
- Workarounds: [Unblock waiting tasks with mocks]
- Result: MVP in [X hours]

### Decisions Made
✅ Proceeding with: Option [1/2/3]
📢 Communication: Notify stakeholders of [scope change / timeline update]
🎯 New Deadline: [Revised date/time]

### Updated Agent Assignments
- Agent 1: [Revised tasks]
- Agent 2: [Revised tasks]
- Agent 3: [New assignment / Freed up / Reassigned]
```

---

## Version

- **v1.0** - Management and coordination templates
- **Created**: December 15, 2025
- **Status**: Ready for use
