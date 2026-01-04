# Claude Code Features Reference

This document contains detailed documentation for all Claude Code features in this repository.

## The Virtual Team

### Commands (Slash)

| Role | Command | When to Use |
|------|---------|-------------|
| **Architect** | `/plan` | Before implementing complex features |
| **QA Engineer** | `/qa` | When tests fail or need verification |
| **TDD** | `/test-driven` | Red-green-refactor development |
| **Gatekeeper** | `/test-and-commit` | Only commit if tests pass |
| **Reviewer** | `/review` | Critical code review (read-only) |
| **Refactorer** | `/simplify` | After implementing features |
| **DevOps** | `/ship` | When ready to commit and PR |
| **Deploy** | `/deploy-staging` | Build and deploy to staging |

### Agents (Subagents)

| Role | Agent | Specialty |
|------|-------|-----------|
| **Code Reviewer** | `@code-reviewer` | Critical code review |
| **QA** | `@verify-app` | End-to-end testing |
| **Security** | `@security-auditor` | Vulnerability scanning (read-only) |
| **Frontend** | `@frontend-specialist` | React, TS, accessibility |
| **Infrastructure** | `@infrastructure-engineer` | Docker, K8s, CI/CD |
| **Cleanup** | `@code-simplifier` | Code hygiene |

### Hooks (Automatic)

| Hook | Type | Function |
|------|------|----------|
| **Safety Net** | PreToolUse | Blocks dangerous commands |
| **Pre-Commit** | PreToolUse | Runs linters & checks formatting before `git commit` |
| **Formatter** | PostToolUse | Auto-formats code after edits |
| **Quality Gate** | Stop | Runs tests at end of turn |

## Thinking Triggers (CLI Only)

Use thinking triggers to allocate more reasoning budget:

| Trigger | Budget | When to Use |
|---------|--------|-------------|
| `think` | ~4k tokens | Simple fixes, refactoring, error handling |
| `think hard` / `megathink` | ~10k tokens | Multi-step algorithms, caching strategy, API design |
| `think harder` / `ultrathink` | ~32k tokens | Major architecture, comprehensive security audit |

**Key facts:**
- Case-insensitive and position-flexible
- CLI-only (not claude.ai web or direct API)
- 3-8x cost increase for ultrathink

**Verbose mode**: Press `Ctrl+O` to see Claude's reasoning.

For detailed guidance, see @.claude/rules/thinking.md

## Session & Context Management

### Session Commands

| Command | Purpose |
|---------|---------|
| `/rename <name>` | Name session for later retrieval |
| `claude --continue` / `-c` | Continue most recent conversation |
| `claude --resume` / `-r` | Interactive session picker |
| `/context` | View current token usage |
| `/clear` | Full context reset |
| `/compact [instructions]` | Summarize & continue |
| `/cost` | Session cost statistics |

### Checkpoint System

| Action | Effect |
|--------|--------|
| `/rewind` | Open checkpoint interface |
| `Esc` twice | Quick access to checkpoints |
| Code-only restore | Revert files, keep conversation |
| Full restore | Revert both |

**Note**: Bash commands (`rm`, `mv`, `cp`) are NOT tracked by checkpoints.

### Context Hygiene

- Run `/compact` at ~70% capacity (auto-compact triggers at ~95%)
- Run `/context` periodically during long sessions
- Use `/clear` between workflow phases
- Disable unused MCP servers: `/mcp`

### Document & Clear Pattern

For complex multi-phase tasks:
1. Have Claude dump plan/progress to a `.md` file
2. Run `/clear` to reset context
3. Start new session: "Read `plan.md` and continue from step 3"

For detailed guidance, see @.claude/rules/context.md

## MCP Server Integration

MCP (Model Context Protocol) servers extend Claude Code's capabilities.

### Setup
1. Copy `.mcp.json.template` to `.mcp.json`
2. Enable servers you need (remove `"disabled": true`)
3. Add credentials via environment variables
4. Verify with `/mcp` inside Claude

### Available Servers
- **GitHub**: PR/issue management
- **Playwright**: Browser automation (replaces deprecated Puppeteer)
- **Postgres/SQLite**: Database queries
- **Slack**: Team communication
- **Memory**: Persistent knowledge graph
- **Fetch**: Web content retrieval

### CLI Commands
```bash
claude mcp add <name> -- <command>  # Add server
claude mcp list                     # List servers
claude mcp remove <name>            # Remove server
/mcp                                # Check status (inside Claude)
```

## Skills

Skills are auto-discovered domain expertise that activate based on context.

### Available Skills
- **tdd**: Test-driven development workflow
- **code-review**: Thorough code review process
- **security-review**: Security audit checklist

Skills are located in `.claude/skills/<name>/SKILL.md` and activate automatically when relevant tasks are detected.

## Known Patterns

### Pre-compute Context
Use inline bash in slash commands:
```markdown
- **Git Status:** !`git status -sb`
```

### Iterative Loops
QA commands loop until green:
```markdown
1. Run tests
2. If fail: analyze, fix, goto 1
3. If pass: report and exit
```

### Critical Subagents
Use "be critical" in prompts:
```markdown
**Be critical, not agreeable.** Find problems.
```

## The Feedback Loop Principle

> "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." - Boris Cherny

1. **Write code** → PostToolUse hook formats it
2. **Complete task** → Stop hook runs tests
3. **Tests fail** → Claude is notified and fixes
4. **Tests pass** → Task truly complete

### Strict Mode
```bash
export CLAUDE_STRICT_MODE=1
claude
```
In strict mode, Claude cannot complete until tests pass.

## Pre-Commit Hook

The pre-commit hook runs before `git commit`:

**Checks:**
- Linting (ESLint, Ruff, etc.)
- Formatting (Prettier, Black, etc.)
- Security (secrets detection)
- PII scanning

**If blocked:**
```bash
npx eslint --fix <file>      # JS/TS linting
npx prettier --write <file>  # JS/TS formatting
ruff --fix <file>            # Python linting
black <file>                 # Python formatting
```

## PII Protection

Multiple layers prevent PII exposure:

1. **Pre-commit**: Blocks commits with PII
2. **CI/CD**: `security.yml` scans on push
3. **Issue/PR scan**: `pii-scan-content.yml` checks content

| Pattern | Action |
|---------|--------|
| Email/Phone/SSN | Blocks commit |
| Credit cards | Blocks commit |
| IP addresses | Blocks commit |
| AWS Account IDs | Blocks commit |

## GitHub Actions

| Workflow | Purpose |
|----------|---------|
| `ci.yml` | Linting, config validation |
| `security.yml` | Secret scanning, PII detection |
| `pii-scan-content.yml` | Scans issues/PRs |
| `gemini-pr-review.yml` | AI code review |
| `notify-on-failure.yml` | Failure notifications |

## Notifications

Configure failure alerts in `.claude/notifications.json`:
- Slack, Discord, Telegram
- Email (SMTP)
- ntfy, Custom webhook

See [SETUP-NOTIFICATIONS.md](SETUP-NOTIFICATIONS.md) for details.
