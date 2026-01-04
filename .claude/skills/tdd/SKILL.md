---
name: tdd
description: "Use when the user asks to write tests first, do TDD, red-green-refactor, or implement a feature test-first. This skill guides test-driven development."
allowed-tools: Read,Write,Edit,Bash,Grep,Glob
version: 1.0.0
---

# Test-Driven Development (TDD)

## Purpose

Guide the user through the Red-Green-Refactor cycle for developing features with tests first.

## When to Use

- User asks to "write tests first"
- User mentions "TDD" or "test-driven"
- User wants "red-green-refactor" approach
- User asks to implement something "test-first"

## The TDD Cycle

### 1. RED: Write a Failing Test

```
Think about the smallest piece of behavior to implement.
Write a test that describes that behavior.
Run the test - it MUST fail.
If it passes, the test is wrong or the feature exists.
```

### 2. GREEN: Make It Pass

```
Write the MINIMUM code to make the test pass.
Don't add extra features.
Don't refactor yet.
Just make it green.
```

### 3. REFACTOR: Clean Up

```
Now improve the code.
Extract common patterns.
Improve naming.
Remove duplication.
Run tests after each change - stay green.
```

## Critical Rules

1. **Never write production code without a failing test first**
2. **Write only enough test code to fail** - no more
3. **Write only enough production code to pass** - no more
4. **Refactor only when tests are green**
5. **Run tests frequently** - after every small change

## Test Quality Checklist

- [ ] Test describes behavior, not implementation
- [ ] Test name explains what should happen
- [ ] Test has single assertion (ideally)
- [ ] Test is independent of other tests
- [ ] Test would catch regressions

## Anti-Patterns to Avoid

- Writing tests after code (that's not TDD)
- Writing multiple tests before any code
- Making tests pass by returning hardcoded values
- Skipping the refactor step
- Testing implementation details

## Commands

- Run tests: Check project's test runner (npm test, pytest, etc.)
- For guided TDD: Use `/test-driven` slash command
