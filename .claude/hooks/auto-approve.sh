#!/bin/bash
# PermissionRequest Hook - Auto-Approve Trusted Commands
# Eliminates approval friction for commands you already trust.
#
# This hook intercepts permission requests and automatically approves
# safe, well-known commands. No more clicking "approve" for npm test.
#
# Output: JSON with decision field
#   {"decision": "approve"} - Auto-approve the command
#   {"decision": "deny", "message": "reason"} - Block the command
#   (no output) - Fall through to normal permission dialog
#
# Exit codes:
#   0 = Hook ran successfully (output determines action)
#   non-zero = Hook failed, fall through to normal behavior

# Read the permission request from stdin
INPUT=$(cat)

# Extract tool name and details
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
BASH_COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# ============================================
# TRUSTED BASH COMMANDS - AUTO APPROVE
# ============================================

if [[ "$TOOL_NAME" == "Bash" ]] && [[ -n "$BASH_COMMAND" ]]; then
    # Test commands - always safe
    if [[ "$BASH_COMMAND" =~ ^npm\ test ]] || \
       [[ "$BASH_COMMAND" =~ ^pnpm\ test ]] || \
       [[ "$BASH_COMMAND" =~ ^yarn\ test ]] || \
       [[ "$BASH_COMMAND" =~ ^pytest ]] || \
       [[ "$BASH_COMMAND" =~ ^python\ -m\ pytest ]] || \
       [[ "$BASH_COMMAND" =~ ^cargo\ test ]] || \
       [[ "$BASH_COMMAND" =~ ^go\ test ]] || \
       [[ "$BASH_COMMAND" =~ ^make\ test ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Lint commands - safe, read-only
    if [[ "$BASH_COMMAND" =~ ^npm\ run\ lint ]] || \
       [[ "$BASH_COMMAND" =~ ^npx\ eslint ]] || \
       [[ "$BASH_COMMAND" =~ ^pnpm\ lint ]] || \
       [[ "$BASH_COMMAND" =~ ^ruff\ check ]] || \
       [[ "$BASH_COMMAND" =~ ^flake8 ]] || \
       [[ "$BASH_COMMAND" =~ ^cargo\ clippy ]] || \
       [[ "$BASH_COMMAND" =~ ^golint ]] || \
       [[ "$BASH_COMMAND" =~ ^staticcheck ]] || \
       [[ "$BASH_COMMAND" =~ ^shellcheck ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Format commands - safe, modifies files but in expected ways
    if [[ "$BASH_COMMAND" =~ ^npx\ prettier ]] || \
       [[ "$BASH_COMMAND" =~ ^black ]] || \
       [[ "$BASH_COMMAND" =~ ^isort ]] || \
       [[ "$BASH_COMMAND" =~ ^gofmt ]] || \
       [[ "$BASH_COMMAND" =~ ^rustfmt ]] || \
       [[ "$BASH_COMMAND" =~ ^shfmt ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Build commands - safe
    if [[ "$BASH_COMMAND" =~ ^npm\ run\ build ]] || \
       [[ "$BASH_COMMAND" =~ ^pnpm\ build ]] || \
       [[ "$BASH_COMMAND" =~ ^yarn\ build ]] || \
       [[ "$BASH_COMMAND" =~ ^cargo\ build ]] || \
       [[ "$BASH_COMMAND" =~ ^go\ build ]] || \
       [[ "$BASH_COMMAND" =~ ^make$ ]] || \
       [[ "$BASH_COMMAND" =~ ^make\ build ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Type checking - read-only
    if [[ "$BASH_COMMAND" =~ ^npx\ tsc ]] || \
       [[ "$BASH_COMMAND" =~ ^tsc\ --noEmit ]] || \
       [[ "$BASH_COMMAND" =~ ^mypy ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Git read-only commands - always safe
    if [[ "$BASH_COMMAND" =~ ^git\ status ]] || \
       [[ "$BASH_COMMAND" =~ ^git\ diff ]] || \
       [[ "$BASH_COMMAND" =~ ^git\ log ]] || \
       [[ "$BASH_COMMAND" =~ ^git\ branch ]] || \
       [[ "$BASH_COMMAND" =~ ^git\ show ]] || \
       [[ "$BASH_COMMAND" =~ ^git\ remote ]] || \
       [[ "$BASH_COMMAND" =~ ^git\ stash\ list ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Docker read-only commands - safe
    if [[ "$BASH_COMMAND" =~ ^docker\ ps ]] || \
       [[ "$BASH_COMMAND" =~ ^docker\ images ]] || \
       [[ "$BASH_COMMAND" =~ ^docker\ logs ]] || \
       [[ "$BASH_COMMAND" =~ ^docker\ inspect ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Kubernetes read-only commands - safe
    if [[ "$BASH_COMMAND" =~ ^kubectl\ get ]] || \
       [[ "$BASH_COMMAND" =~ ^kubectl\ describe ]] || \
       [[ "$BASH_COMMAND" =~ ^kubectl\ logs ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Package info commands - safe
    if [[ "$BASH_COMMAND" =~ ^npm\ list ]] || \
       [[ "$BASH_COMMAND" =~ ^npm\ outdated ]] || \
       [[ "$BASH_COMMAND" =~ ^pip\ list ]] || \
       [[ "$BASH_COMMAND" =~ ^pip\ show ]] || \
       [[ "$BASH_COMMAND" =~ ^cargo\ tree ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # File listing/searching - safe
    if [[ "$BASH_COMMAND" =~ ^ls ]] || \
       [[ "$BASH_COMMAND" =~ ^find ]] || \
       [[ "$BASH_COMMAND" =~ ^grep ]] || \
       [[ "$BASH_COMMAND" =~ ^rg ]] || \
       [[ "$BASH_COMMAND" =~ ^wc ]] || \
       [[ "$BASH_COMMAND" =~ ^head ]] || \
       [[ "$BASH_COMMAND" =~ ^tail ]] || \
       [[ "$BASH_COMMAND" =~ ^cat ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi
fi

# ============================================
# FILE OPERATIONS
# ============================================

# Read operations are always safe
if [[ "$TOOL_NAME" == "Read" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Glob operations are always safe
if [[ "$TOOL_NAME" == "Glob" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Grep operations are always safe
if [[ "$TOOL_NAME" == "Grep" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# ============================================
# NO MATCH - FALL THROUGH TO PERMISSION DIALOG
# ============================================

# If we didn't match any trusted patterns, don't output anything.
# This causes the normal permission dialog to appear.
exit 0
