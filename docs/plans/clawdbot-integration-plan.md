# Clawdbot Features Integration Plan

> Implementation plan for integrating key Clawdbot capabilities into ai-dev-toolkit.
> Created: 2026-01-25

## Executive Summary

This plan details how to integrate 5 key Clawdbot features into the ai-dev-toolkit repository. The features range from medium complexity (skills) to high complexity (workflow engine, browser automation). Each feature leverages existing patterns while introducing new capabilities.

## Implementation Priority & Timeline

| Priority | Feature                | Complexity | Estimated Days | Dependencies       |
| -------- | ---------------------- | ---------- | -------------- | ------------------ |
| 1        | Specialized Dev Skills | Low-Medium | 3 days         | None               |
| 2        | Zeno (Code Analysis)   | Medium     | 2.5 days       | None               |
| 3        | Headless Browser       | High       | 3-4 days       | Chrome, MCP        |
| 4        | Gateway (ChatOps)      | High       | 5 days         | Platform apps      |
| 5        | Lobster (Workflow)     | High       | 5-7 days       | None (pure Python) |

---

## Feature 1: Lobster (Workflow Engine)

### Overview

A typed workflow runtime with approval gates for deterministic, multi-step pipelines that can pause for human approval.

### Complexity Assessment

**HIGH** - Requires new runtime infrastructure, state management, and approval flow integration.

### Architecture Analysis

The ai-dev-toolkit already has workflow patterns via:

- `/feature-workflow` command with manual agent orchestration
- `/ralph` for autonomous loops with exit gates
- GitHub Actions for CI/CD workflows

Lobster would add **programmatic, typed workflow definitions** with explicit approval gates, which is a step beyond the current prompt-based orchestration.

### File Structure

```
.claude/
  workflows/                           # NEW: Workflow definitions
    lobster/
      engine.py                        # Core workflow engine
      types.py                         # TypedDict/Pydantic workflow schemas
      state.py                         # Workflow state persistence
      gates.py                         # Approval gate implementations
    definitions/                       # User-defined workflows
      feature-pipeline.yaml            # Example: full feature workflow
      security-audit.yaml              # Example: security workflow
      deploy-pipeline.yaml             # Example: deployment workflow
  commands/
    workflow.md                        # NEW: /workflow command
    workflow-status.md                 # NEW: /workflow-status command
    workflow-approve.md                # NEW: /workflow-approve command
  hooks/
    workflow-state-hook.py             # NEW: PreToolUse hook to check workflow state
  skills/
    workflow-orchestration/            # NEW: Skill for workflow patterns
      SKILL.md
```

### Implementation Steps

**Phase 1: Core Engine (2-3 days)**

1. Create `workflows/lobster/types.py` with workflow schema definitions:
   - `WorkflowStep`: name, agent/command, inputs, outputs, timeout
   - `ApprovalGate`: condition, approvers, timeout, fallback
   - `WorkflowDefinition`: steps[], gates[], on_failure

2. Create `workflows/lobster/engine.py`:
   - Parse YAML workflow definitions
   - Execute steps sequentially with state tracking
   - Invoke subagents/commands as steps
   - Handle step failures and retries

3. Create `workflows/lobster/state.py`:
   - Persist workflow state to `.claude/artifacts/workflow-state/`
   - Track: current_step, step_results, approvals, timestamps

**Phase 2: Approval Gates (1-2 days)** 4. Create `workflows/lobster/gates.py`:

- `ManualApprovalGate`: Pause and wait for user input
- `TimeoutGate`: Auto-approve after duration
- `ConditionalGate`: Approve based on step outputs
- Integration with existing notification system (`notify.py`)

**Phase 3: Commands & Integration (1-2 days)** 5. Create `/workflow` command to start workflows 6. Create `/workflow-status` command to check progress 7. Create `/workflow-approve` command to approve pending gates 8. Add skill for workflow orchestration patterns

### Integration Points

