# Claude Code Professional Engineering Team Setup
## Comprehensive Research Report
*Based on Boris Cherny's Workflow and Professional Engineering Best Practices*

---

## Table of Contents

1. [Claude Code Slash Commands and Professional Workflows](#claude-code-slash-commands-and-professional-workflows)
2. [Claude Code Subagents and Professional Engineering Workflow](#claude-code-subagents-and-professional-engineering-workflow)
3. [Claude Code Hooks and Professional Agent Setup](#claude-code-hooks-and-professional-agent-setup)
4. [Claude Code Permission Management](#claude-code-permission-management)
5. [Claude Code MCP Server Integrations (Slack, BigQuery, Sentry)](#claude-code-mcp-server-integrations-(slack-bigquery-sentry))
6. [Claude Code GitHub Actions and Automated Code Review](#claude-code-github-actions-and-automated-code-review)
7. [Claude Code verification strategies](#claude-code-verification-strategies)
8. [Claude Code Multi-Session Management and Professional Workflow](#claude-code-multi-session-management-and-professional-workflow)
9. [Claude Code Plan Mode and Professional Workflows](#claude-code-plan-mode-and-professional-workflows)
10. [Professional Software Engineering Practices for Agentic Coding (Claude Code Setup)](#professional-software-engineering-practices-for-agentic-coding-(claude-code-setup))

---

## 1. Claude Code Slash Commands and Professional Workflows

### Key Findings

*   **Slash Commands as Reusable Prompts:** Claude Code slash commands are Markdown files stored in a dedicated directory that act as reusable, parameterized prompts for Claude. They automate repetitive "inner loop" development workflows, such as committing code or running tests [1] [2].
*   **Directory Structure and Scope:** Custom commands are created by placing `.md` files in either the project-specific `.claude/commands/` directory (for team-shared workflows) or the personal `~/.claude/commands/` directory (for user-specific workflows). Project commands take precedence over personal ones [1].
*   **Pre-computed Context with Inline Bash:** The key to professional-grade commands is the use of **inline bash execution** (`!``command``) within the Markdown file. This executes shell commands (e.g., `git status`, `git diff`) and injects their real-time output into the prompt, giving Claude accurate, up-to-date context before it executes its task [1] [2].
*   **Frontmatter for Control and Security:** Commands use a YAML frontmatter block to define metadata, most critically the `allowed-tools` list. This explicitly grants Claude permission to use specific tools (like `Bash(git commit:*)`) and prevents the AI from executing arbitrary or dangerous commands, which is essential for team security and stability [1].

### Implementation Details

**1. Slash Command Directory Structure and Scope**

Custom slash commands are defined in Markdown files (`.md`) and are organized into two scopes: Project and Personal [1]. For a professional engineering team, **Project Commands** are the standard, as they are version-controlled and shared [1].

| Scope | Location | Visibility | Precedence |
| :--- | :--- | :--- | :--- |
| **Project** | `.claude/commands/` (relative to project root) | Shared with the team, committed to Git | Takes precedence over Personal Commands with the same name [1]. |
| **Personal** | `~/.claude/commands/` (user's home directory) | Only visible to the user | Ignored if a Project Command with the same name exists [1]. |

**2. Custom Command Syntax and Features**

A custom slash command is a Markdown file with an optional YAML frontmatter block for metadata and a body containing the prompt instructions for Claude [1].

*   **File Naming:** The filename (without the `.md` extension) becomes the command name. E.g., `.claude/commands/git/commit-push-pr.md` creates the command `/commit-push-pr` [1].
*   **Arguments:** Arguments are passed to the command using positional placeholders (`$1`, `$2`, etc.) or the collective placeholder (`$ARGUMENTS`) [1].
*   **Inline Bash Execution:** Use the `!` prefix followed by a command in backticks (`!``command``) to execute a shell command and inject its output into the prompt context before Claude processes it [1].

**3. Example: Professional Inner Loop Workflow Command**

The `/commit-push-pr` command, a core inner loop workflow for the Claude Code team, demonstrates the use of frontmatter, allowed tools, and inline bash to pre-compute context [2].

**File Path:** `.claude/commands/git/commit-push-pr.md`

**Content:**
```markdown
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*)
argument-hint: [commit-message]
description: Commit staged changes, push to the current branch, and create a pull request.
model: claude-3-5-sonnet
---

## Context for Claude

- **Current git status:** !`git status`
- **Current branch:** !`git branch --show-current`
- **Recent commits:** !`git log --oneline -5`
- **Staged changes:** !`git diff --staged`

## Your Task

1.  **Review** the staged changes and the current git status provided in the 'Context' section.
2.  **Commit** the staged changes using the provided commit message: "$ARGUMENTS".
3.  **Push** the committed changes to the remote branch.
4.  **Create a Pull Request** using the `gh pr create` tool. Use the commit message as the PR title and generate a detailed description based on the changes.

**Note:** If no changes are staged, inform the user and stop. Ensure all steps are executed sequentially and report the outcome of each step.
```

**4. Frontmatter Configuration Details**

| Frontmatter Key | Purpose | Example Value |
| :--- | :--- | :--- |
| `allowed-tools` | Restricts the tools Claude can use, enhancing security and focus [1]. | `Bash(git add:*), Bash(git commit:*)` |
| `description` | Brief description shown in the `/help` menu [1]. | `Commit staged changes and create a PR` |
| `argument-hint` | Hint for expected arguments, shown during command auto-completion [1]. | `[message] [reviewers]` |
| `model` | Overrides the default model for this specific command [1]. | `claude-3-5-sonnet` |

### Best Practices

* **Standardize Project Commands:** For professional teams, all custom slash commands should be created as **Project Commands** under the `.claude/commands/` directory and committed to the repository. This ensures all team members use the same, version-controlled workflows, promoting consistency and reducing "works on my machine" issues [1].
* **Implement Namespacing for Clarity:** Utilize subdirectories within `.claude/commands/` (e.g., `git/`, `deploy/`, `refactor/`) to group related commands. This provides clear context in the `/help` output (e.g., `(project:git)`) and prevents naming conflicts, which is crucial for large, complex codebases [1].
* **Pre-compute Context with Inline Bash:** Design commands to use inline bash (`!``command``) to pre-compute and inject relevant, up-to-date context (e.g., `git status`, `git diff`, environment variables) before the prompt is sent to Claude. This minimizes the model's cognitive load, increases the accuracy of its output, and ensures the AI operates on the latest state of the project [1] [2].
* **Use Frontmatter for Tool and Model Control:** Explicitly define the `allowed-tools` and `model` in the command's frontmatter. For example, restrict a `git` command to only use `Bash(git add:*)` and `Bash(git commit:*)` to enforce security and prevent unintended side effects. For complex tasks, specify a more capable model like `claude-3-5-sonnet` [1].
* **Track and Audit Command Usage:** Integrate command usage tracking (e.g., via a custom hook or a simple log file within the command's bash execution) to monitor which workflows are most used, identify bottlenecks, and continuously improve the team's inner loop efficiency [2].

### Sources

1. https://code.claude.com/docs/en/slash-commands
2. https://x.com/bcherny/status/2007179847949500714

**Confidence Level:** High

---

## 2. Claude Code Subagents and Professional Engineering Workflow

### Key Findings

*   **Subagents as Specialized AI Assistants:** Claude Code subagents are specialized AI assistants with their own system prompts, tools, and separate context windows, enabling task delegation and preventing context pollution in the main conversation [1].
*   **Boris Cherny's Core Subagents:** The workflow creator, Boris Cherny, uses specialized subagents like **`code-simplifier`** (for post-generation code hygiene and readability) and **`verify-app`** (for comprehensive end-to-end testing and quality assurance) to replicate a professional engineering team's roles [2].
*   **Configuration via Markdown/YAML:** Custom subagents are configured using Markdown files with YAML frontmatter, defining their `name`, `description`, `tools` access, and the specific Claude `model` to use, with the system prompt in the body [1].
*   **Professional Team Setup:** A 5+ person team can be simulated by creating subagents for distinct roles such as **System Architect**, **Code Reviewer**, **Debugger**, and **DevOps Engineer**, each with a focused persona and toolset [3].
*   **Implementation for Proactive Use:** To encourage automatic delegation, the subagent's `description` field should include explicit instructions like "Use proactively" or "MUST BE USED" for Claude Code to delegate tasks appropriately [1].

### Implementation Details

### Subagent Configuration and File Structure

Custom subagents are defined in Markdown files with YAML frontmatter, which are stored in specific directories. Project-level subagents take precedence over user-level subagents.

| Configuration Level | File Path | Priority |
| :--- | :--- | :--- |
| **Project-Level** | `.claude/agents/` | Highest |
| **User-Level** | `~/.claude/agents/` | Lower |

### Example: The `code-simplifier` Subagent

The `code-simplifier` subagent, a core component of Boris Cherny's workflow, is designed for code hygiene and maintainability.

```markdown
---
name: code-simplifier
description: Simplify code after Claude is done working. Use proactively after code changes.
tools: Read, Edit, Grep, Glob
model: inherit
---

You are a code simplification expert. Your goal is to make code more readable and maintainable without changing functionality.

Simplification principles:
- Reduce complexity and nesting
- Extract repeated logic into functions
- Use meaningful variable names
- Remove dead code and comments
- Simplify conditional logic
- Apply modern language features

Process:
1. Read the modified files
2. Identify simplification opportunities
3. Apply simplifications
4. Verify tests still pass
5. Report changes made

Never change functionality - only improve readability and maintainability.
```

### Example: The `verify-app` Subagent

The `verify-app` subagent is the quality assurance (QA) engineer, ensuring correctness and quality through end-to-end testing.

```markdown
---
name: verify-app
description: Tests Claude Code end-to-end with detailed instructions. Use proactively before final commit.
tools: Read, Bash, Grep, Glob
model: sonnet
---

You are an app verification assistant. Your task is to run comprehensive end-to-end tests on the Claude-generated application to ensure correctness and quality.

Instructions:
- Follow the detailed test plan provided.
- Check all functionalities, edge cases, and error handling.
- Verify performance and responsiveness.
- Report any failures with detailed logs.
- Confirm when the app passes all tests.

Do not make code changes; only verify and report results.
```

### Management and Invocation

*   **Recommended Management:** Use the interactive slash command `/agents` within a Claude Code session to view, create, edit, and manage tool permissions for subagents [1].
*   **Explicit Invocation:** To ensure a specific subagent is used, mention it in the command, e.g., `> Use the code-reviewer subagent to look at my recent changes` [1].

### Best Practices

1. Define Specialized Personas: Create subagents for distinct roles (e.g., System Architect, Code Reviewer, Debugger, DevOps Engineer) to simulate a professional team and prevent a single agent from being a generalist [3].
2. Use Separate Contexts for Hygiene: Leverage the subagent's separate context window to keep the main conversation focused on high-level objectives, improving context preservation and efficiency [1].
3. Grant Granular Tool Access: Specify the `tools` field (e.g., `Read, Edit, Grep, Glob`) to limit powerful tools to specific subagents, enhancing security and preventing accidental misuse [1].
4. Enforce Proactive Delegation: Include phrases like "Use proactively" or "MUST BE USED" in the subagent's `description` to ensure Claude Code automatically delegates tasks to the specialist when appropriate [1].
5. Inject Criticality in Prompts: Instruct subagents to "be honest," "be critical," or "be realistic" in their system prompts to override the default agreeable LLM demeanor, ensuring rigorous quality checks and argumentative design discussions [3].

### Sources

https://code.claude.com/docs/en/sub-agents
https://dev.to/sivarampg/how-the-creator-of-claude-code-uses-claude-code-a-complete-breakdown-4f07
https://shipyard.build/blog/claude-code-subagents-guide/

**Confidence Level:** High

---

## 3. Claude Code Hooks and Professional Agent Setup

### Key Findings

*   **Claude Code Hooks** are callbacks that allow developers to inject custom logic at various points in the agent's execution loop, including `PreToolUse`, `PostToolUse`, `Stop`, and `UserPromptSubmit` [1] [2].
*   **`PostToolUse` Hooks** are critical for code hygiene, primarily used to enforce deterministic actions immediately after the agent modifies code, such as running auto-formatters (e.g., Black, Prettier) or linters [4] [5].
*   **`Stop` Hooks** serve as "end-of-turn quality gates," running automated verification checks (e.g., unit tests, type checks, security scans) before the agent's turn concludes, ensuring the generated code is functional and correct [5].
*   **Agent Hooks** (or Subagent Hooks) enable the creation of specialized, self-contained agents with custom instructions and toolsets for specific, complex workflows, which is a key component of Boris Cherny's setup for managing a large, professional codebase [6] [7].
*   **Boris Cherny's Workflow** emphasizes a "universal setup" for professional teams, utilizing hooks for automated quality checks, extensive logging (`PostToolUse` for tracking changes), and powerful slash commands (e.g., `/commit-push-pr`) that combine agentic steps with inline shell commands for end-to-end development tasks [6] [8].

### Implementation Details

**Hook Implementation Pattern:** Hooks are implemented as functions that receive a specific input object (e.g., `PostToolUseInput`) and return an an output object (e.g., `PostToolUseOutput`). The core logic involves calling external deterministic tools.

**1. Code Formatting (`PostToolUse` Hook):**
This hook is triggered immediately after a file modification tool is used. It ensures code hygiene by running a formatter on the changed file.

```python
# Conceptual Python implementation for a PostToolUse hook
import subprocess

def post_tool_use_formatter_hook(input: PostToolUseInput) -> PostToolUseOutput:
    # Check if the tool used was a file-writing tool
    if input.tool_name == "file_writer":
        # Assuming the tool output contains the path to the modified file
        modified_file_path = input.tool_output.get("path")
        
        if modified_file_path and modified_file_path.endswith(".py"):
            try:
                # Execute the Black formatter
                subprocess.run(["black", modified_file_path], check=True, capture_output=True)
                print(f"Formatted file: {modified_file_path}")
            except subprocess.CalledProcessError as e:
                # Log the error but allow the agent to continue
                print(f"Formatting failed for {modified_file_path}: {e.stderr.decode()}")
    
    return PostToolUseOutput(status="success")
```

**2. Verification (`Stop` Hook - End-of-Turn Quality Gate):**
This hook runs before the agent stops, acting as a final quality check. If tests fail, the hook can prevent the agent from stopping, forcing a self-correction loop.

```python
# Conceptual Python implementation for a Stop hook
import subprocess

def stop_verification_hook(input: StopInput) -> StopOutput:
    # Run unit tests
    try:
        result = subprocess.run(["pytest", "--quiet"], check=True, capture_output=True)
        
        # If tests pass, allow the agent to stop
        return StopOutput(status="success", message="All tests passed. Work complete.")
        
    except subprocess.CalledProcessError as e:
        # If tests fail, return an error status to force the agent to re-evaluate
        error_message = f"Verification failed: Unit tests failed. Output:\n{e.stdout.decode()}\n{e.stderr.decode()}"
        
        # This message will be fed back to the agent as a new observation
        return StopOutput(status="error", message=error_message)
```

**3. Boris Cherny's Slash Commands (Encapsulated Workflows):**
These commands combine agentic steps with deterministic shell commands for end-to-end development tasks.

```bash
# Example of a /commit-push-pr slash command definition
# This command is executed by the agent's shell tool.

# 1. Pre-compute git status for context
echo "Current Git Status:"
git status

# 2. Add all changes and commit with a placeholder message
git add . && git commit -m "WIP: Agent-driven change"

# 3. Push the changes
git push

# 4. Create a Pull Request using GitHub CLI
gh pr create --title "Agent Fix: Automated bug resolution" --body "This PR was automatically generated by the Claude Code agent after a successful fix and verification run."
```

### Best Practices

1. Enforce Deterministic Quality Gates: Implement a `PostToolUse` hook to run a code formatter (e.g., Black, Prettier) immediately after any file is modified to ensure consistent code style across the team.
2. Establish End-of-Turn Verification: Utilize the `Stop` hook to execute a full suite of unit tests, type checks (e.g., MyPy, TypeScript), and security linters before the agent's turn is considered complete, ensuring functional correctness.
3. Modularize Complex Workflows with Subagents: For specialized tasks (e.g., database migrations, infrastructure-as-code changes), create dedicated subagents with tailored instructions and toolsets to improve focus and reliability.
4. Implement Comprehensive Logging: Use the `PostToolUse` hook to log every tool call, its inputs, and the resulting file changes to a persistent store (e.g., a database or log file) for auditing, debugging, and tracking team efficiency.
5. Create Powerful Slash Commands: Define custom slash commands that chain together multiple agentic steps and deterministic shell commands (e.g., for full CI/CD workflows like `/deploy-staging` or `/commit-push-pr`) to automate common, complex developer tasks.

### Sources

https://code.claude.com/docs/en/hooks-guide
https://code.claude.com/docs/en/hooks
https://www.eesel.ai/blog/hooks-reference-claude-code
https://blog.gitbutler.com/automate-your-ai-workflows-with-claude-code-hooks
https://jpcaparas.medium.com/claude-code-use-hooks-to-enforce-end-of-turn-quality-gates-5bed84e89a0d
https://www.threads.com/@boris_cherny/post/DOo3kzGEoBu/hooks-allow-you-to-hook-into-any-point-in-claudes-agent-loop-use-pretooluse-for-
https://www.reddit.com/r/ClaudeAI/comments/1q2c0ne/claude_code_creator_boris_shares_his_setup_with/
https://x.com/bcherny/status/2007179847949500714

**Confidence Level:** High

---

## 4. Claude Code Permission Management

### Key Findings

*   **Permission Configuration is Centralized and Hierarchical:** Claude Code's permissions are managed via the `permissions` object in `settings.json`, which supports `deny`, `ask`, and `allow` rules. These rules are applied in a strict precedence order: `deny` > `ask` > `allow` [1] [2].
*   **Pre-Allowed Bash Commands Use Prefix Matching:** Safe, common Bash commands (e.g., test, build, lint) can be pre-allowed using the `Bash(command-prefix:*)` format in the `allow` array of the shared `.claude/settings.json`. This avoids repetitive user prompts and is a key component of the creator's recommended team workflow [1] [3].
*   **Professional Workflow Emphasizes Planning and Verification:** The creator's workflow for a professional team involves starting in **Plan mode** (`--permission-mode=plan`), switching to **auto-accept edits mode** for execution, and most importantly, building a robust feedback loop where Claude can **verify its own work** (e.g., running tests or browser checks) [3].
*   **Team Policy Enforcement Relies on Settings Precedence:** For large teams, organizational policies should be enforced using **Managed settings** or **File-based managed settings** (`managed-settings.json`), which take precedence over all other settings, including local project and user configurations [1].

### Implementation Details

The core of Claude Code's permission management for a professional team is the `settings.json` file, which can be shared via version control in the project's `.claude/settings.json` directory.

### 1. The `/permissions` Command
The `/permissions` slash command provides a user interface to inspect and manage all active permission rules. It is the primary tool for a developer to understand which rules are currently applied and from which `settings.json` file they originate.

### 2. `settings.json` Structure for Permissions
Permission rules are defined within the `permissions` object in `settings.json`. The rules are applied in a strict precedence order: `deny` > `ask` > `allow`.

| Key | Type | Description | Precedence |
| :--- | :--- | :--- | :--- |
| `deny` | `string[]` | Rules that permanently prevent tool use. | Highest |
| `ask` | `string[]` | Rules that always prompt the user for confirmation. | Medium |
| `allow` | `string[]` | Rules that permit tool use without a prompt. | Lowest |

**Example `settings.json` for a Team Project:**
```json
{
  "permissions": {
    "deny": [
      "Bash(sudo:*)",
      "Bash(rm -rf:*)",
      "Edit(//etc/*)",
      "WebFetch(domain:production-api.com)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Edit(/src/critical-config.ts)"
    ],
    "allow": [
      "Bash(npm run test:*)",
      "Bash(npm run build)",
      "Bash(make lint)",
      "Read(*.md)",
      "WebFetch(domain:staging-api.com)"
    ]
  },
  "defaultMode": "plan"
}
```

### 3. Pre-Allowing Safe Bash Commands
The `Bash` tool supports fine-grained, prefix-based matching for pre-allowing safe commands. This is the recommended method for sharing common, safe operations across a team.

| Rule Format | Description | Example |
| :--- | :--- | :--- |
| `Bash(exact command)` | Matches the command exactly. | `Bash(npm run build)` |
| `Bash(prefix:*)` | Matches any command starting with the specified prefix. The `:*` wildcard must be at the end. | `Bash(npm run test:*)` |
| `Bash(tool command)` | Allows a specific tool's command. | `Bash(curl http://site.com/:*)` |

**Note on Bash Pattern Matching:** The matching is a **prefix match**, not a regular expression or glob. It is sensitive to shell operators like `&&` and will not match if the command is part of a chain (e.g., `Bash(safe-cmd:*)` will not match `safe-cmd && other-cmd`).

### 4. Configuration Precedence for Team Policies
For a 5+ person team, understanding the settings precedence is crucial for policy enforcement and consistency:

1. **Managed settings** (via Claude.ai admin console)
2. **File-based managed settings** (`managed-settings.json` in system directories)
3. **Command line arguments** (e.g., `--permission-mode=acceptEdits`)
4. **Local project settings** (`.claude/settings.local.json`)
5. **Shared project settings** (`.claude/settings.json`) - **Recommended for team-wide permissions**
6. **User settings** (`~/.claude/settings.json`)

### Best Practices

1. **Centralize and Share Safe Permissions:** Use the shared project settings file (`.claude/settings.json`) to pre-allow common, safe Bash commands (e.g., `npm run test:*`, `make build`) and check this file into version control. This ensures a consistent, secure, and efficient environment for all team members, minimizing repetitive permission prompts.
2. **Adopt a Plan-First Workflow:** Encourage the team to start most sessions in **Plan mode** (`--permission-mode=plan` or `shift+tab` twice). This forces Claude to articulate its strategy before execution, allowing for human review and course correction, which is critical for complex tasks and code hygiene.
3. **Implement Automated Verification:** The most critical best practice is to build a robust feedback loop where Claude can **verify its own work**. This can be a simple Bash command (e.g., running a linter or unit test suite) or a complex browser-based test, ensuring high-quality, reliable code changes.
4. **Leverage Configuration Hierarchy for Policy Enforcement:** Utilize the settings precedence hierarchy to enforce organizational security policies. Administrators should use **Managed settings** (via admin console or `managed-settings.json`) to set strict `deny` rules for sensitive operations (e.g., cloud infrastructure changes, production database access) that cannot be overridden by local project or user settings.
5. **Integrate External Tools via MCP:** For professional workflows, configure **Model Context Protocol (MCP) servers** (e.g., for Slack, Sentry, BigQuery) and share the configuration (`.mcp.json`) with the team. This allows Claude to interact with the full suite of engineering tools, moving beyond simple file and shell operations.

### Sources

1. https://code.claude.com/docs/en/iam
2. https://gist.github.com/xdannyrobertsx/0a395c59b1ef09508e52522289bd5bf6
3. https://www.reddit.com/r/ClaudeAI/comments/1q2c0ne/claude_code_creator_boris_shares_his_setup_with/

**Confidence Level:** High

---

## 5. Claude Code MCP Server Integrations (Slack, BigQuery, Sentry)

### Key Findings

The Claude Code professional setup is centered on the **Model Context Protocol (MCP)**, with configuration shared via a version-controlled `.mcp.json` file that supports environment variable expansion for secrets.
**Sentry** integration is best achieved via the remote-hosted MCP server using **OAuth** for secure, streamlined authentication and access to tools like **Seer** for automated issue fixing.
**BigQuery** integration requires a local **MCP Toolbox** binary running in STDIO mode, configured with the project ID via an environment variable (`BIGQUERY_PROJECT`), and relies on **Application Default Credentials (ADC)** for authentication.
**Slack** integration, a key component of the workflow, uses third-party MCP servers (e.g., `korotovsky/slack-mcp-server`) running in STDIO mode, authenticated via a bot token, to enable the agent to post and query team communication.
Team efficiency is maintained through **configuration hygiene** (shared `.mcp.json`), **context management** (shared `CLAUDE.md`), and **delegation** (treating the main agent as a router to specialized MCP tools).

### Implementation Details

The Claude Code professional setup is built around a shared, version-controlled configuration file, `.mcp.json`, which uses environment variable expansion to manage secrets and project-specific settings.

**1. Configuration File Structure (`.mcp.json`)**

The file is placed at the project root to be shared by the team and contains the definitions for all integrated MCP servers.

```json
{
  "mcpServers": {
    "sentry": {
      "url": "https://mcp.sentry.dev/mcp"
    },
    "bigquery": {
      "command": "./tools/mcp-toolbox",
      "args": ["--prebuilt", "bigquery", "--stdio"],
      "env": {
        "BIGQUERY_PROJECT": "${BIGQUERY_PROJECT_ID}"
      }
    },
    "slack": {
      "command": "npx",
      "args": ["@korotovsky/slack-mcp-server", "--stdio"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}"
      }
    }
  }
}
```

**2. Sentry MCP Server Integration**

| Detail | Implementation |
| :--- | :--- |
| **Integration Type** | Remote Hosted (OAuth Recommended) |
| **Configuration Key** | `sentry` |
| **Configuration Value** | `url` pointing to the Sentry MCP endpoint: `https://mcp.sentry.dev/mcp` |
| **Tools Provided** | Access to issues, search, project/organization queries, and the ability to invoke **Seer** for automated fixes. |
| **Claude Code CLI** | `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp` |

**3. BigQuery MCP Server Integration**

| Detail | Implementation |
| :--- | :--- |
| **Integration Type** | Local STDIO via MCP Toolbox |
| **Prerequisites** | Install MCP Toolbox binary, configure [Application Default Credentials (ADC)], and set the `BIGQUERY_PROJECT_ID` environment variable. |
| **Command/Args** | Executes the local `toolbox` binary: `./tools/mcp-toolbox` with arguments `["--prebuilt", "bigquery", "--stdio"]`. |
| **Environment Variable** | `BIGQUERY_PROJECT` is required to specify the default Google Cloud Project ID. |
| **Tools Provided** | `execute_sql`, `list_table_ids`, `ask_data_insights`, `forecast`, and `analyze_contribution`. |

**4. Slack MCP Server Integration**

| Detail | Implementation |
| :--- | :--- |
| **Integration Type** | Third-Party STDIO (Example: `korotovsky/slack-mcp-server`) |
| **Prerequisites** | Install the server package (e.g., via `npm` or `npx`) and obtain a Slack Bot Token with necessary permissions. |
| **Command/Args** | Executes the installed Slack MCP server package: `npx @korotovsky/slack-mcp-server --stdio`. |
| **Environment Variable** | `SLACK_BOT_TOKEN` is used for authentication. |

### Best Practices

Centralize and Version Control Configuration: Check the team's MCP server configuration into the project's source control as a `.mcp.json` file at the project root to ensure consistency across the team.
Use Environment Variables for Secrets: Externalize all sensitive information (API keys, tokens, project IDs) using environment variable expansion within `.mcp.json` to prevent hardcoding secrets and ensure secure, flexible configuration.
Define Agent Context with `CLAUDE.md`: Create a shared, team-contributed `CLAUDE.md` file at the repository root to provide the LLM with high-level context, architectural decisions, and project-specific conventions.
Treat Claude Code as a Delegator: Treat the primary Claude Code instance as a delegator, routing specialized tasks (e.g., analytics, error checking) to the appropriate MCP-integrated tool (BigQuery, Sentry).
Prioritize OAuth and Remote Hosting: Whenever possible, use remote-hosted MCP servers with OAuth authentication (like Sentry) to leverage existing IAM systems and avoid managing long-lived tokens.
Principle of Least Privilege: Configure tokens or service accounts used by MCP servers with the absolute minimum permissions required for their designated tasks (e.g., read-only access for BigQuery analytical tools).

### Sources

https://code.claude.com/docs/en/mcp
https://docs.sentry.io/product/sentry-mcp/
https://docs.cloud.google.com/bigquery/docs/pre-built-tools-with-mcp-toolbox
https://www.reddit.com/r/ClaudeAI/comments/1q2c0ne/claude_code_creator_boris_shares_his_setup_with/
https://www.anthropic.com/engineering/claude-code-best-practices
https://mckayjohns.substack.com/p/get-the-most-out-of-claude-code
https://www.threads.com/@boris_cherny/post/DTBVlMIkpcm/im-boris-and-i-created-claude-code-lots-of-people-have-asked-how-i-use-claude
https://blog.skyvia.com/mcp-server-for-google-bigquery/

**Confidence Level:** High

---

## 6. Claude Code GitHub Actions and Automated Code Review

### Key Findings

*   **Core Automation Tool**: The foundation of the professional setup is the `anthropics/claude-code-action@v1` GitHub Action, which integrates the Claude Code CLI into GitHub workflows for automated code review and implementation [1].
*   **`/install-github-app` Functionality**: This command, run in the Claude Code terminal, is the recommended "Quick setup" method. It automatically installs the official Claude GitHub App and configures the necessary `ANTHROPIC_API_KEY` secret, simplifying the initial integration [1].
*   **`@claude` Tagging Trigger**: The interactive workflow is activated by an explicit `@claude` mention in a Pull Request or Issue comment. The workflow YAML uses a complex `if` condition to check the comment body for this tag, ensuring the AI only runs when explicitly invoked [3].
*   **Standards Enforcement via `CLAUDE.md`**: To replicate a professional team's standards, a `CLAUDE.md` file must be placed in the repository root. This file serves as the project's style guide and context, which Claude automatically respects during code generation and review [1].
*   **Configuration Flexibility**: The action supports advanced configuration via the `claude_args` input, allowing professional teams to enforce specific models (e.g., `claude-opus-4-5-20251101`), set system prompts, and limit execution time (`--max-turns`) for cost and performance control [1].

### Implementation Details

The core of the professional Claude Code setup is the `anthropics/claude-code-action@v1` GitHub Action. The setup can be achieved via the terminal command `/install-github-app` or manually.

### 1. Quick Setup via `/install-github-app`

The `/install-github-app` command, executed within the Claude Code terminal, automates the following steps [1]:
1. Installs the official Claude GitHub App on the selected repository.
2. Configures the necessary repository secrets, primarily `ANTHROPIC_API_KEY`.

### 2. Manual Setup and Required Permissions

For a professional team setup, manual configuration provides greater control over permissions and is recommended for organization-wide policies [2].

**Required GitHub App Permissions:**
The Claude GitHub App requires the following permissions to function correctly for code review and implementation [2]:
| Permission | Access Level | Purpose |
| :--- | :--- | :--- |
| **Contents** | Read & Write | To modify repository files and create commits. |
| **Issues** | Read & Write | To respond to issues and triage. |
| **Pull requests** | Read & Write | To create PRs, comment on reviews, and push changes. |
| **Actions** | Read | Required for Claude to read CI results on PRs. |

**Required Repository Secret:**
*   **Name**: `ANTHROPIC_API_KEY`
*   **Value**: Your Anthropic API key (e.g., `sk-ant-...`)

### 3. Automated Code Review Workflow (`claude.yml`)

The following YAML defines the interactive workflow that enables the `@claude` PR tagging functionality. This file should be placed at `.github/workflows/claude.yml` [3].

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened, assigned, reopened, submitted]
  pull_request:
    types: [opened, assigned, reopened, submitted]

jobs:
  claude:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.review.body, '@claude')) ||
      (github.event_name == 'issues' && (contains(github.event.issue.body, '@claude') || contains(github.event.issue.title, '@claude')))
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read # Required for Claude to read CI results on PRs
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 1

      - name: Run Claude Code
        id: claude
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          # The action automatically detects the mode (interactive or automation)
          # based on the trigger and inputs.
```

### 4. `@claude` PR Tagging Mechanism

The key to the interactive workflow is the `if` condition in the `jobs.claude` section. It ensures the job only runs when an `@claude` mention is present in the body of a new `issue_comment`, `pull_request_review_comment`, or the body/title of a new `issue` [3].

**The `if` condition for `@claude` tagging:**
```
(github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
(github.event_name == 'pull_request_review_comment' && contains(github.event.review.body, '@claude')) ||
(github.event_name == 'issues' && (contains(github.event.issue.body, '@claude') || contains(github.event.issue.title, '@claude')))
```

### 5. Advanced Configuration with `claude_args`

For fine-tuning Claude's behavior, the `claude_args` input allows passing command-line arguments to the underlying Claude Code CLI. This is crucial for setting project-wide system prompts and model selection [1].

**Example of using `claude_args`:**
```yaml
      - name: Run Claude Code with Custom Args
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "/review" # Use a slash command for a specific task
          claude_args: |
            --system-prompt "You are a senior Python engineer. Focus only on security and performance."
            --max-turns 5
            --model claude-opus-4-5-20251101
```

### Best Practices

1. **Establish a Project Standard with `CLAUDE.md`**: Create a `CLAUDE.md` file in the repository root to define coding standards, architectural guidelines, preferred patterns, and review criteria. This file is automatically consumed by the Claude Code Action to ensure all AI-generated code and reviews adhere to team standards [1].
2. **Secure Credentials with GitHub Secrets**: Never hardcode the Anthropic API key. Always store it as a repository secret named `ANTHROPIC_API_KEY` and reference it in the workflow using `${{ secrets.ANTHROPIC_API_KEY }}` [2].
3. **Enforce Consistency with System Prompts**: For automated, non-interactive workflows (e.g., a mandatory PR review), use the `claude_args` input to pass a `--system-prompt` that enforces a consistent tone, focus (e.g., security, performance), and output format for the AI [1].
4. **Implement a Human-in-the-Loop (HITL) Review Process**: While Claude can suggest and implement code, a professional team must maintain oversight. The workflow should be configured to require a human review of Claude's suggestions before merging, treating the AI as a highly capable junior engineer whose work must be verified [1].
5. **Use the Dedicated `/review` Command for Automated PR Checks**: For a professional setup, configure a separate workflow that triggers on `pull_request: [opened, synchronize]` and uses the `prompt: "/review"` input. This ensures every PR receives an automated, comprehensive review without requiring a manual `@claude` tag [1].

### Sources

https://code.claude.com/docs/en/github-actions
https://github.com/anthropics/claude-code-action/blob/main/docs/setup.md
https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml

**Confidence Level:** High

---

## 7. Claude Code verification strategies

### Key Findings

- **Verification is the Core Feedback Loop:** The fundamental strategy, as championed by Boris Cherny, is to "give Claude a way to verify its work," which is reported to increase the quality of the final result by 2-3x. This verification acts as the LLM's primary feedback loop.
- **Two Primary Verification Workflows:** Professional teams utilize two main, verifiable workflows: **Test-Driven Development (TDD)** for functional code, and **Visual Iteration** for front-end code, which uses a **Puppeteer MCP server** to take screenshots and compare against a visual mock.
- **Multi-Agent QA and Review:** The highest level of verification involves **Multi-Claude Workflows**, where one Claude instance is dedicated to writing code, and a second, separate instance is used to independently review, test, and verify the output, effectively simulating a human code review and QA process.
- **Contextual and Automated Verification:** Verification instructions are formalized through **`CLAUDE.md`** files (for general testing context) and **Custom Slash Commands** (e.g., `/fix-github-issue`) which automate multi-step routines that mandate writing and running tests as part of the fix.

### Implementation Details

**1. Test-Driven Development (TDD) Workflow:**
The recommended TDD loop for Claude Code is:
1.  **Ask Claude to write tests** based on expected input/output pairs, explicitly instructing it not to write mock implementations.
2.  **Commit the tests** (e.g., using `Bash(git commit:*)` permission).
3.  **Ask Claude to write code** that passes the newly committed tests, instructing it not to modify the tests. Claude will then iterate (write code, run tests, adjust code) until all tests pass.

**2. Browser/Visual Testing Setup:**
To enable visual verification for front-end development, Claude must be given a tool to take screenshots. This is typically achieved by integrating a **Puppeteer MCP server**.
*   **Tool:** `mcp__puppeteer__puppeteer_navigate`
*   **Workflow:** "Write code, screenshot result, iterate" where Claude compares its output (via screenshot) against a provided visual mock (image file path or pasted image).
*   **Configuration:** The tool must be added to the allowed list via `/permissions` or by editing `.claude/settings.json`.

**3. Automated Verification via Custom Slash Commands:**
Complex, multi-step verification and fix routines are automated using custom slash commands stored in Markdown files (e.g., `.claude/commands/fix-github-issue.md`).

| File: `.claude/commands/fix-github-issue.md` |
| :--- |
| `Please analyze and fix the GitHub issue: $ARGUMENTS.` |
| `Follow these steps:` |
| `1. Use \`gh issue view\` to get the issue details` |
| `...` |
| `4. Implement the necessary changes to fix the issue` |
| `5. **Write and run tests to verify the fix**` |
| `6. **Ensure code passes linting and type checking**` |
| `7. Create a descriptive commit message` |
| `8. Push and create a PR` |

**4. Multi-Claude Verification Workflow:**
To replicate a professional team's separation of duties, a multi-Claude workflow is used:
*   **Instance 1 (The Coder):** Writes the initial code.
*   **Instance 2 (The Reviewer/QA):** Started in a separate terminal (or after a `/clear`), this instance is instructed to review the first Claude's work, run tests, or perform a subjective code review.
*   **Instance 3 (The Integrator):** Reads the code and the review feedback, and edits the code based on the feedback.

**5. Contextual Configuration:**
*   **`CLAUDE.md`:** Used to provide **Testing instructions** and **Code style guidelines** to the LLM's context.
*   **`.mcp.json`:** Used to share MCP server configurations (e.g., Puppeteer, Sentry) across the entire engineering team, ensuring a consistent toolset for verification.

### Best Practices

- **Formalize the Feedback Loop:** Always provide Claude with a clear, verifiable target—such as a failing test suite (TDD) or a visual mock (UI/Browser testing)—before instructing it to write code. This is the single most effective way to improve code quality by 2-3x.
- **Implement Multi-Agent Verification:** For critical tasks, adopt a **Multi-Claude Workflow** where one Claude instance writes the code and a separate, isolated Claude instance is tasked with independent review, testing, or security analysis, mirroring a professional team's code review and QA process.
- **Contextualize Testing Instructions:** Use the **`CLAUDE.md`** file to document project-specific testing instructions, preferred test runners, and code style guidelines. This ensures the LLM has the necessary context for generating and running valid tests.
- **Automate Complex Verification Routines:** Create **Custom Slash Commands** (stored in `.claude/commands/`) for multi-step workflows that include mandatory verification steps, such as the `/fix-github-issue` command which forces the agent to "Write and run tests to verify the fix."
- **Enable Browser Testing via MCP:** Integrate a **Puppeteer MCP server** and allow the `mcp__puppeteer__puppeteer_navigate` tool to enable the "Write code, screenshot result, iterate" workflow, allowing Claude to visually verify its front-end work against a mock.
- **Use Headless Mode for CI/CD:** Leverage Claude Code's headless mode (`claude -p`) in CI/CD pipelines or pre-commit hooks to automate subjective code reviews, issue triage, and linting beyond what traditional tools can detect.

### Sources

https://www.anthropic.com/engineering/claude-code-best-practices
https://www.reddit.com/r/ClaudeAI/comments/1q2c0ne/claude_code_creator_boris_shares_his_setup_with/
https://www.threads.com/@boris_cherny/post/DTBVlMIkpcm/im-boris-and-i-created-claude-code-lots-of-people-have-asked-how-i-use-claude
https://x.com/bcherny/status/2007179850139000872

**Confidence Level:** High

---

## 8. Claude Code Multi-Session Management and Professional Workflow

### Key Findings

- **Cross-Platform Session Continuity:** Claude Code achieves seamless session handoff between the CLI, web, and mobile interfaces using the ampersand (`&`) operator to background tasks to the web and the `claude --teleport <session-id>` command to bring sessions back to the terminal [1].
- **Parallel Multi-Platform Setup:** The recommended professional workflow involves running 15+ parallel Claude sessions across platforms (Terminal, Web, Mobile) to optimize for different tasks, such as active coding in the terminal and visual review on the web [1].
- **Knowledge Compounding via `CLAUDE.md`:** Professional teams maintain a shared, version-controlled `CLAUDE.md` file in their repository to capture project-specific tribal knowledge, coding conventions, and common mistakes, which Claude reads to improve its performance exponentially over time [1].
- **Automated Workflows and Code Hygiene:** Efficiency is driven by custom, shared slash commands (e.g., `/commit-push-pr`) for multi-step processes and automated `PostToolUse` hooks (e.g., running Prettier) to enforce code hygiene immediately after the AI makes an edit [1].
- **Strategic Model Use:** The workflow prioritizes the most capable model (Opus 4.5) for complex tasks, arguing that its higher quality output and fewer required human-steering iterations save more **human time** than faster, less capable models [1].

### Implementation Details

The core of Claude Code's multi-session management revolves around two key mechanisms for cross-platform session continuity: the **ampersand (`&`) operator** and the **`--teleport` command** [1].

### 1. Multi-Session Setup and Coordination
A professional setup involves running multiple parallel sessions across different platforms, each optimized for a specific task [1]:

| Platform | Recommended Use Case | Parallel Instances |
| :--- | :--- | :--- |
| **Terminal (CLI)** | Active coding, file edits, running commands, starting long tasks. | 5+ instances (e.g., numbered tabs 1-5) |
| **Web (`claude.ai/code`)** | Code review, documentation generation, visual diffs, monitoring long-running tasks. | 5-10 sessions |
| **Mobile (iOS/Android)** | Quick prompts, initiating long tasks, checking progress remotely. | As needed |

### 2. Session Handoff: `&` Operator
The ampersand (`&`) operator is used in the Claude Code CLI to **background a task and hand it off to the web interface** for asynchronous processing [1].

**Command Example:**
```bash
# Hand off long-running task to web
> analyze this entire codebase and generate documentation &
```
This command starts the task in the background and makes the session immediately available on the `claude.ai/code` web interface, freeing up the terminal for interactive work [1].

### 3. Session Teleportation: `--teleport` Command
The `--teleport` command is used to **move an active session back to the terminal** from the web or another device, ensuring context continuity [1].

**Command Example:**
```bash
# Teleport session back to terminal
claude --teleport <session-id>
```
The `<session-id>` is a unique identifier (often a UUID) associated with the session, which can be obtained from the web interface or a list of active sessions [1]. This enables **device continuity**, allowing a developer to start a task on a mobile device, monitor it on the web, and then bring it back to their desktop terminal for final interactive steps [1].

### 4. Shared Knowledge and Configuration
Team-wide efficiency is achieved by checking configuration files into Git, ensuring all parallel sessions and team members operate with the same context and rules [1]:

*   **`CLAUDE.md`:** A shared Markdown file checked into the repository's root that contains project-specific knowledge, style guides, and anti-patterns for Claude to read [1].
*   **`.claude/commands/`:** Directory for custom, shared slash commands (e.g., `commit-push-pr.md`) that automate common engineering workflows [1].
*   **`.claude/hooks.json`:** Configuration for automated actions, such as running `npx prettier` after every file edit to enforce code formatting [1].
*   **`.claude/settings.json`:** Used to pre-allow safe Bash commands, enabling auto-approval for common operations like `git status` and `npm test` [1].

### Best Practices

- **Adopt a Multi-Session, Multi-Platform Workflow:** Emulate the 15+ parallel session setup (Terminal, Web, Mobile) to maximize efficiency, dedicating each platform to its optimal use case (e.g., Terminal for active coding, Web for review/documentation, Mobile for quick prompts/long task initiation) [1].
- **Enforce Knowledge Compounding with `CLAUDE.md`:** Maintain a shared, version-controlled `CLAUDE.md` file in the repository to capture tribal knowledge, coding conventions, and common mistakes. This file is read by Claude in every new session, allowing the AI to "learn" and avoid repeated errors, leading to exponential improvement in AI-assisted development [1].
- **Prioritize Planning with a Two-Phase Workflow:** For complex tasks, enforce a "Plan Then Execute" workflow. Use an interactive planning phase to refine the steps with the AI until the plan is perfect, then switch to an automated execution phase. This minimizes human steering time and reduces wasted iterations [1].
- **Automate Inner-Loop Workflows with Slash Commands:** Create custom, shared slash commands (e.g., `/commit-push-pr`) that leverage inline Bash commands (`!``git status`) to pre-compute context. This automates multi-step processes and ensures consistency across the team [1].
- **Implement Smart Permissions Management:** Avoid the `claude --dangerously-skip-permissions` flag. Instead, use the `/permissions` command or a `.claude/settings.json` file to pre-allow a safe list of common commands (e.g., `git status`, `npm test`). This balances convenience for the AI with security and human oversight [1].
- **Use Hooks for Code Hygiene:** Implement `PostToolUse` hooks (e.g., in `.claude/hooks.json`) to automatically run code formatters (like `npx prettier`) after Claude makes an edit. This prevents formatting errors from reaching the CI/CD pipeline and maintains code hygiene [1].
- **Leverage Specialized Subagents:** For domain-specific tasks, configure subagents (e.g., `code-simplifier`) with separate context windows, custom system prompts, and specific tool access. This prevents the main conversation from being polluted and ensures specialized expertise is applied when needed [1].

### Sources

1. https://dev.to/sivarampg/how-the-creator-of-claude-code-uses-claude-code-a-complete-breakdown-4f07

**Confidence Level:** High

---

## 9. Claude Code Plan Mode and Professional Workflows

### Key Findings

*   **Plan Mode and Auto-Accept Mode are the core of the professional workflow.** The `Shift+Tab` shortcut cycles between Normal, Auto-Accept (`⏵⏵ accept edits on`), and Plan Mode (`⏸ plan mode on`). The recommended workflow is to start in Plan Mode for analysis and planning, and then switch to Auto-Accept Mode for uninterrupted execution.
*   **The Plan-First approach is critical for complex tasks.** Claude Code creator Boris Cherny emphasizes starting most sessions in Plan Mode, refining the plan with follow-up questions, and only then switching to Auto-Accept Mode for a "1-shot" implementation, which significantly increases success rate.
*   **Compounding Engineering is achieved through a shared `CLAUDE.md` file.** Professional teams maintain a version-controlled `CLAUDE.md` to document instances where Claude made a mistake, effectively training the model to avoid those errors in the future and building a collective knowledge base.
*   **Verification is the single most important factor for quality.** The best practice is to always give Claude a way to verify its work (e.g., running tests, checking UI), which acts as a crucial feedback loop that can 2-3x the quality of the final result.
*   **Permission Hygiene and Automation are key to efficiency.** Teams use custom slash commands for repetitive tasks (e.g., `/commit-push-pr`) and pre-allow safe commands via the `/permissions` feature and shared `.claude/settings.json` to minimize interruptions.

### Implementation Details

The core of the professional Claude Code setup revolves around three key permission modes, workflow automation, and shared configuration files.

### 1. Permission Mode Cycling (`Shift+Tab`)
The `Shift+Tab` shortcut is the primary control for permission hygiene, cycling through three modes:
| Mode | Indicator | Function | Activation |
| :--- | :--- | :--- | :--- |
| **Normal Mode** | N/A | Requires explicit user confirmation for every file edit or command execution. | Default, or after Plan Mode. |
| **Auto-Accept Mode** | `⏵⏵ accept edits on` | Eliminates confirmation prompts for file edits, allowing for seamless execution of a pre-approved plan. | 1st `Shift+Tab` press from Normal Mode. |
| **Plan Mode** | `⏸ plan mode on` | Read-only mode for safe code analysis, exploration, and detailed plan generation. No file edits or commands are executed. | 2nd `Shift+Tab` press from Normal Mode. |

### 2. CLI and Default Configuration
- **Start in Plan Mode:** A new session can be explicitly started in Plan Mode using the CLI flag:
  ```bash
  claude --permission-mode plan
  ```
- **Set Default Mode:** For a plan-first approach, the default mode can be configured in the shared settings file:
  ```json
  // .claude/settings.json
  {
    "permissions": {
      "defaultMode": "plan"
    }
  }
  ```
- **Shared Permissions:** Pre-approved, safe bash commands can be shared across the team via the same settings file to avoid unnecessary permission prompts:
  ```bash
  /permissions allow <command>
  ```

### 3. PR Planning Workflow
The recommended workflow for complex changes (like refactoring or new features) is a two-stage process:
1.  **Planning (Plan Mode):** Start the session in Plan Mode and prompt Claude with the goal (e.g., `I need to refactor our authentication system to use OAuth2. Create a detailed migration plan.`). Refine the plan with follow-up questions until satisfactory.
2.  **Execution (Auto-Accept Mode):** Once the plan is solid, switch to Auto-Accept Mode (`Shift+Tab` once) for a "1-shot" execution of the plan.

### 4. Team Knowledge and Automation
- **Team Knowledge Base:** A shared `CLAUDE.md` file is checked into git and used to document past Claude errors, acting as a guardrail for future sessions.
- **Custom Slash Commands:** Workflows like creating a commit, pushing, and opening a PR are automated using custom slash commands (e.g., `/commit-push-pr`) stored in the `.claude/commands/` directory. These commands often use inline bash to pre-compute necessary information.

### Best Practices

1. **Adopt the Plan-First Workflow:** For any non-trivial task, start in Plan Mode (`Shift+Tab` twice) to force Claude to analyze the codebase and create a detailed, multi-step plan. Only switch to Auto-Accept Mode (`Shift+Tab` once) for "1-shot" execution after the plan has been thoroughly reviewed and refined.
2. **Implement Compounding Engineering:** Maintain a shared, version-controlled `CLAUDE.md` file within the repository. The team must continuously update this file with examples of incorrect Claude behavior to serve as a collective, self-correcting knowledge base.
3. **Prioritize Verification:** Integrate robust verification steps into every workflow. This can range from simple bash commands to running full test suites or using the Claude Chrome extension to test UI changes, ensuring a critical feedback loop for quality.
4. **Automate the Inner Loop:** Create and share custom slash commands (e.g., `/commit-push-pr`) for all repetitive, high-frequency developer tasks. Store these commands in `.claude/commands/` and check them into version control.
5. **Enforce Permission Hygiene:** Avoid using the `--dangerously-skip-permissions` flag. Instead, use the `/permissions` command to pre-allow common, safe bash commands and share this configuration in `.claude/settings.json` to maintain security while reducing interruptions.
6. **Use Post-Tool-Use Hooks:** Implement a `PostToolUse hook` to automatically format code after Claude's edits, handling the final 10% of formatting to prevent CI/CD pipeline failures due to style inconsistencies.
7. **Leverage Parallelism:** Run multiple Claude sessions concurrently (terminal and web) to maximize throughput, using system notifications to manage input needs across sessions.

### Sources

https://code.claude.com/docs/en/common-workflows
https://www.threads.com/@boris_cherny/post/DKxKMUjPYty/how-to-use-plan-mode-with-shift-tab-pr-planning-workflows-auto-accept-edits-mode-planning-best-practices
https://www.reddit.com/r/ClaudeAI/comments/1q2c0ne/claude_code_creator_boris_shares_his_setup_with/

**Confidence Level:** High

---

## 10. Professional Software Engineering Practices for Agentic Coding (Claude Code Setup)

### Key Findings

*   **Team-wide Documentation and Context:** The core mechanism for sharing context is the **`CLAUDE.md`** file, which is checked into Git and automatically ingested by the agent. It documents code style, repository etiquette, custom bash commands, and developer environment setup, ensuring a consistent operational environment for all agents and engineers [1].
*   **Compounding Engineering (CE):** This is the key efficiency and learning mechanism, structured as a four-step loop: **Plan → Work → Assess → Compound** [2]. The "Compound" step codifies lessons learned (bugs, performance issues) into agent-readable rules/prompts (e.g., custom slash commands or updates to `CLAUDE.md`), making every change a permanent, shared lesson for the entire team [2].
*   **Efficiency Tracking and Planning:** Efficiency is maximized by dedicating resources to the "Plan" phase, using Claude's **thinking budget** commands (`think`, `ultrathink`) to allocate more computation time for complex problem-solving. The "Assess" phase uses **parallel subagents** (up to 12) to review code from multiple perspectives (security, performance, complexity) for advanced quality tracking [2].
*   **Shared Configurations:** Team-wide standardization is achieved by checking agent configuration files (`.claude/settings.json` for tool allowlists and `.mcp.json` for shared Model Context Protocol servers) into source control. This ensures all agents have the same capabilities and access to team tools [1].

### Implementation Details

**1. Team-wide Context and Documentation (`CLAUDE.md`)**
The core of the shared setup is the `CLAUDE.md` file, which is checked into the root of the repository. This file serves as the agent's primary source of project-specific knowledge and team standards.

```markdown
# CLAUDE.md - Team Standards and Context

## Code Style Guidelines
- Use ES modules (import/export) syntax, not CommonJS (require).
- Destructure imports when possible (e.g., import { foo } from 'bar').

## Repository Etiquette
- Branch naming convention: feature/JIRA-123-short-description
- Prefer rebase over merge for pull requests.

## Custom Bash Commands
- npm run build: Build the project for production.
- npm run typecheck: Run the team's standard typechecker.
```

**2. Shared Agent and Tool Configuration**
Agent permissions and tool access are standardized across the team by checking configuration files into Git.

*   **Permissions (`.claude/settings.json`):**
    ```json
    {
      "allowedTools": [
        "Edit",
        "Bash(git commit:*)",
        "mcp__puppeteer__puppeteer_navigate"
      ]
    }
    ```
*   **MCP Server Configuration (`.mcp.json`):**
    ```json
    {
      "servers": [
        {
          "name": "sentry",
          "config": {
            "url": "https://sentry.team.com/api"
          }
        }
      ]
    }
    ```

**3. Compounding Engineering Rules (Custom Slash Commands)**
Learnings are codified as custom slash commands in the `.claude/commands` folder, making them available team-wide.

*   **File:** `.claude/commands/fix-github-issue.md`
*   **Command:** `/project:fix-github-issue <issue_number>`
*   **Content:**
    ```markdown
    Please analyze and fix the GitHub issue: $ARGUMENTS.

    Follow these steps:
    1. Use `gh issue view` to get the issue details.
    2. Understand the problem described in the issue.
    3. Search the codebase for relevant files.
    4. Implement the necessary changes to fix the issue.
    5. Write and run tests to verify the fix.
    6. Ensure code passes linting and type checking (Compounding Rule: Always run typecheck before commit).
    7. Create a descriptive commit message.
    8. Push and create a PR.
    ```

**4. Shared Code Hygiene Enforcement (Git Hooks)**
While not a Claude Code feature, professional teams enforce code hygiene via shared Git hooks. Using the `pre-commit` framework with a shared configuration file is a common approach.

*   **File:** `.pre-commit-config.yaml`
    ```yaml
    repos:
      - repo: https://github.com/pre-commit/pre-commit-hooks
        rev: v4.4.0
        hooks:
          - id: trailing-whitespace
          - id: end-of-file-fixer
          - id: check-yaml
      - repo: https://github.com/psf/black
        rev: 23.3.0
        hooks:
          - id: black
    ```

### Best Practices

1. **Codify Learnings as Prompts:** Implement the "Compound" step of Compounding Engineering by automatically or semi-automatically converting post-mortem analysis, code review comments, and bug fixes into new rules or instructions. These rules should be stored as agent-readable prompts (e.g., in `CLAUDE.md` or custom slash commands) and checked into the repository.
2. **Centralize Configuration:** Check all agent and tool configurations (`CLAUDE.md`, `.claude/settings.json`, `.mcp.json`) into Git to ensure every team member and every agent session operates with the same context and permissions. This is the foundation of a shared professional setup.
3. **Enforce Code Hygiene with Agents:** Use the "Assess" step of the Compounding Engineering loop, employing multiple specialized subagents (e.g., security, performance, complexity) to review code in parallel. This goes beyond simple linting to enforce deeper, context-aware code hygiene.
4. **Prioritize Planning:** Adopt the "Explore, Plan, Code, Commit" or "Plan → Work → Assess → Compound" workflows. Dedicate significant time and computational resources (e.g., using Claude's `ultrathink` command) to the planning phase to build a shared mental model and reduce costly rework in later stages.
5. **Standardize Git Hooks:** Use tools like `pre-commit` with a shared `.pre-commit-config.yaml` checked into the repository to enforce team-wide standards (linting, formatting, security checks) before code is committed. This ensures a baseline of code hygiene is met by both human and agent-generated code.

### Sources

https://www.anthropic.com/engineering/claude-code-best-practices
https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents
https://github.com/EveryInc/compound-engineering-plugin
https://www.viget.com/articles/two-ways-to-share-git-hooks-with-your-team
https://naveira.dev/posts/enhancing-engineering-practices-centralized-eslint-configuration/

**Confidence Level:** High

---

