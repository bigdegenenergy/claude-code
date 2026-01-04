---
description: "Context management and session hygiene"
---

# Context Management Guide

## Understanding Context Limits

- Claude Code has a ~200k token context window
- Auto-compact triggers at **~95% capacity** (not 60%)
- By 95%, you've lost control over what gets summarized
- Run `/compact` manually at **~70%** for better control

## Session Commands Quick Reference

| Command | Purpose |
|---------|---------|
| `/context` | Check current usage (run often!) |
| `/clear` | Full reset for fresh start |
| `/compact` | Summarize and continue |
| `/compact focus on X` | Summarize with custom focus |
| `/cost` | View session cost statistics |

## Hygiene Practices

### During Long Sessions

1. Run `/context` every 15-20 minutes
2. At 70% capacity, run `/compact`
3. Between workflow phases, use `/clear`
4. Disable unused MCP servers: `/mcp`

### Multi-Phase Tasks

Use the **Document & Clear** pattern:

```
1. "Write current progress to PROGRESS.md"
2. /clear
3. "Read PROGRESS.md and continue from step 4"
```

This gives Claude fresh context while preserving knowledge.

## What Consumes Context

| Item | Tokens | Mitigation |
|------|--------|------------|
| Large file reads | 1k-10k+ | Read specific sections |
| MCP server tools | 50-1k each | Disable unused servers |
| Long conversations | Cumulative | Use /clear between phases |
| Error stacktraces | 500-2k | Truncate when sharing |

## Warning Signs

- Claude forgetting earlier instructions
- Repeated questions about things already discussed
- Slower responses
- Missing details in outputs

When you notice these, run `/context` and consider `/compact` or `/clear`.
