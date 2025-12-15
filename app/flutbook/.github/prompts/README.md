# Flutbook MVP - Agent Prompt Templates

A collection of reusable prompt templates for managing agent-driven development on the Flutbook MVP project. These templates ensure clear communication, reduce ambiguity, and accelerate task completion.

---

## 📚 Template Overview

### 1. **agent-task-assignment.md** - Complete Task Assignment
**For**: Managers assigning detailed tasks to individual agents
**Length**: Comprehensive (1000+ words)
**Use When**:
- Assigning a specific, well-defined task
- First time assigning to a new agent
- Task needs detailed context and code examples
- You want crystal-clear acceptance criteria

**Key Sections**:
- Task overview and context
- Detailed requirements & acceptance criteria
- Architecture pattern guidance
- Code examples
- Supporting files needed
- Complete workflow steps
- Completion checklist

**Time to Create**: 20-30 minutes per task
**Time for Agent to Read**: 20-25 minutes

---

### 2. **quick-task-template.md** - Fast Task Assignment
**For**: Managers with less time, or for smaller/simpler tasks
**Length**: Concise (200-400 words)
**Use When**:
- Task is straightforward (1-3 hours)
- Agent is familiar with the codebase
- You need to assign quickly
- Repeating similar tasks

**Key Sections**:
- One-page task summary
- Acceptance criteria checklist
- Architectural reference
- 1-2 code examples
- Quick start workflow
- 3 worked examples

**Time to Create**: 5-10 minutes per task
**Time for Agent to Read**: 5-7 minutes

---

### 3. **manager-coordination.md** - Team Management
**For**: Managers coordinating multiple agents
**Length**: Strategic (1500+ words)
**Use When**:
- Running multiple agents in parallel
- Tasks have interdependencies
- You need to manage blockers
- Planning multi-day work

**Key Templates Included**:
- Daily team briefing
- Parallel execution coordination
- Task dependency matrix
- Blocker resolution options
- Mid-sprint adjustment planning
- Escalation procedures

**Use Cases**:
- Managing 1-10 agents on MVP completion
- Coordinating across phases
- Handling blockers efficiently
- Replanning when progress differs from estimate

---

## 🎯 Quick Decision Tree

### Choose Your Template

```
"I'm assigning a task to an agent"
  ├─ "Is this quick/simple? (<3 hours)"
  │  └─ Use: quick-task-template.md
  └─ "Is this complex? (3+ hours)"
     └─ Use: agent-task-assignment.md

"I'm managing multiple agents"
  ├─ "Daily briefing/status?"
  │  └─ Use: manager-coordination.md (Daily Briefing)
  ├─ "Parallel execution planning?"
  │  └─ Use: manager-coordination.md (Parallel Executor)
  └─ "Team is blocked/off-track?"
     └─ Use: manager-coordination.md (Escalation/Adjustment)
```

---

## 📖 How to Use These Templates

### For Managers

#### Assigning a Task (5 min)
1. **Pick a template**:
   - Is task < 3 hours? → Use quick-task-template.md
   - Is task 3+ hours? → Use agent-task-assignment.md

2. **Customize** (5 minutes):
   - Replace all [bracketed] placeholders
   - Add specific code examples
   - Include actual file paths

3. **Attach supporting files**:
   - Always: START_HERE.md, AGENT_INSTRUCTIONS.md
   - Phase-specific: Documentation for the phase
   - Examples: Link to similar completed features

4. **Send & track**:
   - Agent updates MVP_STATUS.md when done
   - You verify acceptance criteria
   - Mark task complete in MVP_STATUS.md

#### Managing Team (10 min daily)
1. **Morning**: Check CURRENT_PROGRESS.txt (2 min)
2. **During day**: Monitor MVP_STATUS.md for updates (3 min)
3. **Assign next**: Use appropriate template (5 min)
4. **EOD**: Verify completions, update status (5 min)

#### Parallel Execution Planning (30 min once)
1. Open: manager-coordination.md
2. Find: "Parallel Execution Coordinator Template"
3. Fill in your task dependency matrix
4. Assign agents based on dependency order
5. Check in daily with blocker resolution section

### For Agents

#### Starting a Task (50 min)
1. **Read instructions** (20 min):
   - START_HERE.md
   - AGENT_INSTRUCTIONS.md (code standards section)
   - Your task assignment

2. **Plan** (15 min):
   - Review code examples in task
   - Check referenced existing features
   - Outline what you'll create/modify

3. **Implement** (2-4+ hours):
   - Follow patterns from examples
   - Test as you go
   - Check off acceptance criteria

4. **Complete** (10 min):
   - Verify all acceptance criteria
   - Update MVP_STATUS.md
   - Commit with message: "Complete: Task [#] - [Title]"

---

## 📋 Template Checklist

### Before Sending a Task Assignment

- [ ] Task is specific (no vague language)
- [ ] Time estimate is realistic
- [ ] Acceptance criteria are testable (can be verified)
- [ ] Code example(s) provided (shows pattern to follow)
- [ ] Related existing code referenced
- [ ] Supporting files listed
- [ ] Clear deadline given (date + time)
- [ ] Priority level set (CRITICAL/HIGH/MEDIUM/LOW)

### Template Quality Gates

**Good Task Assignment** ✅
- "Implement login screen with email/password validation, Firebase auth, error handling"
- Acceptance criteria: testable, specific, measurable
- Code example shows exact pattern to use
- Agent can start immediately without questions

**Bad Task Assignment** ❌
- "Make authentication work"
- Acceptance criteria: vague or untestable
- No code examples or references
- Agent needs to ask clarifying questions

---

## 🔗 Related Documentation

