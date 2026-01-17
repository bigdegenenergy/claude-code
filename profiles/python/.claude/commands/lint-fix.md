---
description: Run ruff and black to fix all linting and formatting issues
allowed-tools: Bash(ruff*), Bash(black*), Bash(pip*), Read(*), Glob(*)
---

# Python Lint & Format Fixer

Automatically fix linting issues with ruff and format code with black.

## Command

```bash
ruff check . --fix && black .
```

## Process

1. **Check Tools Availability**

   ```bash
   which ruff black || pip install --no-input ruff black
   ```

2. **Run Ruff with Auto-Fix**

   ```bash
   ruff check . --fix
   ```

   Ruff will:
   - Fix import sorting (I)
   - Remove unused imports (F401)
   - Fix simple code issues (E, W)
   - Apply safe transformations

3. **Run Black Formatter**

   ```bash
   black .
   ```

   Black will:
   - Format all Python files
   - Ensure consistent style
   - Wrap long lines

4. **Verify No Remaining Issues**
   ```bash
   ruff check . && black --check .
   ```

## What Gets Fixed

### Ruff Fixes

- Import sorting and organization
- Unused imports removal
- Trailing whitespace
- Missing newlines at end of file
- Simple code style issues

### Black Fixes

- Line length (default 88 chars)
- String quote consistency
- Trailing commas
- Bracket/parenthesis formatting
- Whitespace around operators

## Configuration

If the project has `pyproject.toml`, ruff and black will use those settings.

Default configuration if none exists:

```toml
[tool.ruff]
line-length = 100
select = ["E", "F", "I", "N", "W"]
ignore = ["E501"]  # Let black handle line length

[tool.black]
line-length = 100
```

## Check Mode (No Changes)

To see what would be changed without modifying files:

```bash
ruff check . && black --check --diff .
```

## Type Checking (Optional)

After fixing lint/format, optionally run type checking:

```bash
mypy src/ --ignore-missing-imports
```

## Troubleshooting

### Ruff Not Found

```bash
pip install --no-input ruff
```

### Black Conflicts with Existing Style

```bash
# Check current black config
black --version
cat pyproject.toml | grep -A5 "\[tool.black\]"
```

### Ignoring Specific Rules

```python
# Ignore specific line
x = 1  # noqa: E501

# Ignore block
# fmt: off
matrix = [
    [1, 0, 0],
    [0, 1, 0],
    [0, 0, 1],
]
# fmt: on
```
