---
description: "When to use extended thinking triggers"
---

# Thinking Triggers Guide

## Budget Levels

| Trigger | Budget | Cost Multiplier |
|---------|--------|-----------------|
| `think` | ~4,000 tokens | 1.5x |
| `think hard` / `megathink` | ~10,000 tokens | 3x |
| `think harder` / `ultrathink` | ~32,000 tokens | 8x |

## When to Use Each Level

### `think` (~4k tokens)
- Simple bug fixes
- Routine refactoring
- Error handling improvements
- Adding comments or documentation
- Small feature additions

### `think hard` (~10k tokens)
- Multi-step algorithms
- Caching strategy design
- API endpoint design
- Database schema changes
- Complex state management
- Migration planning

### `ultrathink` (~32k tokens)
- Major architectural decisions
- Comprehensive security audits
- Full codebase refactors
- Complex debugging (multi-file, unclear root cause)
- Performance optimization strategies
- System design for new features

## Anti-Patterns

- **Don't use ultrathink for everything** - it's expensive and slow
- **Don't use think for complex tasks** - insufficient reasoning budget
- **Don't combine triggers** - "ultrathink harder" doesn't work

## Tips

- Start with `think`, escalate if Claude seems stuck
- Use with `/plan` for architecture: "think hard about the best approach"
- Combine with verbose mode (`Ctrl+O`) to see reasoning
- Trust Claude to know when more thinking would help
