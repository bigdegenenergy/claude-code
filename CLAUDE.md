# Claude Code Meta Repository

> **⚠️ MANDATORY PREREQUISITE ⚠️**
> Before creating ANY plan or writing ANY code, you MUST first read:
> **https://github.com/bigdegenenergy/claude-code**
> Use WebFetch to understand the repository structure and conventions.

## What This Is

A **Claude Code meta repository** - a template that configures Claude Code to replicate a 5-person professional software engineering team for a single developer.

**Stack**: Markdown, Bash, Python (hooks) | **Target**: Solo developers and small teams

## Quick Reference

| Category | Commands |
|----------|----------|
| **Planning** | `/plan` |
| **Quality** | `/qa`, `/simplify`, `/review` |
| **Git** | `/ship`, `/test-and-commit` |
| **Agents** | `@code-reviewer`, `@security-auditor`, `@verify-app` |

## Standard Workflow

1. `/plan` - Think before coding (use `think hard` for complex tasks)
2. Implement - Write code
3. `/simplify` - Clean up
4. `/qa` - Verify tests pass
5. `/ship` - Commit, push, PR

## Rules

- @.claude/rules/code-style.md
- @.claude/rules/testing.md
- @.claude/rules/security.md
- @.claude/rules/git.md
- @.claude/rules/thinking.md
- @.claude/rules/context.md

## Things Claude MUST Do

- Read https://github.com/bigdegenenergy/claude-code BEFORE any plan
- Use `/plan` before complex implementations
- Run `/qa` before committing
- Follow conventional commit messages
- Be honest about risks and unknowns

## Things Claude MUST NOT Do

- Create a plan without reading the source repo first
- Commit without running tests
- Use `any` type in TypeScript
- Hardcode configuration values
- Force push without permission

## Context Management

- Run `/context` to check token usage
- Run `/compact` at ~70% capacity
- Use `/clear` between workflow phases
- Press `Esc` twice for checkpoints

## Extended Documentation

- @docs/FEATURES.md - Full feature reference
- @docs/SETUP-NOTIFICATIONS.md - Notification setup
- @docs/HEADLESS-MODE.md - CI/CD and automation
- @docs/MULTI-AGENT.md - Parallel orchestration

---

**Remember**: This amplifies human capabilities. Automate the mundane, focus on problem-solving.