| Existing Component                  | Integration                                      |
| ----------------------------------- | ------------------------------------------------ |
| `notify.py`                         | Send approval requests to Slack/Discord/Telegram |
| `settings.json`                     | Add workflow-related hooks                       |
| `@code-reviewer`, `@test-automator` | Invoke as workflow steps                         |
| `/qa`, `/ship`                      | Can be workflow step targets                     |

### External Dependencies

| Dependency | Purpose                    | Required                     |
| ---------- | -------------------------- | ---------------------------- |
| `pydantic` | Schema validation          | Optional (can use TypedDict) |
| `pyyaml`   | Parse workflow definitions | Yes (already used in hooks)  |
| None       | Pure Python implementation | Core engine                  |

### Example Workflow Definition

```yaml
# .claude/workflows/definitions/feature-pipeline.yaml
name: feature-pipeline
description: Full feature implementation with quality gates

steps:
  - name: plan
    command: /plan
    inputs:
      description: "{{ feature_description }}"

  - name: implement
    agent: "@typescript-pro"
    inputs:
      task: "Implement the plan"

  - name: test
    command: /qa
    gate:
      type: manual
      message: "Tests passing. Review implementation before proceeding?"

  - name: review
    agent: "@code-reviewer"
    gate:
      type: conditional
      condition: "findings.critical == 0"
      fallback: fail

  - name: ship
    command: /ship
    gate:
      type: manual
      message: "Ready to commit and push?"

on_failure:
  notify: true
  rollback: false
```

---

## Feature 2: Zeno (Surgical Code Analysis)

### Overview

Evidence-based code analysis that provides file:line citations for every finding, enabling precise, verifiable code reviews.

### Complexity Assessment

**MEDIUM** - Extends existing review patterns with stricter citation requirements.

### Architecture Analysis

The toolkit already has:

- `@code-reviewer` agent with review checklist
- `@security-auditor` for vulnerability scanning
- Gemini PR review workflow with structured output

Zeno adds **mandatory file:line citations** for every finding, creating an evidence trail that can be verified.

### File Structure

```
.claude/
  agents/
    zeno-analyzer.md                   # NEW: Surgical code analyzer agent
  skills/
    surgical-analysis/                 # NEW: Skill for evidence-based analysis
      SKILL.md
  commands/
    zeno.md                            # NEW: /zeno command for analysis
    zeno-verify.md                     # NEW: /zeno-verify to validate findings
  hooks/
    zeno-citation-validator.py         # NEW: PostToolUse hook to validate citations
  templates/
    zeno-report.md                     # NEW: Report template with citation format
```

### Implementation Steps

**Phase 1: Agent Definition (0.5 days)**

1. Create `agents/zeno-analyzer.md`:
   - Strict instruction: Every finding MUST include `file:line` citation
   - Output format: structured JSON with evidence array
   - Categories: security, performance, correctness, style

**Phase 2: Skill & Citation Format (0.5 days)** 2. Create `skills/surgical-analysis/SKILL.md`:

- Citation format: `path/to/file.ts:42-45`
- Evidence requirements: code snippet, explanation, severity
- Cross-reference patterns

**Phase 3: Commands (1 day)** 3. Create `/zeno` command:

- Accepts file paths or git diff
- Outputs structured findings with citations
- Severity levels: critical, high, medium, low

4. Create `/zeno-verify` command:
   - Validates that cited lines actually contain the issue
   - Flags stale citations after code changes

**Phase 4: Validation Hook (0.5 days)** 5. Create `zeno-citation-validator.py`:

- PostToolUse hook for Write/Edit operations
- Verifies cited lines exist
- Warns if code changed since citation

### Output Format

```json
{
  "findings": [
    {
      "id": "SEC-001",
      "severity": "critical",
      "category": "security",
      "title": "SQL Injection in user query",
      "evidence": {
        "file": "src/db/users.py",
        "line_start": 42,
        "line_end": 44,
        "snippet": "cursor.execute(f\"SELECT * FROM users WHERE id={user_id}\")",
        "explanation": "User-controlled input is directly interpolated into SQL query"
      },
      "recommendation": "Use parameterized queries: cursor.execute(\"SELECT * FROM users WHERE id=?\", (user_id,))"
    }
  ]
}
```

### Integration Points

