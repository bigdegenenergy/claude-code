#!/usr/bin/env python3
"""
Validators: Utility functions for validating hook inputs and configurations.

This module provides common validation functions used across hooks to ensure
consistent input validation and error handling.
"""

import re
import os
from typing import Optional, Dict, Any, List


def validate_file_path(file_path: Optional[str]) -> bool:
    """
    Validate that a file path is safe and within expected bounds.

    Args:
        file_path: Path to validate

    Returns:
        True if valid, False otherwise
    """
    if not file_path:
        return False

    # Check for path traversal attempts
    if ".." in file_path:
        return False

    # Check for null bytes (injection attempt)
    if "\x00" in file_path:
        return False

    # Ensure path is not too long
    if len(file_path) > 4096:
        return False

    return True


def validate_json_input(data: Any) -> Dict[str, Any]:
    """
    Validate and normalize JSON input from Claude's tool input.

    Args:
        data: Raw input data

    Returns:
        Validated dictionary or empty dict if invalid
    """
    if data is None:
        return {}

    if not isinstance(data, dict):
        return {}

    return data


def is_safe_command(command: str, allowed_patterns: List[str]) -> bool:
    """
    Check if a command matches allowed patterns.

    Args:
        command: Command string to check
        allowed_patterns: List of regex patterns for allowed commands

    Returns:
        True if command is safe, False otherwise
    """
    if not command or not isinstance(command, str):
        return False

    for pattern in allowed_patterns:
        if re.match(pattern, command):
            return True

    return False


def validate_environment() -> Dict[str, bool]:
    """
    Check if required environment variables and tools are available.

    Returns:
        Dictionary mapping tool/var names to availability status
    """
    checks = {
        "git": _command_exists("git"),
        "python": _command_exists("python3") or _command_exists("python"),
        "node": _command_exists("node"),
        "GITHUB_WORKSPACE": bool(os.environ.get("GITHUB_WORKSPACE")),
    }
    return checks


def _command_exists(cmd: str) -> bool:
    """Check if a command exists in PATH."""
    import shutil

    return shutil.which(cmd) is not None


def sanitize_commit_message(message: str) -> str:
    """
    Sanitize a commit message to prevent injection attacks.

    Args:
        message: Raw commit message

    Returns:
        Sanitized message safe for use in git commands
    """
    if not message:
        return ""

    # Remove any shell metacharacters
    dangerous_chars = [
        ";",
        "&",
        "|",
        "$",
        "`",
        "(",
        ")",
        "{",
        "}",
        "<",
        ">",
        "\\",
        "\n",
        "\r",
    ]
    result = message
    for char in dangerous_chars:
        result = result.replace(char, "")

    # Truncate to reasonable length
    max_length = 500
    if len(result) > max_length:
        result = result[:max_length]

    return result.strip()


if __name__ == "__main__":
    # Simple self-test
    print("Running validators self-test...")

    assert validate_file_path("/home/user/file.py") == True
    assert validate_file_path("../etc/passwd") == False
    assert validate_file_path(None) == False

    assert validate_json_input({"key": "value"}) == {"key": "value"}
    assert validate_json_input(None) == {}
    assert validate_json_input("string") == {}

    assert is_safe_command("npm test", [r"^npm\s+test"]) == True
    assert is_safe_command("rm -rf /", [r"^npm\s+test"]) == False

    assert sanitize_commit_message("fix: bug; rm -rf /") == "fix: bug rm -rf /"

    print("All self-tests passed!")
