# Claude Code Meta Repository

This is a **Claude Code meta repository** - a template that configures Claude Code to replicate a 5-person professional software engineering team for a single developer.

## Project Overview

**Purpose:** Provide a universal, production-ready Claude Code configuration that amplifies a solo developer's capabilities through automated workflows, specialized subagents, and quality gates.

**Architecture:** Configuration-as-code approach using Claude Code's native features (slash commands, hooks, subagents).

## The Virtual Team

| Role | Implementation | When to Use |
|------|----------------|-------------|
| **Architect** | `/plan` | Before implementing complex features |
| **QA Engineer** | `/qa` | When tests fail or need verification |
| **Refactorer** | `/simplify` | After implementing features |
| **DevOps** | `/ship` | When ready to commit and PR |
| **Code Reviewer** | `@code-reviewer` | Before submitting PRs |
| **Code Janitor** | PostToolUse Hook | Automatic after every edit |

## Workflow

### Standard Development Flow

1. **Plan First**: Start with `/plan` for complex features
2. **Implement**: Write code in auto-accept mode
3. **Simplify**: Run `/simplify` to clean up
4. **Verify**: Use `/qa` to ensure tests pass
5. **Review**: Invoke `@code-reviewer` for self-review
6. **Ship**: Use `/ship` to commit, push, and PR

### Quick Reference

```bash
# Planning
/plan                    # Think before coding

# Quality
/qa                      # Run tests, fix until green
/simplify                # Clean up code

# Git Operations
/ship                    # Commit, push, create PR
/git:commit-push-pr      # Alternative git workflow

# Agents (invoke with @)
@code-reviewer           # Critical code review
@code-simplifier         # Improve readability
@verify-app              # End-to-end testing
```

## Things Claude Should NOT Do

- Skip the planning phase for complex features
- Commit without running tests
- Use `any` type in TypeScript
- Hardcode configuration values
- Leave commented-out code
- Force push without permission

## Things Claude SHOULD Do

- Use `/plan` before complex implementations
- Run `/qa` before committing
- Use `/simplify` to pay down tech debt
- Follow conventional commit messages
- Update documentation when changing behavior
- Be honest about risks and unknowns

## Tech Stack (This Repo)

- **Language:** Markdown, Bash, Python (for hooks)
- **Framework:** Claude Code native features
- **Target Users:** Solo developers and small teams

## Known Patterns

### Pre-compute Context
Use inline bash in slash commands for real-time data:
```markdown
- **Git Status:** !`git status -sb`
```

### Iterative Loops
QA commands should loop until green:
```markdown
1. Run tests
2. If fail: analyze, fix, goto 1
3. If pass: report and exit
```

### Critical Subagents
Use "be critical" and "be honest" in prompts:
```markdown
**Be critical, not agreeable.** Find problems.
```

## Update Log

Track improvements to this configuration:

- **2025-01-03**: Initial virtual team setup with `/plan`, `/qa`, `/simplify`, `/ship`
- **2025-01-03**: Added format.py hook for robust auto-formatting
- **2025-01-03**: Created universal setup script (setup-claude-team.sh)

---

**Remember:** This configuration amplifies human capabilities. Use it to automate the mundane and focus on creative problem-solving.