| Existing Component  | Integration                                      |
| ------------------- | ------------------------------------------------ |
| `@code-reviewer`    | Zeno extends with stricter citation requirements |
| `@security-auditor` | Can invoke Zeno for evidence gathering           |
| Gemini PR review    | Zeno findings can feed into review workflow      |
| `/review` command   | Add Zeno as an option: `/review --zeno`          |

---

## Feature 3: Gateway (Remote ChatOps)

### Overview

Remote control of Claude Code via Discord, Telegram, or Slack. Users can trigger commands, approve workflows, and receive status updates from chat platforms.

### Complexity Assessment

**HIGH** - Requires external services and webhook handling, but can leverage existing notification infrastructure.

### Architecture Analysis

The toolkit already has:

- `notify.py` for sending notifications to Slack/Discord/Telegram
- MCP server templates for Slack integration
- GitHub Actions for @claude mentions

Gateway extends this to **bidirectional communication** - receiving commands from chat platforms, not just sending notifications.

### File Structure

```
.claude/
  gateway/                             # NEW: Gateway service
    server.py                          # Webhook server for incoming messages
    handlers/
      slack.py                         # Slack command handlers
      discord.py                       # Discord command handlers
      telegram.py                      # Telegram bot handlers
    commands.py                        # Map chat commands to Claude commands
    auth.py                            # User authentication/authorization
  commands/
    gateway-start.md                   # NEW: /gateway-start command
    gateway-status.md                  # NEW: /gateway-status command
  skills/
    chatops/                           # NEW: ChatOps patterns skill
      SKILL.md
.github/
  workflows/
    gateway-webhook.yml                # NEW: Webhook receiver workflow
```

### Implementation Approach

**Option A: Local Server (Full Feature)**
A Python Flask/FastAPI server that runs alongside Claude Code, receiving webhooks from chat platforms.

**Option B: GitHub Actions (Lighter Weight)**
Use GitHub Actions as the webhook receiver, triggering Claude Code via `workflow_dispatch`.

**Recommended: Hybrid Approach**

- GitHub Actions for CI/CD-related commands (already supported)
- Local server for real-time interaction during development

### Implementation Steps

**Phase 1: Command Mapping (1 day)**

1. Create `gateway/commands.py`:
   - Map chat commands to Claude commands: `/plan`, `/qa`, `/ship`
   - Support for arguments: `/zeno src/auth/`
   - Response formatting for each platform

**Phase 2: GitHub Actions Gateway (1 day)** 2. Create `gateway-webhook.yml`:

- Triggered by `workflow_dispatch` from platform webhooks
- Parses incoming command
- Executes appropriate Claude Code command
- Posts result back to chat

**Phase 3: Platform Handlers (2 days)** 3. Create platform-specific handlers:

- Slack: Slash commands via Slack app
- Discord: Bot commands via Discord.py
- Telegram: Bot commands via Telegram Bot API

**Phase 4: Authentication (1 day)** 4. Create `gateway/auth.py`:

- Verify user has permission to execute commands
- Map chat users to GitHub users
- Rate limiting

### Integration Points

| Existing Component      | Integration                                      |
| ----------------------- | ------------------------------------------------ |
| `notify.py`             | Gateway responses use existing notification code |
| `@claude` workflow      | Gateway extends to other platforms               |
| Workflow approval gates | Chat responses can approve gates                 |
| MCP Slack server        | Can be used for Slack integration                |

### External Dependencies

| Dependency            | Purpose               | Required                   |
| --------------------- | --------------------- | -------------------------- |
| `flask` or `fastapi`  | Webhook server        | For local server option    |
| `slack_sdk`           | Slack API integration | For Slack                  |
| `discord.py`          | Discord bot           | For Discord                |
| `python-telegram-bot` | Telegram bot          | For Telegram               |
| GitHub Actions        | Webhook processing    | For Actions-based approach |

---

## Feature 4: Headless Browser (CDP)

### Overview

Chrome DevTools Protocol integration for E2E testing, visual validation, and browser automation directly from Claude Code.

### Complexity Assessment

**HIGH** - Requires browser binary and CDP communication, but MCP Puppeteer server provides a foundation.

