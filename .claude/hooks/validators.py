#!/usr/bin/env python3
"""
Validators: Utility functions for validating hook inputs and configurations.

This module provides common validation functions used across hooks to ensure
consistent input validation and error handling.
"""

import re
import os
import shlex
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

    WARNING: Regex-based command validation is prone to bypasses. Patterns MUST be:
    - Strictly anchored with ^ and $ (e.g., r"^git status$")
    - Should NOT match shell metacharacters or allow variable arguments
    - Avoid broad patterns like r"git .*" which can match malicious subcommands

    Consider using a strict allow-list of exact command strings instead of regex,
    or restricting validation to the command executable only.

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

    IMPORTANT: This function uses shlex.quote() to properly escape the message
    for shell usage. However, the RECOMMENDED approach is to pass arguments
    as a list to subprocess.run() (e.g., ['git', 'commit', '-m', message])
    which bypasses the shell entirely and makes sanitization unnecessary.

    Args:
        message: Raw commit message

    Returns:
        Sanitized message safe for use in shell commands
    """
    if not message:
        return ""

    # Truncate to reasonable length before quoting
    max_length = 500
    if len(message) > max_length:
        message = message[:max_length]

    # Use shlex.quote() to properly escape the message for shell usage
    # This handles all shell metacharacters correctly, including quotes
    return shlex.quote(message.strip())
