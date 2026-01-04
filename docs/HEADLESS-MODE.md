# Headless Mode & CI/CD Integration

This guide covers using Claude Code in headless mode for automation, CI/CD pipelines, and batch processing.

## Basic Headless Usage

### The `-p` Flag

```bash
# Simple one-shot task
claude -p "Update copyright headers to 2026"

# With JSON output
claude -p "Find bugs in src/utils.ts" --output-format json

# Pipe input to Claude
cat error.log | claude -p "Analyze these errors"

# With specific permissions
claude -p "Fix failing test" --allowedTools Edit,Bash,Read
```

### Output Formats

| Format | Use Case |
|--------|----------|
| `text` | Human-readable output (default) |
| `json` | Structured output for parsing |
| `stream-json` | Real-time JSON events |

```bash
# JSON for scripting
result=$(claude -p "Count TODO comments" --output-format json)
count=$(echo "$result" | jq '.result')
```

## Key Flags

| Flag | Purpose |
|------|---------|
| `-p`, `--print` | Enable headless mode |
| `--output-format` | text/json/stream-json |
| `--allowedTools` | Pre-approve specific tools |
| `--append-system-prompt` | Add custom instructions |
| `--max-turns` | Limit Claude invocations |
| `--dangerously-skip-permissions` | Skip all permission prompts (use in containers only) |

## Common Patterns

### Pattern 1: Fanning Out

Process multiple files in parallel:

```bash
#!/bin/bash
# Migrate all TypeScript files to new API
for file in $(find src -name "*.ts"); do
  claude -p "Migrate $file to new API v2" \
    --allowedTools "Edit,Read" \
    --output-format json &
done
wait
```

### Pattern 2: Pipelining

Chain Claude calls:

```bash
# Analyze → Summarize → Report
cat error.log | \
  claude -p "Extract unique errors" | \
  claude -p "Summarize and prioritize" | \
  claude -p "Format as markdown report" > report.md
```

### Pattern 3: Code Review Pipeline

```bash
# Get changed files and review each
git diff --name-only main | while read file; do
  claude -p "Review $file for bugs and security issues" \
    --allowedTools "Read,Grep" \
    --output-format json >> reviews.json
done
```

## GitHub Actions Integration

### Using claude-code-action

```yaml
name: Claude Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "Review this PR for bugs and security issues"
          claude_args: "--max-turns 5"
```

### Custom Headless Workflow

```yaml
name: Auto-fix Linting
on:
  push:
    branches: [main]

jobs:
  fix:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Fix linting issues
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude -p "Fix all ESLint errors in src/" \
            --allowedTools "Edit,Read,Bash(npm:*)" \
            --max-turns 10

      - name: Commit fixes
        run: |
          git config user.name "Claude Code"
          git config user.email "claude@example.com"
          git add -A
          git diff --staged --quiet || git commit -m "fix: auto-fix linting issues"
          git push
```

## Safe YOLO Mode

For isolated environments (containers, sandboxes), you can skip all permission prompts:

```bash
# Run in a network-isolated container
docker run --network none \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v $(pwd):/workspace \
  claude-code-image \
  claude -p "Refactor the codebase" \
    --dangerously-skip-permissions \
    --allowedTools "Edit,Read,Bash(npm:*)"
```

**Warning**: Only use `--dangerously-skip-permissions` in:
- Network-isolated containers
- Disposable VMs
- Sandboxed environments

Never use in production or with access to sensitive data.

## Visual Iteration Workflow

For UI development, combine headless mode with Playwright MCP:

```bash
# 1. Implement from design
claude -p "Implement this design: @mockup.png"

# 2. Screenshot result (requires Playwright MCP)
claude -p "Screenshot localhost:3000 and save to result.png"

# 3. Compare and iterate
claude -p "Compare mockup.png with result.png, fix differences"
```

### Setup Playwright MCP

```json
// .mcp.json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/playwright-mcp"]
    }
  }
}
```

## Tips for Effective Headless Use

1. **Be specific**: Vague prompts produce vague results
2. **Limit scope**: One task per invocation
3. **Set max-turns**: Prevent runaway loops
4. **Use allowedTools**: Minimize permissions
5. **Parse JSON output**: More reliable than text parsing
6. **Log everything**: Debug issues in CI/CD

## Troubleshooting

### Claude times out
```bash
# Increase timeout (default 2 min)
claude -p "Long task" --timeout 300000
```

### Permission denied errors
```bash
# Explicitly allow needed tools
claude -p "Fix tests" --allowedTools "Edit,Read,Bash(npm:test)"
```

### Output too long
```bash
# Use JSON and extract what you need
claude -p "Analyze codebase" --output-format json | jq '.result | .[0:500]'
```
