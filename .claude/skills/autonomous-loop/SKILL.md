---
name: autonomous-loop
description: Autonomous development loop patterns for iterative self-improvement. Auto-triggers when implementing features autonomously, fixing bugs in a loop, or running until completion.
---

# Autonomous Development Loop

Based on Geoffrey Huntley's Ralph technique for Claude Code.

## Core Principle: Dual-Condition Exit Gate

**Never exit prematurely.** Require BOTH conditions:

1. Multiple completion indicators (tests pass, tasks complete, no errors)
2. Explicit `EXIT_SIGNAL: true` in your status report

This prevents exiting during productive work phases.

## Circuit Breaker Pattern

Halt execution when detecting stagnation:

| Condition         | Threshold     | Action                |
| ----------------- | ------------- | --------------------- |
| No progress loops | 3 consecutive | Stop and report       |
| Repeated errors   | 5 identical   | Stop and analyze      |
| Test-only loops   | 3 consecutive | Stop - likely blocked |
| Output decline    | >70% drop     | Review and adjust     |

## Structured Status Reporting

**Every response MUST end with this status block:**

```
## Status Report

STATUS: IN_PROGRESS | COMPLETE | BLOCKED
LOOP: [current]/[max expected]
EXIT_SIGNAL: false | true
TASKS_COMPLETED_THIS_LOOP: [list]
FILES_MODIFIED: [list]
TESTS_STATUS: [pass/fail count]
ERRORS_THIS_LOOP: [count]
WORK_TYPE: implementation | testing | documentation | debugging
RECOMMENDATION: [one-line next step]
```

## Exit Signal Rules

Set `EXIT_SIGNAL: true` ONLY when ALL conditions are met:

1. All planned tasks marked complete
2. All tests passing
3. No errors in execution
4. All requirements implemented
5. Nothing meaningful remains to do

**If ANY condition is false, EXIT_SIGNAL MUST be false.**

## Work Focus Hierarchy

Prioritize work in this order:

1. **Implementation** - Core feature code
2. **Testing** - ~20% of loop effort
3. **Documentation** - Only when needed
4. **Cleanup** - Refactoring, polish

## Progress Indicators

Track these signals to detect completion:

```
- "all tests pass" / "tests green"
- "feature complete" / "implementation done"
- "no remaining tasks" / "fix plan empty"
- "ready for review" / "ready to merge"
```

**Two or more indicators + explicit confirmation = potential exit**

## Loop State Management

### CLOSED (Normal)

- Continue executing loops
- Track progress metrics
- Monitor for stagnation

### HALF_OPEN (Warning)

- One more chance after detecting issues
- Increased scrutiny on progress
- Report concerns in status

### OPEN (Halted)

- Stop autonomous execution
- Provide diagnostic summary
- Request human intervention

## Anti-Patterns to Avoid

- **Premature exit**: Stopping when tests pass but tasks remain
- **Infinite loops**: Not detecting repeated failures
- **Busy work**: Testing without implementing
- **Silent failures**: Not reporting errors clearly
- **Scope creep**: Adding unplanned work

## Integration with Fix Plan

Maintain a `@fix_plan.md` file tracking:

- [ ] High priority items first
- [ ] Medium priority items
- [ ] Lower priority items

Mark items complete as you work. Empty fix plan + passing tests = ready to exit.

## Example Loop Execution

```
Loop 1: Implement core feature
  -> Modified 3 files, tests fail (2/5 pass)
  -> STATUS: IN_PROGRESS, EXIT_SIGNAL: false

Loop 2: Fix failing tests
  -> Fixed 2 issues, tests fail (4/5 pass)
  -> STATUS: IN_PROGRESS, EXIT_SIGNAL: false

Loop 3: Fix last test, add edge cases
  -> All tests pass (5/5)
  -> STATUS: IN_PROGRESS, EXIT_SIGNAL: false (tasks remain)

Loop 4: Complete remaining tasks
  -> All tasks done, tests pass
  -> STATUS: COMPLETE, EXIT_SIGNAL: true
```

## Recovery from BLOCKED State

1. Report what's blocking progress
2. List attempted solutions
3. Suggest alternatives or request input
4. Wait for human direction

**Never infinite loop on a blocker.**
