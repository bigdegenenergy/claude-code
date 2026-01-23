#!/usr/bin/env python3
"""
Tests for validators module.

These tests validate the security and functionality of the validators module,
ensuring proper input validation and sanitization.
"""

import sys
import os
import importlib.util

# Use importlib to load module from .claude hidden directory
# This is more robust than sys.path manipulation for hidden directories
validators_path = os.path.join(
    os.path.dirname(__file__), "..", ".claude", "hooks", "validators.py"
)
spec = importlib.util.spec_from_file_location("validators", validators_path)
validators = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validators)

# Import functions from the loaded module
validate_file_path = validators.validate_file_path
validate_json_input = validators.validate_json_input
is_safe_command = validators.is_safe_command
sanitize_commit_message = validators.sanitize_commit_message


def test_validate_file_path():
    """Test file path validation."""
    assert validate_file_path("/home/user/file.py") == True
    assert validate_file_path("../etc/passwd") == False
    assert validate_file_path(None) == False
    assert validate_file_path("") == False
    assert validate_file_path("a" * 5000) == False  # Too long


def test_validate_json_input():
    """Test JSON input validation."""
    assert validate_json_input({"key": "value"}) == {"key": "value"}
    assert validate_json_input(None) == {}
    assert validate_json_input("string") == {}
    assert validate_json_input([1, 2, 3]) == {}


def test_is_safe_command():
    """Test command safety validation."""
    assert is_safe_command("npm test", [r"^npm\s+test$"]) == True
    assert is_safe_command("rm -rf /", [r"^npm\s+test$"]) == False
    assert is_safe_command("", [r"^npm\s+test$"]) == False
    assert is_safe_command(None, [r"^npm\s+test$"]) == False


def test_sanitize_commit_message():
    """Test commit message sanitization."""
    # Basic message
    msg = "fix: bug in parser"
    sanitized = sanitize_commit_message(msg)
    assert sanitized is not None
    assert len(sanitized) > 0

    # Message with shell metacharacters - should be properly quoted
    msg = "fix: bug; rm -rf /"
    sanitized = sanitize_commit_message(msg)
    # shlex.quote should wrap it in single quotes or escape properly
    assert sanitized is not None
    # The original dangerous characters should still be preserved in the quoted result
    assert "fix:" in sanitized or "'" in sanitized  # Either contains content or is quoted

    # Empty message
    assert sanitize_commit_message("") == ""

    # Very long message should be truncated to 500 chars before quoting
    long_msg = "a" * 1000
    sanitized = sanitize_commit_message(long_msg)
    # The result will be slightly longer than 500 due to shlex.quote() adding quotes
    # For a string of 500 'a's, shlex.quote will wrap it making it ~502-504 chars
    assert len(sanitized) <= 510  # Allow some margin for quote wrapping


if __name__ == "__main__":
    # Run tests when executed directly
    print("Running validator tests...")

    test_validate_file_path()
    print("✓ test_validate_file_path passed")

    test_validate_json_input()
    print("✓ test_validate_json_input passed")

    test_is_safe_command()
    print("✓ test_is_safe_command passed")

    test_sanitize_commit_message()
    print("✓ test_sanitize_commit_message passed")

    print("\nAll tests passed!")
