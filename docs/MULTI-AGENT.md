# Multi-Claude Orchestration

This guide covers advanced patterns for running multiple Claude instances in parallel for complex tasks.

## Why Multi-Agent?

- **Context isolation**: Each agent has a fresh 200k token window
- **Parallel processing**: Multiple tasks simultaneously
- **Specialization**: Different agents for different concerns
- **Reduced conflicts**: Isolated worktrees prevent merge issues

## Pattern 1: Writer + Reviewer

The simplest multi-agent pattern:

```
Worktree 1 (Writer)    Worktree 2 (Reviewer)
     │                       │
     ▼                       ▼
 Write code ──────────► Review code
     │                       │
     ▼                       ▼
 Apply fixes ◄────────── Feedback
```

### Setup

```bash
# Create worktrees
git worktree add .worktrees/feature -b feature main
git worktree add .worktrees/review -b review main

# Terminal 1: Writer
cd .worktrees/feature && claude
# "Implement user authentication"

# Terminal 2: Reviewer (fresh context)
cd .worktrees/review && claude
# "Review the changes in ../feature for security issues"
```

## Pattern 2: Specialized Teams

For large refactors, assign different agents to different areas:

| Agent | Role | Directory |
|-------|------|-----------|
| Agent 1-2 | Component work | `src/components/` |
| Agent 3-4 | Test updates | `tests/` |
| Agent 5 | Documentation | `docs/` |
| Agent 6 | Benchmarks | `benchmarks/` |

### Setup

```bash
# Create worktrees for each specialty
git worktree add .worktrees/components -b refactor-components main
git worktree add .worktrees/tests -b refactor-tests main
git worktree add .worktrees/docs -b refactor-docs main

# Run agents in parallel
cd .worktrees/components && claude &
cd .worktrees/tests && claude &
cd .worktrees/docs && claude &
```

## Pattern 3: Parallel Subagent Research

Use Claude's built-in Task tool for parallel exploration:

```
"Explore the codebase using 4 tasks in parallel:
- Agent 1: Explore src/components/ for React patterns
- Agent 2: Explore src/services/ for API patterns
- Agent 3: Explore tests/ for test patterns
- Agent 4: Explore docs/ for documentation gaps"
```

### Limits

- **Default cap**: 10 concurrent subagents
- **Context per agent**: Isolated 200k window
- **Overflow handling**: Additional tasks queue automatically

## Git Worktree Commands

### Create Worktrees

```bash
# Create worktree with new branch
git worktree add <path> -b <branch> <start-point>

# Examples
git worktree add .worktrees/feature-a -b feature-a main
git worktree add .worktrees/hotfix -b hotfix main
git worktree add ../project-experiment -b experiment main
```

### Manage Worktrees

```bash
# List all worktrees
git worktree list

# Remove worktree
git worktree remove <path>

# Prune stale worktree info
git worktree prune
```

### Best Practices

```bash
# Use .worktrees/ directory (gitignored)
mkdir -p .worktrees
echo ".worktrees/" >> .gitignore

# Name worktrees by purpose
git worktree add .worktrees/auth -b feature-auth main
git worktree add .worktrees/perf -b feature-perf main
```

## Conflict Mitigation Strategies

### 1. Directory Partitioning

Assign each agent exclusive ownership:

```
Agent A: src/components/**
Agent B: src/services/**
Agent C: tests/**
```

### 2. Communication Ledger

Use a shared progress file:

```bash
# Create shared ledger
touch PROGRESS.md

# Each agent reads/writes status
"Check PROGRESS.md before starting. Update when done."
```

### 3. Commit Messages

Agents can read each other's commits:

```bash
# Agent reads recent commits
git log --oneline -20

# Clear commit messages enable coordination
"feat(auth): implement login endpoint - Agent A"
"test(auth): add login endpoint tests - Agent B"
```

### 4. Sequential Dependencies

Some tasks must wait for others:

```
Components ──► Tests ──► Docs
   (1)          (2)       (3)
```

## Decision Guide

### Use Parallel Agents When

- Tasks are independent (no shared files)
- Each task takes >30 minutes
- Fresh context would help (complex codebase)
- Multiple specialties needed

### Use Sequential Execution When

- Tasks depend on each other
- High risk of conflicts
- Context continuity matters
- Simple, quick tasks

## Example: Full Refactor Workflow

```bash
#!/bin/bash
# Multi-agent refactor script

# Setup
mkdir -p .worktrees
git worktree add .worktrees/components -b refactor-components main
git worktree add .worktrees/tests -b refactor-tests main

# Phase 1: Components (parallel)
(cd .worktrees/components && claude -p "Refactor all class components to hooks") &

# Phase 2: Tests (waits for phase 1)
wait
(cd .worktrees/tests && claude -p "Update tests for refactored components") &

# Phase 3: Merge
wait
git checkout main
git merge refactor-components --no-edit
git merge refactor-tests --no-edit

# Cleanup
git worktree remove .worktrees/components
git worktree remove .worktrees/tests
git branch -d refactor-components refactor-tests
```

## Monitoring Parallel Agents

### Using tmux

```bash
# Create session with panes
tmux new-session -d -s agents
tmux split-window -h
tmux split-window -v
tmux select-pane -t 0
tmux split-window -v

# Run agents in each pane
tmux send-keys -t 0 "cd .worktrees/a && claude" C-m
tmux send-keys -t 1 "cd .worktrees/b && claude" C-m
tmux send-keys -t 2 "cd .worktrees/c && claude" C-m
tmux send-keys -t 3 "cd .worktrees/d && claude" C-m

# Attach to watch
tmux attach -t agents
```

### Using Background Jobs

```bash
# Start agents in background
claude -p "Task A" > agent-a.log 2>&1 &
claude -p "Task B" > agent-b.log 2>&1 &

# Monitor logs
tail -f agent-*.log

# Wait for completion
wait
```

## Cost Considerations

- Each parallel agent uses separate API calls
- Thinking tokens multiply with agents
- Use `--max-turns` to limit runaway costs
- Consider sequential for simple tasks

## Troubleshooting

### Merge Conflicts

```bash
# Use --no-commit to review before finalizing
git merge branch-a --no-commit

# Or use merge tool
git mergetool
```

### Lost Progress

```bash
# Check worktree status
git worktree list

# Recover from branch
git log branch-name
git cherry-pick <commit>
```

### Resource Exhaustion

```bash
# Limit concurrent agents
MAX_AGENTS=4
for task in tasks/*; do
  while [ $(jobs -r | wc -l) -ge $MAX_AGENTS ]; do
    sleep 5
  done
  claude -p "Process $task" &
done
wait
```
