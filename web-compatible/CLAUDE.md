# Claude Code Web - Headless Configuration

> **Web Environment Profile** - Optimized for ephemeral, non-interactive sessions.

This configuration is designed for **Claude Code Web** (browser-based, headless) environments where:

- Sessions are ephemeral and may restart at any time
- Interactive prompts will block execution indefinitely
- Token efficiency matters (avoid verbose logs)
- GUI operations are not possible

## Headless Optimizations

### 1. No Interaction - ALWAYS Use Non-Interactive Flags

**CRITICAL**: The web environment cannot accept interactive input. Commands that prompt for confirmation will hang forever.

| Tool   | Interactive       | Headless (USE THIS)                                |
| ------ | ----------------- | -------------------------------------------------- |
| pip    | `pip install pkg` | `pip install --no-input pkg`                       |
| npm    | `npm install`     | `npm ci --silent` or `npm install --yes`           |
| apt    | `apt install pkg` | `apt-get install -y pkg`                           |
| Maven  | `mvn install`     | `mvn install -B` (batch mode)                      |
| Gradle | `gradle build`    | `gradle build --no-daemon -q`                      |
| pytest | `pytest`          | `pytest --tb=short -q`                             |
| git    | `git commit`      | `git commit -m "message"` (always provide message) |
| curl   | `curl -O url`     | `curl -sS -O url` (silent + show errors)           |

### 2. Silence Logs - Suppress Progress Bars

Progress bars and verbose logging waste tokens. Always use quiet/silent flags.

```bash
# Python
pip install --no-input --progress-bar off package

# Node.js
npm ci --silent --progress false

# Maven
mvn clean install -B -q  # -B = batch, -q = quiet

# Gradle
./gradlew build --no-daemon -q --console=plain

# Docker
docker build -q .

# Wget/Curl
wget -q URL
curl -sS URL
```

### 3. Visuals - Save to Files, Never Open GUIs

**DO NOT**:

- Call `plt.show()` - blocks forever
- Use `webbrowser.open()` - no browser available
- Open file dialogs or system prompts
- Use `input()` for user confirmation

**DO**:

- Save plots to files: `plt.savefig('output.png')`
- Write results to files for inspection
- Use environment variables for configuration
- Return data as structured output

```python
# BAD - will hang or error
import matplotlib.pyplot as plt
plt.plot(data)
plt.show()  # BLOCKS FOREVER

# GOOD - save to file
import matplotlib.pyplot as plt
plt.plot(data)
plt.savefig('analysis/plot.png', dpi=150, bbox_inches='tight')
plt.close()  # Free memory
print("Plot saved to analysis/plot.png")
```

### 4. Error Handling - Fail Fast with Clear Messages

In headless environments, retries with prompts are futile. Fail fast and report clearly.

```python
# Fail fast pattern
import sys

def require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        print(f"ERROR: Required environment variable {name} is not set", file=sys.stderr)
        sys.exit(1)
    return value
```

### 5. Dependency Management - Pin and Verify

Always verify installations succeeded before proceeding.

```bash
# Python - verify install
pip install --no-input requests && python -c "import requests; print('OK')"

# Node - verify install
npm ci --silent && node -e "require('express'); console.log('OK')"

# Maven - verify dependencies
./mvnw dependency:resolve -B && echo "Dependencies resolved"
```

## Session Start Hook

This profile includes a `SessionStart` hook that auto-detects your project type and installs dependencies:

- **Python** (`requirements.txt`): Runs `pip install --no-input -r requirements.txt`
- **Java/Maven** (`pom.xml`): Runs `./mvnw dependency:go-offline -B`
- **Node.js** (`package.json`): Runs `npm ci --silent`

No action required - dependencies are bootstrapped automatically.

## Recommended Commands

### Python

```bash
# Install
pip install --no-input -r requirements.txt

# Test
pytest -v --tb=short --maxfail=3

# Lint & Format
ruff check . --fix && black .

# Type Check
mypy . --ignore-missing-imports
```

### Java/Maven

```bash
# Build (skip tests)
./mvnw clean package -DskipTests -B

# Test
./mvnw test -B

# Test single class
./mvnw -Dtest=MyClassTest test -B

# Dependencies
./mvnw dependency:tree -B
```

### Node.js

```bash
# Install
npm ci --silent

# Test
npm test --silent

# Lint
npm run lint --silent

# Build
npm run build --silent
```

## Token-Efficient Patterns

### Truncate Long Output

```bash
# Only show first 50 lines of test output
pytest 2>&1 | head -50

# Show summary only
./mvnw test -B 2>&1 | grep -E "(BUILD|Tests run|FAILURE|SUCCESS)"
```

### Structured Logging

```python
# Use structured logging instead of print spam
import logging
logging.basicConfig(level=logging.WARNING)  # Only warnings and errors
```

### Minimal Git Operations

```bash
# One-liner commit
git add -A && git commit -m "feat: description" && git push

# Check status briefly
git status -sb
```

## Environment Variables

Use environment variables for configuration instead of interactive prompts:

```python
import os

# Database
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///local.db")

# API Keys (never hardcode)
API_KEY = os.environ["API_KEY"]  # Will error if not set - good!

# Feature Flags
DEBUG = os.environ.get("DEBUG", "false").lower() == "true"
```

## Anti-Patterns to Avoid

| Anti-Pattern            | Why It Fails            | Better Alternative          |
| ----------------------- | ----------------------- | --------------------------- |
| `input("Continue?")`    | Hangs forever           | Use env var or flag         |
| `plt.show()`            | No display              | `plt.savefig()`             |
| `webbrowser.open()`     | No browser              | Print URL instead           |
| `pip install pkg`       | May prompt              | `pip install --no-input`    |
| `mvn install`           | Interactive             | `mvn install -B`            |
| Long log output         | Wastes tokens           | Use `-q` flags              |
| `git push` without `-u` | May prompt for upstream | `git push -u origin branch` |

## Usage

To use this profile, copy the contents of `web-compatible/` to your project:

```bash
cp -r web-compatible/.claude/settings.json .claude/settings.json
cp web-compatible/CLAUDE.md CLAUDE.md  # Or merge with existing
```

Or reference it in your project's CLAUDE.md:

```markdown
> See also: [Web-Compatible Configuration](https://github.com/bigdegenenergy/ai-dev-toolkit/tree/main/web-compatible)
```

---

**Remember**: The web environment is ephemeral and non-interactive. Every command must run to completion without human input.
