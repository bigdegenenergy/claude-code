#!/usr/bin/env python3
"""
Gateway Command Mapping

Maps chat platform commands to Claude Code commands.
Used by webhook handlers to translate incoming requests.
"""

from dataclasses import dataclass
from enum import Enum
from typing import Optional


class PermissionLevel(Enum):
    """User permission levels for command execution."""

    VIEWER = "viewer"
    MEMBER = "member"
    ADMIN = "admin"


@dataclass
class CommandMapping:
    """Maps a chat command to a Claude command."""

    chat_pattern: str  # Pattern to match (e.g., "plan", "qa")
    claude_command: str  # Claude command to execute (e.g., "/plan", "/qa")
    description: str  # Human-readable description
    required_permission: PermissionLevel
    accepts_args: bool = True  # Whether the command accepts arguments


# Command mapping registry
COMMAND_MAPPINGS: dict[str, CommandMapping] = {
    "plan": CommandMapping(
        chat_pattern="plan",
        claude_command="/plan",
        description="Plan a feature implementation",
        required_permission=PermissionLevel.MEMBER,
        accepts_args=True,
    ),
    "qa": CommandMapping(
        chat_pattern="qa",
        claude_command="/qa",
        description="Run tests and fix failures",
        required_permission=PermissionLevel.MEMBER,
        accepts_args=False,
    ),
    "review": CommandMapping(
        chat_pattern="review",
        claude_command="/review",
        description="Critical code review",
        required_permission=PermissionLevel.MEMBER,
        accepts_args=True,
    ),
    "zeno": CommandMapping(
        chat_pattern="zeno",
        claude_command="/zeno",
        description="Surgical code analysis with citations",
        required_permission=PermissionLevel.MEMBER,
        accepts_args=True,
    ),
    "ship": CommandMapping(
        chat_pattern="ship",
        claude_command="/ship",
        description="Commit and create PR",
        required_permission=PermissionLevel.ADMIN,
        accepts_args=True,
    ),
    "simplify": CommandMapping(
        chat_pattern="simplify",
        claude_command="/simplify",
        description="Clean up and refactor code",
        required_permission=PermissionLevel.MEMBER,
        accepts_args=True,
    ),
    "deslop": CommandMapping(
        chat_pattern="deslop",
        claude_command="/deslop",
        description="Aggressive code simplification",
        required_permission=PermissionLevel.MEMBER,
        accepts_args=True,
    ),
    "debug": CommandMapping(
        chat_pattern="debug",
        claude_command="/systematic-debug",
        description="Systematic bug investigation",
        required_permission=PermissionLevel.MEMBER,
        accepts_args=True,
    ),
    "status": CommandMapping(
        chat_pattern="status",
        claude_command="/gateway-status",
        description="Check current session status",
        required_permission=PermissionLevel.VIEWER,
        accepts_args=False,
    ),
    "approve": CommandMapping(
        chat_pattern="approve",
        claude_command="/workflow-approve",
        description="Approve pending workflow gate",
        required_permission=PermissionLevel.ADMIN,
        accepts_args=True,
    ),
    "help": CommandMapping(
        chat_pattern="help",
        claude_command="",
        description="Show available commands",
        required_permission=PermissionLevel.VIEWER,
        accepts_args=False,
    ),
}


def parse_command(message: str) -> tuple[Optional[str], Optional[str]]:
    """
    Parse a chat message to extract command and arguments.

    Args:
        message: Raw message from chat (e.g., "/claude plan add user auth")

    Returns:
        Tuple of (command_name, arguments) or (None, None) if not a command
    """
    # Maximum length limits to prevent DoS and injection attacks
    MAX_MESSAGE_LENGTH = 2000
    MAX_COMMAND_LENGTH = 100
    MAX_ARGS_LENGTH = 1500

    # Enforce maximum message length
    if len(message) > MAX_MESSAGE_LENGTH:
        message = message[:MAX_MESSAGE_LENGTH]

    # Remove common prefixes
    prefixes = ["/claude ", "!claude ", "@claude "]

    normalized = message.strip().lower()
    for prefix in prefixes:
        if normalized.startswith(prefix):
            message = message[len(prefix) :].strip()
            break
    else:
        # Not a claude command
        return None, None

    # Split into command and args
    parts = message.split(maxsplit=1)
    command = parts[0].lower() if parts else None
    args = parts[1] if len(parts) > 1 else None

    # Enforce length limits on parsed components
    if command and len(command) > MAX_COMMAND_LENGTH:
        command = command[:MAX_COMMAND_LENGTH]

    if args and len(args) > MAX_ARGS_LENGTH:
        args = args[:MAX_ARGS_LENGTH]

    return command, args


def get_command(name: str) -> Optional[CommandMapping]:
    """Get command mapping by name."""
    return COMMAND_MAPPINGS.get(name.lower())


def can_execute(command: CommandMapping, user_permission: PermissionLevel) -> bool:
    """Check if user has permission to execute command."""
    permission_order = [
        PermissionLevel.VIEWER,
        PermissionLevel.MEMBER,
        PermissionLevel.ADMIN,
    ]
    user_level = permission_order.index(user_permission)
    required_level = permission_order.index(command.required_permission)
    return user_level >= required_level


def format_help() -> str:
    """Generate help text listing all available commands."""
    lines = ["**Available Commands**\n"]

    for name, cmd in COMMAND_MAPPINGS.items():
        perm = cmd.required_permission.value
        args = " <args>" if cmd.accepts_args else ""
        lines.append(f"- `/claude {name}{args}` - {cmd.description} ({perm})")

    return "\n".join(lines)


def build_prompt(command: CommandMapping, args: Optional[str], context: dict) -> str:
    """
    Build the Claude prompt for the command.

    Args:
        command: The CommandMapping to execute
        args: Optional arguments from the chat message
        context: Additional context (repo, branch, user, etc.)

    Returns:
        Formatted prompt string for Claude
    """
    prompt_parts = [f"Execute: {command.claude_command}"]

    if args:
        prompt_parts.append(f"Arguments: {args}")

    if context.get("repo"):
        prompt_parts.append(f"Repository: {context['repo']}")

    if context.get("branch"):
        prompt_parts.append(f"Branch: {context['branch']}")

    if context.get("pr_number"):
        prompt_parts.append(f"PR: #{context['pr_number']}")

    return "\n".join(prompt_parts)


if __name__ == "__main__":
    # Test command parsing
    test_messages = [
        "/claude plan add user authentication",
        "!claude qa",
        "@claude review src/auth/",
        "/claude ship",
        "/claude help",
        "random message",
    ]

    print("Testing command parsing:\n")
    for msg in test_messages:
        cmd, args = parse_command(msg)
        print(f"  '{msg}'")
        print(f"    -> command: {cmd}, args: {args}")
        if cmd:
            mapping = get_command(cmd)
            if mapping:
                print(f"    -> Claude command: {mapping.claude_command}")
        print()
