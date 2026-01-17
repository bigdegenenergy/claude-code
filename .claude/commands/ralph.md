---
description: Autonomous development loop. Iteratively improves until completion with built-in safeguards.
model: claude-opus-4-5-20251101
allowed-tools: Bash(*), Read(*), Edit(*), Write(*), Grep(*), Glob(*), Task(*)
---

# Ralph: Autonomous Development Mode

You are entering **autonomous development mode** based on Geoffrey Huntley's Ralph technique.

## Your Mission

Iteratively develop until ALL tasks are complete with ALL tests passing.

## Context

- **Git Status:** !`git status -sb`
- **Recent Changes:** !`git log --oneline -5 2>/dev/null || echo "No commits yet"`
- **Fix Plan:** !`cat @fix_plan.md 2>/dev/null || echo "No @fix_plan.md found - create one if needed"`
- **Test Status:** !`npm test 2>&1 | tail -5 || pytest --tb=no -q 2>&1 | tail -5 || echo "Run tests to discover status"`

## Autonomous Loop Protocol

### 1. Read Instructions

Check for project-specific guidance:

- `PROMPT.md` - Development instructions
- `@fix_plan.md` - Prioritized task list
- `@AGENT.md` - Build/run specifications

### 2. Execute ONE Task Per Loop

Focus on a single task each iteration:

1. Pick the highest priority incomplete task
2. Implement the solution
3. Run relevant tests
4. Update the fix plan

### 3. Circuit Breaker Rules

**HALT if any of these occur:**

- 3 consecutive loops with no progress
- 5 consecutive loops with the same error
- 3 consecutive test-only loops (no implementation)
- You encounter a true blocker requiring human input

### 4. Status Report (REQUIRED)

**End EVERY response with this block:**

```
## Status Report

STATUS: IN_PROGRESS | COMPLETE | BLOCKED
LOOP: [N]
EXIT_SIGNAL: false | true
TASKS_COMPLETED: [what you finished]
FILES_MODIFIED: [list of changed files]
TESTS: [X/Y passing]
ERRORS: [count or "none"]
NEXT: [what comes next or "done"]
```

## Exit Signal Rules

Set `EXIT_SIGNAL: true` ONLY when ALL are true:

1. All `@fix_plan.md` items are marked complete (or no fix plan exists and task is done)
2. All tests are passing
3. No execution errors
4. All requirements implemented
5. Nothing meaningful remains

**One false = EXIT_SIGNAL: false. Keep going.**

## Work Priorities

1. **Implementation** - Write the actual code
2. **Tests** - ~20% of effort per loop
3. **Documentation** - Only when explicitly needed
4. **Cleanup** - After core work is done

## Important Rules

- **Search before assuming** - Check if something exists before creating it
- **Minimal changes** - Smallest fix that solves the problem
- **Track everything** - Update @fix_plan.md as you work
- **Be honest** - Report blockers clearly, don't spin wheels
- **One task focus** - Complete one thing before starting another

## Recovery Protocol

If BLOCKED:

1. Clearly state what's blocking you
2. List what you've tried
3. Suggest alternatives
4. Set `STATUS: BLOCKED` and wait for input

## Example Session

```
Loop 1:
- Task: Implement user authentication
- Modified: src/auth.ts, src/middleware.ts
- Tests: 3/5 passing
- Status: IN_PROGRESS, EXIT_SIGNAL: false
- Next: Fix remaining 2 test failures

Loop 2:
- Task: Fix auth test failures
- Modified: src/auth.ts
- Tests: 5/5 passing
- Status: IN_PROGRESS, EXIT_SIGNAL: false
- Next: Implement session management (next in fix plan)

Loop 3:
- Task: Implement session management
- Modified: src/session.ts, src/config.ts
- Tests: 7/7 passing
- Fix plan complete
- Status: COMPLETE, EXIT_SIGNAL: true
- Next: Done - ready for review
```

## Begin

1. Check for `@fix_plan.md` or create one from the task
2. Start with the highest priority item
3. Execute, test, report
4. Loop until EXIT_SIGNAL: true or BLOCKED

**Go.**
