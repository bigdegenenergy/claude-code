# Tests

This directory contains tests for the claude-engineer-hooks project.

## Running Tests

### Run all tests with pytest (recommended)
```bash
pytest tests/
```

### Run a specific test file
```bash
pytest tests/test_validators.py
```

### Run tests directly (without pytest)
```bash
python3 tests/test_validators.py
```

## Test Files

- `test_validators.py` - Tests for the validators module in `.claude/hooks/validators.py`

## Adding New Tests

When adding new functionality to the hooks, please:
1. Create corresponding test files in this directory
2. Follow the naming convention `test_*.py`
3. Use pytest-compatible test functions (starting with `test_`)
4. Include docstrings explaining what each test validates