**For Task Planning**:
- [MVP_STATUS.md](../../documentation/MVP_STATUS.md) - All tasks with estimates and dependencies
- [TASK_CARDS.md](../../documentation/TASK_CARDS.md) - Printable task cards with details

**For Code Standards**:
- [AGENT_INSTRUCTIONS.md](../../documentation/AGENT_INSTRUCTIONS.md) - Code patterns, testing, architecture
- [IMPLEMENTATION_SUMMARY.md](../../documentation/IMPLEMENTATION_SUMMARY.md) - Architecture overview

**For Onboarding**:
- [START_HERE.md](../../documentation/START_HERE.md) - Quick start for new team members
- [DOCUMENTATION_INDEX.md](../../documentation/DOCUMENTATION_INDEX.md) - All docs with FAQ

---

## 📊 Task Sizing Guide

Use this to estimate which template and how much detail you need:

| Task Scope | Time | Agents | Template | Detail |
|-----------|------|--------|----------|--------|
| Single widget | 1-2 hrs | 1 | Quick | Low |
| Simple provider | 2-3 hrs | 1 | Quick | Low |
| Complete feature (1 layer) | 2-4 hrs | 1 | Complete | Med |
| Full feature (all layers) | 4-8 hrs | 1 | Complete | High |
| Multi-day work | 8+ hrs | 2+ | Coordinator | High |
| Parallel phases | 3-5 days | 3+ | Coordinator | High |

---

## 🚀 Example Workflows

### Workflow 1: Single Agent, Single Task (1 hour setup)
```
1. Read quick-task-template.md (5 min)
2. Fill in placeholders for Task 2.1 (5 min)
3. Send to agent with 2 supporting files (1 min)
4. Agent completes task in 3 hours (async)
5. You verify & mark complete (5 min)
Total: 21 minutes of your time + 3 hours agent time
```

### Workflow 2: Two Agents in Series (30 min setup)
```
1. Read manager-coordination.md - Parallel Executor (10 min)
2. Identify blocker: Task A must finish before B (5 min)
3. Assign Agent 1: Task A (quick template) (5 min)
4. Prepare Agent 2: Task B (ready to send) (5 min)
5. Send Agent 1, tell Agent 2 "starting when Agent 1 done"
6. Agent 1 finishes → immediately launch Agent 2
7. Monitor in MVP_STATUS.md (5 min daily)
Total: 30 minutes of your time + 6 hours agent time
```

### Workflow 3: Three Agents in Parallel (1 hour setup)
```
1. Read manager-coordination.md - Daily Briefing (15 min)
2. Read Parallel Executor section (15 min)
3. Create dependency matrix for your 3 agents (15 min)
4. Prepare 3 task assignments (10 min each = 30 min)
5. Send all + blocker resolution guide (5 min)
6. Monitor daily with coordination checklist (5 min/day)
7. Adjust with manager-coordination.md if needed
Total: 1 hour setup + 5 min daily monitoring
```

---

## 💡 Pro Tips

### For Quick Turnaround
- Use quick-task-template.md for 1-3 hour tasks
- Reuse the same template structure; only customize content
- Create a template for your most-common task type

### For Parallel Execution
- Use manager-coordination.md to identify dependencies first
- Give "waiting" agents a workaround (mock data) to continue
- Have next task ready to send immediately when blocker clears

### For Team Scaling
- 1 agent: 1 task/day assignments (15 min overhead)
- 2-3 agents: Daily briefing + coordinate dependencies (30 min)
- 4+ agents: Full coordination template + sprint planning (1 hour)

### For Consistency
- Keep a completed task assignment as a template
- Reuse structure for similar tasks
- Standard format reduces agent questions

---

## 🔄 Template Evolution

These templates are designed to be reusable across projects. As you use them:

- **Customize**: Adapt for your project's specific needs
- **Save**: Keep completed assignments as examples
- **Iterate**: Refine based on feedback
- **Share**: Use with your team

---

## 📞 Support

### Common Questions

**Q: How detailed should code examples be?**
A: 2-3 snippets showing the key pattern. If your example is >10 lines, you're probably too detailed. Agent should understand the pattern, not copy-paste.

**Q: What if task estimate is wrong?**
A: Use manager-coordination.md mid-sprint adjustment template. Identify the issue, adjust scope/timeline, communicate to agent.

**Q: Can I use both templates?**
A: Yes! Quick template for simple tasks, complete template for complex. Mix and match based on your needs.

**Q: What's the minimum info needed?**
A: Task title + what to build + 2-3 acceptance criteria + code example + deadline. Anything less risks confusion.

---

## 📦 File Manifest

```
.github/prompts/
├── agent-task-assignment.md       (Complete task template - 1000+ words)
├── quick-task-template.md         (Quick assignment - 300-400 words)
├── manager-coordination.md        (Team management - 1500+ words)
└── README.md                      (This file)
```

---

## Version & Updates

- **v1.0** - Initial release with 3 templates
- **Created**: December 15, 2025
- **Tested**: Yes, with example workflows
- **Status**: Ready for immediate use

---

## Quick Links

- **Templates**: See files in this directory
- **Task Board**: [MVP_STATUS.md](../../documentation/MVP_STATUS.md)
- **Agent Handbook**: [AGENT_INSTRUCTIONS.md](../../documentation/AGENT_INSTRUCTIONS.md)
- **Onboarding**: [START_HERE.md](../../documentation/START_HERE.md)
- **All Docs**: [DOCUMENTATION_INDEX.md](../../documentation/DOCUMENTATION_INDEX.md)

---

**Start here**: Pick a template above and customize for your first task. Should take 5-20 minutes to send. Agent reads in 20-25 minutes, codes for 2-4 hours. Done! 🚀
