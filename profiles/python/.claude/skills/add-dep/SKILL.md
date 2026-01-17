---
name: add-dep
description: Safely install a Python package, verify it imports correctly, and pin it to requirements.txt
---

# Add Dependency Skill

Safely add a new Python dependency to the project with verification and pinning.

## When to Use

- User asks to "add", "install", or "use" a new package
- You need to add a dependency for implementing a feature
- Upgrading or changing an existing dependency

## Process

### Step 1: Install the Package

```bash
pip install --no-input PACKAGE_NAME
```

For a specific version:

```bash
pip install --no-input PACKAGE_NAME==1.2.3
```

### Step 2: Verify Import Works

```bash
python -c "import PACKAGE_NAME; print(f'{PACKAGE_NAME.__name__} v{getattr(PACKAGE_NAME, \"__version__\", \"unknown\")} OK')"
```

For packages with different import names:

```bash
# PIL is imported as pillow
python -c "from PIL import Image; print('Pillow OK')"

# sklearn is imported from scikit-learn
python -c "import sklearn; print('scikit-learn OK')"
```

### Step 3: Get Installed Version

```bash
pip show PACKAGE_NAME | grep Version
```

### Step 4: Pin to requirements.txt

Add the exact installed version to `requirements.txt`:

```bash
# Get the version and append to requirements.txt
VERSION=$(pip show PACKAGE_NAME | grep Version | cut -d' ' -f2)
echo "PACKAGE_NAME==$VERSION" >> requirements.txt
```

Or use pip freeze for the package:

```bash
pip freeze | grep -i PACKAGE_NAME >> requirements.txt
```

### Step 5: Verify requirements.txt

```bash
cat requirements.txt | grep PACKAGE_NAME
```

## Common Package Mappings

Some packages have different install and import names:

| pip install      | python import |
| ---------------- | ------------- |
| `Pillow`         | `PIL`         |
| `scikit-learn`   | `sklearn`     |
| `beautifulsoup4` | `bs4`         |
| `python-dotenv`  | `dotenv`      |
| `PyYAML`         | `yaml`        |
| `opencv-python`  | `cv2`         |

## Example: Adding requests

```bash
# 1. Install
pip install --no-input requests

# 2. Verify
python -c "import requests; print(requests.__version__)"

# 3. Pin
pip freeze | grep -i requests >> requirements.txt

# 4. Confirm
cat requirements.txt | tail -1
```

Output:

```
2.31.0
requests==2.31.0
```

## Example: Adding pandas with specific version

```bash
# 1. Install specific version
pip install --no-input pandas==2.1.0

# 2. Verify
python -c "import pandas as pd; print(pd.__version__)"

# 3. Pin
echo "pandas==2.1.0" >> requirements.txt
```

## Dev Dependencies

For development-only dependencies (testing, linting), add to `requirements-dev.txt`:

```bash
pip install --no-input pytest
pip freeze | grep -i pytest >> requirements-dev.txt
```

## Handling Failures

### Installation Fails

```bash
# Check if package name is correct
pip search PACKAGE_NAME  # May be disabled

# Try with verbose output
pip install --no-input -v PACKAGE_NAME
```

### Import Fails

```bash
# Check installed packages
pip list | grep -i PACKAGE_NAME

# Check for correct import name
pip show PACKAGE_NAME | grep -E "Name|Location"
```

### Version Conflict

```bash
# See what's conflicting
pip check

# See dependency tree
pip install --no-input pipdeptree && pipdeptree
```

## Web Environment Notes

In Claude Code Web (headless):

- Always use `--no-input` flag
- Suppress progress bar with `--progress-bar off`
- Verify immediately after install (session may restart)

```bash
pip install --no-input --progress-bar off PACKAGE_NAME && \
python -c "import PACKAGE_NAME; print('OK')"
```