### Architecture Analysis

The toolkit already has:

- `@test-automator` agent with Playwright patterns
- MCP Puppeteer server in configuration templates
- E2E testing skill patterns

The Headless Browser feature adds **direct CDP access** for lower-level browser control beyond what test frameworks provide.

### File Structure

```
.claude/
  browser/                             # NEW: Browser automation
    cdp_client.py                      # CDP WebSocket client
    commands.py                        # High-level browser commands
    selectors.py                       # Element selection helpers
    screenshots.py                     # Screenshot capture and comparison
  agents/
    browser-automator.md               # NEW: Browser automation agent
  skills/
    browser-automation/                # NEW: Browser automation patterns
      SKILL.md
  commands/
    browser.md                         # NEW: /browser command
    screenshot.md                      # NEW: /screenshot command
    visual-diff.md                     # NEW: /visual-diff command
tools/
  browser/
    install-chrome.sh                  # Chrome/Chromium installation helper
    launch-headless.sh                 # Launch browser in headless mode
```

### Implementation Approaches

**Option A: MCP Puppeteer Server (Recommended)**
Leverage the existing MCP Puppeteer server which already provides browser automation capabilities.

**Option B: Direct CDP Client**
Build a Python CDP client for lower-level control, useful for debugging and custom automation.

**Recommended: MCP-First with CDP Fallback**

### Implementation Steps

**Phase 1: MCP Integration (1 day)**

1. Document MCP Puppeteer server setup in skill
2. Create `/browser` command that uses MCP tools
3. Create `@browser-automator` agent with MCP tool access

**Phase 2: Screenshot & Visual Testing (1 day)** 4. Create `/screenshot` command:

- Capture full page or element screenshots
- Save to `.claude/artifacts/screenshots/`

5. Create `/visual-diff` command:
   - Compare screenshots against baselines
   - Highlight differences

**Phase 3: CDP Client (Optional, 2 days)** 6. Create `browser/cdp_client.py`:

- WebSocket connection to Chrome
- Basic CDP commands: navigate, evaluate, screenshot
- Network interception

**Phase 4: Skill & Patterns (0.5 days)** 7. Create `skills/browser-automation/SKILL.md`:

- Page Object patterns
- Wait strategies
- Error handling

### Integration Points

| Existing Component   | Integration                          |
| -------------------- | ------------------------------------ |
| MCP Puppeteer server | Primary browser automation           |
| `@test-automator`    | Can use browser commands for E2E     |
| Playwright patterns  | Already documented in test-automator |
| `/qa` command        | Can include visual regression tests  |

### External Dependencies

| Dependency           | Purpose            | Required        |
| -------------------- | ------------------ | --------------- |
| Chrome/Chromium      | Browser binary     | Yes             |
| MCP Puppeteer server | Browser automation | Recommended     |
| `websocket-client`   | CDP communication  | For direct CDP  |
| `Pillow`             | Image comparison   | For visual diff |

---

## Feature 5: Specialized Dev Skills

### Overview

Three specialized development skills: **ralph** (coder loop), **deslop** (refactorer), and **systematic-debugging**.

### Complexity Assessment

**LOW-MEDIUM** - Skills follow established patterns; ralph is already partially implemented.

### Architecture Analysis

The toolkit already has:

- `autonomous-loop` skill (Ralph-based)
- `refactoring` skill
- `debugging` skill
- `/ralph` command

The new skills add **refined, specialized behaviors** on top of existing foundations.

### File Structure

```
.claude/
  skills/
    ralph-coder/                       # NEW: Enhanced coder loop (extends autonomous-loop)
      SKILL.md
    deslop/                            # NEW: Aggressive refactoring skill
      SKILL.md
    systematic-debugging/              # NEW: Enhanced debugging methodology
      SKILL.md
  commands/
    deslop.md                          # NEW: /deslop command
    systematic-debug.md                # NEW: /systematic-debug command
```

### Skill 1: Ralph Coder Loop (Enhanced)

The existing `autonomous-loop` skill is already Ralph-based. Enhancements:

**New patterns to add:**

