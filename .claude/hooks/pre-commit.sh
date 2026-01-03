#!/bin/bash
# Pre-Commit Hook - Runs before git commit
# Primary use: Generate commit messages, run quick checks, update trackers
#
# This hook should be fast (<10 seconds) to not slow down commits.
# For heavier checks, use the Stop hook instead.
#
# Exit codes:
# - 0: All checks passed, proceed with commit
# - 1: Warnings (commit proceeds but user notified)
# - 2: Blocked (commit aborted)

echo "🔍 Running pre-commit checks..."

EXIT_CODE=0

# Check 1: Ensure we're not committing to main/master directly
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
    if [ "${ALLOW_MAIN_COMMIT:-0}" != "1" ]; then
        echo "  ⚠️  Warning: Committing directly to $BRANCH"
        echo "     Consider using a feature branch instead."
        # Don't block, just warn
    fi
fi

# Check 2: Look for debugging artifacts in staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Check for console.log/print statements
DEBUG_PATTERNS="console\.log|debugger|print\(|puts |binding\.pry"
DEBUG_FOUND=$(echo "$STAGED_FILES" | xargs grep -l -E "$DEBUG_PATTERNS" 2>/dev/null | head -5)
if [ -n "$DEBUG_FOUND" ]; then
    echo "  ⚠️  Debug statements found in:"
    echo "$DEBUG_FOUND" | sed 's/^/     /'
    echo "     Consider removing before commit."
fi

# Check 3: Look for sensitive data patterns
SENSITIVE_PATTERNS="API_KEY|SECRET|PASSWORD|PRIVATE_KEY|-----BEGIN"
SENSITIVE_FOUND=$(echo "$STAGED_FILES" | xargs grep -l -E "$SENSITIVE_PATTERNS" 2>/dev/null | grep -v ".example" | head -5)
if [ -n "$SENSITIVE_FOUND" ]; then
    echo "  ⛔ Potential secrets found in:"
    echo "$SENSITIVE_FOUND" | sed 's/^/     /'
    echo "     Please review before committing."
    EXIT_CODE=2
fi

# Check 4: Verify no .env files are being committed
ENV_FILES=$(echo "$STAGED_FILES" | grep -E "^\.env$|\.env\.local$|\.env\.production$")
if [ -n "$ENV_FILES" ]; then
    echo "  ⛔ Environment files staged for commit:"
    echo "$ENV_FILES" | sed 's/^/     /'
    echo "     These should be in .gitignore."
    EXIT_CODE=2
fi

# Check 5: Run quick linter if available (max 5 seconds)
if [ -f "package.json" ] && grep -q "\"lint\"" package.json; then
    echo "  Running quick lint check..."
    timeout 5 npm run lint --silent 2>/dev/null || echo "  ⚠️  Lint check skipped (timed out)"
fi

# Check 6: Ensure tests are not skipped
SKIP_PATTERNS="\.skip\(|\.only\(|@pytest\.mark\.skip|#.*noqa"
SKIP_FOUND=$(echo "$STAGED_FILES" | xargs grep -l -E "$SKIP_PATTERNS" 2>/dev/null | head -3)
if [ -n "$SKIP_FOUND" ]; then
    echo "  ⚠️  Test skips found in:"
    echo "$SKIP_FOUND" | sed 's/^/     /'
fi

# Final status
echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Pre-commit checks passed"
elif [ $EXIT_CODE -eq 1 ]; then
    echo "⚠️  Pre-commit checks passed with warnings"
else
    echo "⛔ Pre-commit checks failed - commit blocked"
    echo "   Fix the issues above or use --no-verify to bypass (not recommended)"
fi

exit $EXIT_CODE
