# Python Development Profile

> **Language Profile**: Python 3.10+ with modern tooling (ruff, black, pytest, mypy)

This profile provides Claude Code with Python-specific conventions, commands, and skills optimized for both CLI and web environments.

## Project Structure

A well-organized Python project should follow this structure:

```
my-project/
├── src/
│   └── mypackage/
│       ├── __init__.py
│       └── main.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   └── test_main.py
├── requirements.txt       # Production dependencies
├── requirements-dev.txt   # Development dependencies
├── pyproject.toml         # Project configuration
├── .python-version        # Python version (pyenv)
├── .claude/               # Claude Code configuration
│   ├── settings.json
│   ├── commands/
│   └── skills/
└── CLAUDE.md
```

## Build / Run / Test Commands

### Installation

```bash
# Production dependencies
pip install --no-input -r requirements.txt

# Development dependencies (includes testing tools)
pip install --no-input -r requirements-dev.txt

# Install package in editable mode
pip install --no-input -e .
```

### Running

```bash
# Run main script
python -m mypackage.main

# Run with environment variables
DATABASE_URL=sqlite:///db.sqlite python -m mypackage.main

# Run specific function
python -c "from mypackage import main; main.run()"
```

### Testing

```bash
# Run all tests with verbose output
pytest -v --maxfail=1

# Run with coverage
pytest --cov=src --cov-report=term-missing

# Run specific test file
pytest tests/test_main.py -v

# Run specific test function
pytest tests/test_main.py::test_function_name -v

# Run tests matching pattern
pytest -k "test_user" -v
```

### Linting & Formatting

```bash
# Lint with auto-fix
ruff check . --fix

# Format with black
black .

# Type checking
mypy src/ --ignore-missing-imports

# All checks (CI style)
ruff check . && black --check . && mypy src/
```

## Slash Commands

This profile includes the following commands:

| Command     | Description                          |
| ----------- | ------------------------------------ |
| `/test`     | Run pytest with concise output       |
| `/lint-fix` | Run ruff and black to fix all issues |

## Skills

| Skill     | Description                                                          |
| --------- | -------------------------------------------------------------------- |
| `add-dep` | Safely install a package, verify import, and pin to requirements.txt |

## Web Environment Compatibility

When running in Claude Code Web (headless environment):

### ALWAYS Use Non-Interactive Flags

```bash
# GOOD - headless compatible
pip install --no-input package
pytest -v --tb=short --maxfail=3

# BAD - may prompt
pip install package
```

### Save Plots to Files

```python
# GOOD - save to file
import matplotlib.pyplot as plt
plt.plot(data)
plt.savefig('output.png')
plt.close()

# BAD - will hang in headless
plt.show()
```

### No Interactive Input

```python
# GOOD - use environment or defaults
config = os.environ.get("CONFIG", "default")

# BAD - will hang forever
config = input("Enter config: ")
```

## Code Conventions

### Imports

```python
# Standard library
import os
import sys
from pathlib import Path

# Third-party
import requests
from pydantic import BaseModel

# Local
from mypackage.utils import helper
```

### Type Hints

Always use type hints for function signatures:

```python
def process_data(items: list[str], count: int = 10) -> dict[str, int]:
    """Process items and return counts."""
    return {item: len(item) for item in items[:count]}
```

### Error Handling

```python
# Specific exceptions, not bare except
try:
    result = api_call()
except requests.RequestException as e:
    logger.error(f"API call failed: {e}")
    raise

# Context managers for resources
with open("file.txt") as f:
    content = f.read()
```

### Logging

```python
import logging

logger = logging.getLogger(__name__)

# Use appropriate levels
logger.debug("Detailed debugging info")
logger.info("General operational info")
logger.warning("Something unexpected")
logger.error("Error occurred")
```

## Testing Conventions

### Test Structure

```python
# tests/test_user.py
import pytest
from mypackage.user import User, create_user

class TestUser:
    """Tests for User class."""

    def test_user_creation(self):
        """User can be created with name and email."""
        user = User(name="Test", email="test@example.com")
        assert user.name == "Test"
        assert user.email == "test@example.com"

    def test_user_validation_fails_for_invalid_email(self):
        """User creation fails with invalid email."""
        with pytest.raises(ValueError, match="Invalid email"):
            User(name="Test", email="invalid")
```

### Fixtures

```python
# tests/conftest.py
import pytest

@pytest.fixture
def sample_user():
    """Provide a sample user for tests."""
    return User(name="Test User", email="test@example.com")

@pytest.fixture
def db_session():
    """Provide a test database session."""
    session = create_test_session()
    yield session
    session.rollback()
    session.close()
```

### Parameterized Tests

```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("World", "WORLD"),
    ("", ""),
])
def test_uppercase(input, expected):
    assert input.upper() == expected
```

## Dependency Management

### requirements.txt

```text
# Pin exact versions for reproducibility
requests==2.31.0
pydantic==2.5.0
sqlalchemy==2.0.23
```

### requirements-dev.txt

```text
-r requirements.txt

# Testing
pytest==7.4.3
pytest-cov==4.1.0

# Linting & Formatting
ruff==0.1.6
black==23.11.0
mypy==1.7.0
```

### pyproject.toml

```toml
[project]
name = "mypackage"
version = "0.1.0"
requires-python = ">=3.10"

[tool.ruff]
line-length = 100
select = ["E", "F", "I", "N", "W"]

[tool.black]
line-length = 100

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --tb=short"

[tool.mypy]
python_version = "3.10"
strict = true
```

## GitHub Actions Integration

This profile includes a GitHub Action workflow (`.github/workflows/claude-python.yml`) for automated CI with Claude Code in headless mode.

## Usage

To use this profile:

1. Copy the contents of `profiles/python/` to your project root
2. Adjust `CLAUDE.md` for your specific project
3. Update `requirements.txt` with your dependencies
4. Run `/test` to verify setup

```bash
# From the claude-code repo
cp -r profiles/python/* /path/to/your/project/
```