- **Code Quality Gates**: Run linters/formatters between loops
- **Test-First Enforcement**: Write failing test before implementation
- **Commit Atomicity**: Commit after each successful loop
- **Progress Metrics**: Track lines changed, tests added, complexity reduced

### Skill 2: Deslop (Aggressive Refactorer)

**Deslop Philosophy:**

- "Slop" = verbose, unclear, over-engineered code
- Deslop = ruthlessly simplify
- Targets: unnecessary abstractions, dead code, complex conditionals

**Key Patterns:**

1. **YAGNI Enforcement**: Remove features not currently used
2. **Line Budget**: Aim for 50% code reduction where possible
3. **Readability First**: Inline over-abstracted code
4. **Test Verification**: Run tests after every change

### Skill 3: Systematic Debugging

**Beyond existing debugging skill:**

1. **Hypothesis Tracking**: Numbered hypotheses with status (testing/confirmed/rejected)
2. **Evidence Collection**: Structured evidence format with timestamps
3. **Bisection Protocol**: Automated git bisect when applicable
4. **Root Cause Classification**: Taxonomy of bug types

### Implementation Steps

**Phase 1: Ralph-Coder Enhancements (0.5 days)**

1. Update `autonomous-loop` skill OR create `ralph-coder` skill:
   - Add code quality gates
   - Add commit atomicity pattern
   - Add progress metrics tracking

**Phase 2: Deslop Skill (1 day)** 2. Create `skills/deslop/SKILL.md`:

- Deslop philosophy and targets
- Simplification heuristics
- Before/after examples

3. Create `/deslop` command:
   - Accepts file paths
   - Reports simplification metrics
   - Safe mode with preview

**Phase 3: Systematic Debugging (1 day)** 4. Create `skills/systematic-debugging/SKILL.md`:

- Hypothesis tracking format
- Evidence collection template
- Bisection protocol

5. Create `/systematic-debug` command:
   - Accepts bug description
   - Outputs structured investigation

**Phase 4: Skill Activation Integration (0.5 days)** 6. Update `skill-activation-prompt.mjs`:

- Add triggers for new skills
- Pattern matching for deslop keywords
- Pattern matching for debugging keywords

### Skill Activation Triggers

Add to `skill-activation-prompt.mjs`:

```javascript
'ralph-coder': {
  patterns: [
    /\bcoder.?loop\b/,
    /\bralph.?mode\b/,
    /\bautonomous.?cod/,
  ],
  priority: 1
},
'deslop': {
  patterns: [
    /\bdeslop\b/,
    /\bremove.?slop\b/,
    /\baggressive.?refactor/,
    /\bsimplify.?drastic/,
    /\bcut.?code\b/,
    /\breduce.?complex/,
  ],
  priority: 1
},
'systematic-debugging': {
  patterns: [
    /\bsystematic.?debug/,
    /\bmethodical.?debug/,
    /\bstructured.?debug/,
    /\broot.?cause.?analysis/,
    /\bbisect/,
  ],
  priority: 1
}
```

---

## Summary Table

| Feature | Files to Create | Lines of Code | External Deps |
| ------- | --------------- | ------------- | ------------- |
| Lobster | 8 files         | ~800-1000     | PyYAML        |
| Zeno    | 5 files         | ~300-400      | None          |
| Gateway | 7 files         | ~600-800      | Platform SDKs |
| Browser | 6 files         | ~400-500      | Chrome, MCP   |
| Skills  | 5 files         | ~400-500      | None          |

---

## Critical Files for Implementation

List of files most critical for implementing this plan:

1. `.claude/skills/autonomous-loop/SKILL.md` - Foundation for ralph-coder skill enhancement
2. `.claude/hooks/SkillActivationHook/skill-activation-prompt.mjs` - Must be updated for new skill triggers
3. `.claude/agents/code-reviewer.md` - Pattern template for Zeno agent
4. `.github/mcp-config.json.template` - MCP server configuration for Puppeteer
5. `.claude/hooks/notify.py` - Foundation for Gateway bidirectional communication

---

## Changelog

- 2026-01-25: Initial plan created
