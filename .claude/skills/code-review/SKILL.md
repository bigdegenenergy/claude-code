---
name: code-review
description: "Use when the user asks to review code, critique changes, find issues, or provide feedback on code quality. This skill performs thorough code reviews."
allowed-tools: Read,Grep,Glob,Bash
version: 1.0.0
---

# Code Review

## Purpose

Perform thorough, constructive code reviews that improve code quality and catch issues before they reach production.

## When to Use

- User asks to "review this code"
- User wants "feedback on changes"
- User asks to "find issues" or "critique"
- Before merging a PR
- After completing a feature

## Review Process

### 1. Understand Context

```
- What problem does this code solve?
- What files were changed?
- Is there a related issue or ticket?
```

### 2. Check Correctness

```
- Does the code do what it claims to do?
- Are edge cases handled?
- Are there potential bugs?
```

### 3. Review Code Quality

```
- Is the code readable and maintainable?
- Are names descriptive?
- Is complexity appropriate?
```

### 4. Security & Performance

```
- Are there security vulnerabilities?
- Are there performance issues?
- Is user input validated?
```

## Checklist

### Functionality
- [ ] Code solves the stated problem
- [ ] Edge cases are handled
- [ ] Error handling is appropriate
- [ ] No obvious bugs

### Code Quality
- [ ] Code is readable and self-documenting
- [ ] Functions are small and focused
- [ ] No unnecessary complexity
- [ ] No code duplication
- [ ] Naming is clear and consistent

### Security
- [ ] User input is validated
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Secrets are not hardcoded
- [ ] Authentication/authorization is correct

### Performance
- [ ] No N+1 query problems
- [ ] No memory leaks
- [ ] Appropriate data structures used
- [ ] No unnecessary computation

### Tests
- [ ] Tests cover new functionality
- [ ] Tests are meaningful (not just for coverage)
- [ ] Edge cases are tested

## Feedback Guidelines

**Be Constructive**: Explain the "why" behind suggestions.

```
Bad: "This is wrong."
Good: "This could cause a null pointer exception when user is undefined. Consider adding a guard clause."
```

**Be Specific**: Point to exact lines and provide examples.

```
Bad: "Improve error handling."
Good: "Line 45: Catching all errors silently. Consider logging the error or re-throwing for visibility."
```

**Prioritize Issues**:
- 🔴 **Blocker**: Must fix before merge (bugs, security issues)
- 🟡 **Suggestion**: Should consider (code quality, maintainability)
- 🟢 **Nitpick**: Minor (style, naming preferences)

## Commands

- For read-only review: Use `/review` slash command
- For review with suggestions: Use `@code-reviewer` agent
