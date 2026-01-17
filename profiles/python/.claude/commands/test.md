---
description: Run pytest with concise, CI-friendly output
allowed-tools: Bash(pytest*), Bash(python*), Read(*), Glob(*)
---

# Python Test Runner

Run the test suite with pytest using concise output suitable for both CLI and web environments.

## Command

```bash
pytest -v --tb=short --maxfail=3
```

## Options Explained

- `-v`: Verbose test names (see which tests run)
- `--tb=short`: Short traceback format (saves tokens in web)
- `--maxfail=3`: Stop after 3 failures (fail fast)

## Process

1. **Run Tests**

   ```bash
   pytest -v --tb=short --maxfail=3
   ```

2. **If Tests Fail**:
   - Analyze the failure output
   - Identify the root cause
   - Fix the failing test or code
   - Re-run to verify fix

3. **If Tests Pass**:
   - Report success with summary
   - Suggest running with coverage if appropriate

## Coverage Mode

To run with coverage reporting:

```bash
pytest --cov=src --cov-report=term-missing --tb=short
```

## Running Specific Tests

```bash
# Single file
pytest tests/test_specific.py -v --tb=short

# Single test function
pytest tests/test_specific.py::test_function -v --tb=short

# Tests matching pattern
pytest -k "test_user" -v --tb=short
```

## Troubleshooting

### ModuleNotFoundError

```bash
# Install package in editable mode
pip install --no-input -e .
```

### Missing Dependencies

```bash
pip install --no-input -r requirements-dev.txt
```

### Slow Tests

```bash
# Run with timing info
pytest -v --tb=short --durations=10
```
