---
description: "Universal code style rules for all languages"
---

# Code Style Rules

## Universal Principles

1. **Prefer clarity over cleverness** - readable code beats clever one-liners
2. **Consistent naming** - follow language conventions (camelCase for JS/TS, snake_case for Python)
3. **Small functions** - each function does one thing well (<30 lines ideal)
4. **Early returns** - reduce nesting by returning early on edge cases
5. **Meaningful names** - avoid single-letter variables except in loops

## Formatting

- Use project's configured formatter (Prettier, Black, gofmt, etc.)
- PostToolUse hook auto-formats on save - don't fight it
- No trailing whitespace
- Files end with single newline

## Comments

- Comment **why**, not **what**
- Don't add comments to unchanged code during edits
- Delete commented-out code, don't leave it
- Use `TODO:` prefix for planned improvements

## Anti-Patterns

- No `any` type in TypeScript (use `unknown` if needed)
- No hardcoded configuration values
- No magic numbers without named constants
- No nested ternaries beyond 2 levels
