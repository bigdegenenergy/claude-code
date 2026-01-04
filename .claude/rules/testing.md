---
description: "Testing requirements and patterns"
---

# Testing Rules

## Test Requirements

1. **All new features must have tests** - no exceptions
2. **Bug fixes require regression tests** - prove the fix works
3. **Run tests before committing** - use `/qa` or `/test-and-commit`

## Test Structure

```
describe('ComponentName', () => {
  describe('methodName', () => {
    it('should do X when Y', () => {
      // Arrange
      // Act
      // Assert
    });
  });
});
```

## Best Practices

- **Test behavior, not implementation** - tests survive refactoring
- **One assertion per test** - easier to identify failures
- **Use descriptive test names** - `it('should return null when user not found')`
- **Isolate tests** - no shared state between tests
- **Mock external services** - tests should run offline

## Coverage Guidelines

- Aim for **80%+ coverage** on business logic
- **100% coverage** on critical paths (auth, payments, security)
- Don't chase coverage numbers with trivial tests

## Red-Green-Refactor (TDD)

1. **Red**: Write failing test first
2. **Green**: Write minimum code to pass
3. **Refactor**: Clean up without breaking tests

Use `/test-driven` command for guided TDD workflow.
