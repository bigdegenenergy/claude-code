#!/bin/bash

# ==============================================================================
# Claude Code Configuration Installer
# Source: https://github.com/bigdegenenergy/claude-code
#
# Installs the complete Claude Code professional development environment:
#   - 21 Slash Commands (workflows and orchestration)
#   - 17 Specialized Agents (subagents for different domains)
#   - 11 Auto-Discovered Skills (context-aware expertise)
#   - 8 Automated Hooks (quality gates and automation)
#   - 7 GitHub Actions Workflows (CI/CD automation)
#   - 5 Git Hooks (pre-commit, commit-msg, prepare-commit-msg, post-commit, pre-push)
#
# Usage (Multiple Methods):
#
#   Method 1 - Direct git clone (RECOMMENDED - most reliable):
#     git clone https://github.com/bigdegenenergy/claude-code.git /tmp/claude-code && \
#     /tmp/claude-code/install-claude-code.sh && \
#     rm -rf /tmp/claude-code
#
#   Method 2 - One-liner via curl:
#     curl -fsSL https://raw.githubusercontent.com/bigdegenenergy/claude-code/main/install-claude-code.sh | bash
#
#   Method 3 - Download and run:
#     git archive --remote=https://github.com/bigdegenenergy/claude-code.git HEAD install-claude-code.sh | tar -x
#     ./install-claude-code.sh
#
# With options:
#   ./install-claude-code.sh [OPTIONS]
#
# Options:
#   --no-github      Skip GitHub Actions workflows
#   --no-git-hooks   Skip git hooks setup
#   --no-profiles    Skip language profiles
#   --profile=NAME   Install specific profile (python, java)
#   --web            Install web-compatible configuration
#   --force          Overwrite existing files without prompting
#   --dry-run        Show what would be installed without making changes
#   --help           Show this help message
# ==============================================================================

set -e

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
VERSION="2.0.0"
SOURCE_REPO="https://github.com/bigdegenenergy/claude-code.git"
SOURCE_RAW="https://raw.githubusercontent.com/bigdegenenergy/claude-code/main"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Options (defaults)
INSTALL_GITHUB=true
INSTALL_GIT_HOOKS=true
INSTALL_PROFILES=false
PROFILE_NAME=""
WEB_MODE=false
FORCE_MODE=false
DRY_RUN=false

# Counters
COMMANDS_INSTALLED=0
AGENTS_INSTALLED=0
SKILLS_INSTALLED=0
HOOKS_INSTALLED=0
WORKFLOWS_INSTALLED=0

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_header() { echo -e "\n${BOLD}${CYAN}$1${NC}"; }

print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
   _____ _                 _        _____          _
  / ____| |               | |      / ____|        | |
 | |    | | __ _ _   _  __| | ___ | |     ___   __| | ___
 | |    | |/ _` | | | |/ _` |/ _ \| |    / _ \ / _` |/ _ \
 | |____| | (_| | |_| | (_| |  __/| |___| (_) | (_| |  __/
  \_____|_|\__,_|\__,_|\__,_|\___| \_____\___/ \__,_|\___|

EOF
    echo -e "${NC}"
    echo -e "${BOLD}Professional Development Environment Installer v${VERSION}${NC}"
    echo -e "Source: ${BLUE}https://github.com/bigdegenenergy/claude-code${NC}"
    echo ""
}

print_help() {
    print_banner
    cat << EOF
Usage: $0 [OPTIONS]

Installs Claude Code configuration to amplify solo developer capabilities.

OPTIONS:
    --no-github      Skip GitHub Actions workflows installation
    --no-git-hooks   Skip git hooks setup (pre-commit, commit-msg)
    --no-profiles    Skip language profiles (default: profiles not installed)
    --profile=NAME   Install specific language profile (python, java)
    --web            Install web-compatible configuration for browser sessions
    --force          Overwrite existing files without prompting
    --dry-run        Preview installation without making changes
    --help           Display this help message

EXAMPLES:
    # Standard installation
    $0

    # Install with Python profile
    $0 --profile=python

    # Web-compatible installation
    $0 --web

    # Preview what would be installed
    $0 --dry-run

WHAT GETS INSTALLED:
    .claude/
    ├── commands/     (21 slash commands)
    ├── agents/       (17 specialized subagents)
    ├── skills/       (11 auto-discovered skills)
    ├── hooks/        (8 automated quality gates)
    ├── templates/    (project templates)
    └── settings.json (permissions & hook config)

    .github/
    └── workflows/    (7 CI/CD workflows)

    CLAUDE.md         (project instructions)

For more information, visit: https://github.com/bigdegenenergy/claude-code
EOF
}

check_prerequisites() {
    log_header "Checking Prerequisites"

    # Check git
    if ! command -v git &> /dev/null; then
        log_error "git is not installed. Please install git first."
        exit 1
    fi
    log_success "git found: $(git --version)"

    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        log_error "Not inside a git repository. Please run from a git repo root."
        exit 1
    fi

    # Move to git root
    GIT_ROOT=$(git rev-parse --show-toplevel)
    cd "$GIT_ROOT"
    log_success "Git root: $GIT_ROOT"

    # Check for curl or wget
    if command -v curl &> /dev/null; then
        DOWNLOADER="curl"
        log_success "curl found"
    elif command -v wget &> /dev/null; then
        DOWNLOADER="wget"
        log_success "wget found"
    else
        log_error "Neither curl nor wget found. Please install one."
        exit 1
    fi
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-github)
                INSTALL_GITHUB=false
                shift
                ;;
            --no-git-hooks)
                INSTALL_GIT_HOOKS=false
                shift
                ;;
            --no-profiles)
                INSTALL_PROFILES=false
                shift
                ;;
            --profile=*)
                PROFILE_NAME="${1#*=}"
                INSTALL_PROFILES=true
                shift
                ;;
            --web)
                WEB_MODE=true
                shift
                ;;
            --force)
                FORCE_MODE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                print_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

confirm_overwrite() {
    local file="$1"
    if [ -e "$file" ] && [ "$FORCE_MODE" = false ]; then
        echo -en "${YELLOW}File exists: $file. Overwrite? [y/N] ${NC}"
        read -r response
        case "$response" in
            [yY][eE][sS]|[yY]) return 0 ;;
            *) return 1 ;;
        esac
    fi
    return 0
}

# ------------------------------------------------------------------------------
# Installation Functions
# ------------------------------------------------------------------------------
download_source() {
    log_header "Downloading Claude Code Configuration"

    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would clone $SOURCE_REPO to $TEMP_DIR"
        return 0
    fi

    log_info "Cloning repository..."
    git clone --quiet --depth 1 "$SOURCE_REPO" "$TEMP_DIR"
    log_success "Downloaded configuration source"
}

install_claude_directory() {
    log_header "Installing .claude Directory"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install .claude directory with:"
        log_info "  - commands/ (21 slash commands)"
        log_info "  - agents/ (17 subagents)"
        log_info "  - skills/ (11 skills)"
        log_info "  - hooks/ (8 hooks)"
        log_info "  - templates/"
        log_info "  - settings.json"
        return 0
    fi

    # Create .claude directory
    mkdir -p .claude

    # Copy commands
    if [ -d "$TEMP_DIR/.claude/commands" ]; then
        cp -R "$TEMP_DIR/.claude/commands" .claude/
        COMMANDS_INSTALLED=$(find .claude/commands -name "*.md" | wc -l)
        log_success "Installed $COMMANDS_INSTALLED slash commands"
    fi

    # Copy agents
    if [ -d "$TEMP_DIR/.claude/agents" ]; then
        cp -R "$TEMP_DIR/.claude/agents" .claude/
        AGENTS_INSTALLED=$(find .claude/agents -name "*.md" | wc -l)
        log_success "Installed $AGENTS_INSTALLED specialized agents"
    fi

    # Copy skills
    if [ -d "$TEMP_DIR/.claude/skills" ]; then
        cp -R "$TEMP_DIR/.claude/skills" .claude/
        SKILLS_INSTALLED=$(find .claude/skills -name "SKILL.md" | wc -l)
        log_success "Installed $SKILLS_INSTALLED auto-discovered skills"
    fi

    # Copy hooks
    if [ -d "$TEMP_DIR/.claude/hooks" ]; then
        cp -R "$TEMP_DIR/.claude/hooks" .claude/
        chmod +x .claude/hooks/*.sh 2>/dev/null || true
        chmod +x .claude/hooks/*.py 2>/dev/null || true
        chmod +x .claude/hooks/*.mjs 2>/dev/null || true
        # Handle nested hook directories
        find .claude/hooks -type f \( -name "*.sh" -o -name "*.py" -o -name "*.mjs" \) -exec chmod +x {} \;
        HOOKS_INSTALLED=$(find .claude/hooks -type f \( -name "*.sh" -o -name "*.py" -o -name "*.mjs" \) | wc -l)
        log_success "Installed $HOOKS_INSTALLED automated hooks (made executable)"
    fi

    # Copy templates
    if [ -d "$TEMP_DIR/.claude/templates" ]; then
        cp -R "$TEMP_DIR/.claude/templates" .claude/
        log_success "Installed project templates"
    fi

    # Copy settings.json
    if [ -f "$TEMP_DIR/.claude/settings.json" ]; then
        if [ -f ".claude/settings.json" ]; then
            if confirm_overwrite ".claude/settings.json"; then
                cp "$TEMP_DIR/.claude/settings.json" .claude/
                log_success "Updated settings.json"
            else
                log_warning "Kept existing settings.json"
            fi
        else
            cp "$TEMP_DIR/.claude/settings.json" .claude/
            log_success "Installed settings.json"
        fi
    fi

    # Copy other config files
    for file in bootstrap.toml docs.md README.md notifications.json.template; do
        if [ -f "$TEMP_DIR/.claude/$file" ]; then
            cp "$TEMP_DIR/.claude/$file" .claude/
        fi
    done

    # Handle notifications.json
    if [ ! -f ".claude/notifications.json" ] && [ -f ".claude/notifications.json.template" ]; then
        cp .claude/notifications.json.template .claude/notifications.json
        log_success "Created notifications.json from template"
    fi
}

install_claude_md() {
    log_header "Installing CLAUDE.md"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install CLAUDE.md project instructions"
        return 0
    fi

    local source_file="$TEMP_DIR/CLAUDE.md"
    if [ "$WEB_MODE" = true ] && [ -f "$TEMP_DIR/web-compatible/CLAUDE.md" ]; then
        source_file="$TEMP_DIR/web-compatible/CLAUDE.md"
        log_info "Using web-compatible CLAUDE.md"
    fi

    if [ -f "CLAUDE.md" ]; then
        if confirm_overwrite "CLAUDE.md"; then
            # Backup existing
            cp CLAUDE.md "CLAUDE.md.backup.$(date +%Y%m%d%H%M%S)"
            cp "$source_file" CLAUDE.md
            log_success "Updated CLAUDE.md (backup created)"
        else
            cp "$source_file" "CLAUDE.md.new"
            log_warning "Saved as CLAUDE.md.new (existing file preserved)"
        fi
    else
        cp "$source_file" CLAUDE.md
        log_success "Installed CLAUDE.md"
    fi
}

install_github_workflows() {
    if [ "$INSTALL_GITHUB" = false ]; then
        log_info "Skipping GitHub workflows (--no-github)"
        return 0
    fi

    log_header "Installing GitHub Actions Workflows"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install .github/workflows/ with CI/CD pipelines"
        return 0
    fi

    mkdir -p .github/workflows
    mkdir -p .github/ISSUE_TEMPLATE

    # Copy workflows
    if [ -d "$TEMP_DIR/.github/workflows" ]; then
        cp -R "$TEMP_DIR/.github/workflows/"* .github/workflows/ 2>/dev/null || true
        WORKFLOWS_INSTALLED=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
        log_success "Installed $WORKFLOWS_INSTALLED GitHub Actions workflows"
    fi

    # Copy issue templates
    if [ -d "$TEMP_DIR/.github/ISSUE_TEMPLATE" ]; then
        cp -R "$TEMP_DIR/.github/ISSUE_TEMPLATE/"* .github/ISSUE_TEMPLATE/ 2>/dev/null || true
        log_success "Installed issue templates"
    fi

    # Copy PR template
    if [ -f "$TEMP_DIR/.github/pull_request_template.md" ]; then
        cp "$TEMP_DIR/.github/pull_request_template.md" .github/
        log_success "Installed PR template"
    fi

    # Copy CONTRIBUTING.md
    if [ -f "$TEMP_DIR/.github/CONTRIBUTING.md" ]; then
        cp "$TEMP_DIR/.github/CONTRIBUTING.md" .github/
        log_success "Installed CONTRIBUTING.md"
    fi
}

install_git_hooks() {
    if [ "$INSTALL_GIT_HOOKS" = false ]; then
        log_info "Skipping git hooks (--no-git-hooks)"
        return 0
    fi

    log_header "Installing Git Hooks"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install git hooks:"
        log_info "  - pre-commit (linting, formatting, PII scan)"
        log_info "  - commit-msg (conventional commits)"
        log_info "  - prepare-commit-msg (context generation)"
        log_info "  - post-commit (notifications)"
        return 0
    fi

    # Create git hooks directory if needed
    mkdir -p .git/hooks

    # -------------------------------------------------------------------------
    # Pre-commit Hook - Linting, Formatting, Security Checks
    # -------------------------------------------------------------------------
    cat > .git/hooks/pre-commit << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# Claude Code Pre-Commit Hook
# Runs before each commit to ensure code quality and security
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Running Claude Code pre-commit checks...${NC}"

# Get staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
    echo "No staged files to check"
    exit 0
fi

EXIT_CODE=0

# -------------------------------------------------------------------------
# 1. Run Claude's pre-commit hook if it exists
# -------------------------------------------------------------------------
if [ -f ".claude/hooks/pre-commit.sh" ]; then
    echo -e "\n${YELLOW}→ Running Claude pre-commit checks...${NC}"
    if bash .claude/hooks/pre-commit.sh; then
        echo -e "${GREEN}✓ Claude pre-commit checks passed${NC}"
    else
        echo -e "${RED}✗ Claude pre-commit checks failed${NC}"
        EXIT_CODE=1
    fi
fi

# -------------------------------------------------------------------------
# 2. Check for secrets and sensitive data
# -------------------------------------------------------------------------
echo -e "\n${YELLOW}→ Scanning for secrets...${NC}"

SECRET_PATTERNS=(
    'PRIVATE.KEY'
    'api[_-]?key.*=.*["\x27][a-zA-Z0-9]{20,}'
    'password.*=.*["\x27].+'
    'secret.*=.*["\x27].+'
    'AWS_ACCESS_KEY_ID'
    'AWS_SECRET_ACCESS_KEY'
    'GITHUB_TOKEN'
)

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        for pattern in "${SECRET_PATTERNS[@]}"; do
            if grep -iE "$pattern" "$file" 2>/dev/null | grep -v "example\|sample\|test\|mock\|dummy" > /dev/null; then
                echo -e "${RED}✗ Potential secret found in: $file${NC}"
                echo "  Pattern: $pattern"
                EXIT_CODE=1
            fi
        done
    fi
done

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ No secrets detected${NC}"
fi

# -------------------------------------------------------------------------
# 3. Check for PII (Personal Identifiable Information)
# -------------------------------------------------------------------------
echo -e "\n${YELLOW}→ Scanning for PII...${NC}"

PII_FOUND=false
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        # Skip binary files and common non-code files
        if file "$file" | grep -q "text"; then
            # Email addresses (excluding test/example domains)
            if grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$file" 2>/dev/null | \
               grep -v '@example\|@test\|@localhost\|@email.com\|@mail.com' > /dev/null; then
                echo -e "${RED}✗ Email address found in: $file${NC}"
                PII_FOUND=true
            fi

            # SSN pattern
            if grep -E '\b[0-9]{3}-[0-9]{2}-[0-9]{4}\b' "$file" 2>/dev/null > /dev/null; then
                echo -e "${RED}✗ SSN pattern found in: $file${NC}"
                PII_FOUND=true
                EXIT_CODE=1
            fi

            # Credit card pattern
            if grep -E '\b[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}\b' "$file" 2>/dev/null > /dev/null; then
                echo -e "${RED}✗ Credit card pattern found in: $file${NC}"
                PII_FOUND=true
                EXIT_CODE=1
            fi
        fi
    fi
done

if [ "$PII_FOUND" = false ]; then
    echo -e "${GREEN}✓ No PII detected${NC}"
fi

# -------------------------------------------------------------------------
# 4. Run language-specific linters (if available)
# -------------------------------------------------------------------------
echo -e "\n${YELLOW}→ Running linters...${NC}"

# JavaScript/TypeScript
JS_FILES=$(echo "$STAGED_FILES" | grep -E '\.(js|jsx|ts|tsx)$' || true)
if [ -n "$JS_FILES" ] && command -v npx &> /dev/null; then
    if [ -f "package.json" ] && grep -q "eslint" package.json 2>/dev/null; then
        echo "  Linting JavaScript/TypeScript..."
        if echo "$JS_FILES" | xargs npx eslint --quiet 2>/dev/null; then
            echo -e "${GREEN}  ✓ ESLint passed${NC}"
        else
            echo -e "${RED}  ✗ ESLint found issues${NC}"
            EXIT_CODE=1
        fi
    fi
fi

# Python
PY_FILES=$(echo "$STAGED_FILES" | grep -E '\.py$' || true)
if [ -n "$PY_FILES" ]; then
    if command -v ruff &> /dev/null; then
        echo "  Linting Python with ruff..."
        if echo "$PY_FILES" | xargs ruff check --quiet 2>/dev/null; then
            echo -e "${GREEN}  ✓ Ruff passed${NC}"
        else
            echo -e "${RED}  ✗ Ruff found issues${NC}"
            EXIT_CODE=1
        fi
    elif command -v flake8 &> /dev/null; then
        echo "  Linting Python with flake8..."
        if echo "$PY_FILES" | xargs flake8 --quiet 2>/dev/null; then
            echo -e "${GREEN}  ✓ Flake8 passed${NC}"
        else
            echo -e "${RED}  ✗ Flake8 found issues${NC}"
            EXIT_CODE=1
        fi
    fi
fi

# Shell scripts
SH_FILES=$(echo "$STAGED_FILES" | grep -E '\.sh$' || true)
if [ -n "$SH_FILES" ] && command -v shellcheck &> /dev/null; then
    echo "  Checking shell scripts..."
    if echo "$SH_FILES" | xargs shellcheck -S warning 2>/dev/null; then
        echo -e "${GREEN}  ✓ ShellCheck passed${NC}"
    else
        echo -e "${YELLOW}  ⚠ ShellCheck warnings (non-blocking)${NC}"
    fi
fi

# -------------------------------------------------------------------------
# Final Result
# -------------------------------------------------------------------------
echo ""
if [ $EXIT_CODE -ne 0 ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}Pre-commit checks FAILED. Please fix the issues above.${NC}"
    echo -e "${YELLOW}To bypass (not recommended): git commit --no-verify${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}All pre-commit checks passed!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

exit $EXIT_CODE
HOOK_EOF
    chmod +x .git/hooks/pre-commit
    log_success "Installed pre-commit git hook"

    # -------------------------------------------------------------------------
    # Commit-msg Hook - Conventional Commits Validation
    # -------------------------------------------------------------------------
    cat > .git/hooks/commit-msg << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# Claude Code Commit Message Hook
# Validates commit message format (conventional commits)
# ==============================================================================

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Skip merge commits and fixup/squash commits
if echo "$commit_msg" | grep -qE "^(Merge|fixup!|squash!)"; then
    exit 0
fi

# Skip WIP commits (optional - remove this block if you want to enforce on WIP)
if echo "$commit_msg" | grep -qi "^wip"; then
    echo -e "${YELLOW}⚠ WIP commit detected - skipping validation${NC}"
    exit 0
fi

# Conventional commit pattern
# type(optional-scope): description
pattern="^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-zA-Z0-9_-]+\))?: .{3,}"

if ! echo "$commit_msg" | head -1 | grep -qE "$pattern"; then
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}ERROR: Invalid commit message format${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Expected format:${NC} <type>(<scope>): <description>"
    echo ""
    echo -e "${YELLOW}Valid types:${NC}"
    echo "  feat     - New feature"
    echo "  fix      - Bug fix"
    echo "  docs     - Documentation changes"
    echo "  style    - Code style (formatting, semicolons)"
    echo "  refactor - Code refactoring"
    echo "  perf     - Performance improvements"
    echo "  test     - Adding/updating tests"
    echo "  build    - Build system changes"
    echo "  ci       - CI/CD changes"
    echo "  chore    - Maintenance tasks"
    echo "  revert   - Reverting changes"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  feat(auth): add OAuth2 login support"
    echo "  fix: resolve race condition in worker pool"
    echo "  docs(readme): update installation instructions"
    echo "  refactor(api): simplify error handling"
    echo ""
    echo -e "${YELLOW}Your message:${NC} $commit_msg"
    echo ""
    echo -e "${YELLOW}To bypass (not recommended): git commit --no-verify${NC}"
    echo ""
    exit 1
fi

# Check message length (first line should be < 72 chars)
first_line=$(echo "$commit_msg" | head -1)
if [ ${#first_line} -gt 72 ]; then
    echo -e "${YELLOW}⚠ Warning: First line is ${#first_line} chars (recommended: <72)${NC}"
fi

echo -e "${GREEN}✓ Commit message format valid${NC}"
exit 0
HOOK_EOF
    chmod +x .git/hooks/commit-msg
    log_success "Installed commit-msg git hook"

    # -------------------------------------------------------------------------
    # Prepare-commit-msg Hook - Auto-generate context
    # -------------------------------------------------------------------------
    cat > .git/hooks/prepare-commit-msg << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# Claude Code Prepare Commit Message Hook
# Auto-generates commit context before message editing
# ==============================================================================

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Only run for regular commits (not merges, squashes, etc.)
if [ -n "$COMMIT_SOURCE" ]; then
    exit 0
fi

# Run commit context generator if it exists
if [ -f ".claude/hooks/commit-context-generator.py" ] && command -v python3 &> /dev/null; then
    python3 .claude/hooks/commit-context-generator.py 2>/dev/null || true
fi

exit 0
HOOK_EOF
    chmod +x .git/hooks/prepare-commit-msg
    log_success "Installed prepare-commit-msg git hook"

    # -------------------------------------------------------------------------
    # Post-commit Hook - Notifications and cleanup
    # -------------------------------------------------------------------------
    cat > .git/hooks/post-commit << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# Claude Code Post-Commit Hook
# Runs after successful commit for notifications and cleanup
# ==============================================================================

GREEN='\033[0;32m'
NC='\033[0m'

# Get commit info
COMMIT_HASH=$(git rev-parse --short HEAD)
COMMIT_MSG=$(git log -1 --pretty=%s)
BRANCH=$(git branch --show-current)

echo -e "${GREEN}✓ Committed ${COMMIT_HASH} on ${BRANCH}${NC}"

# Run notification hook if it exists
if [ -f ".claude/hooks/notify.py" ] && command -v python3 &> /dev/null; then
    python3 .claude/hooks/notify.py --event "commit" --message "Committed: $COMMIT_MSG" 2>/dev/null || true
fi

exit 0
HOOK_EOF
    chmod +x .git/hooks/post-commit
    log_success "Installed post-commit git hook"

    # -------------------------------------------------------------------------
    # Pre-push Hook - Final checks before push
    # -------------------------------------------------------------------------
    cat > .git/hooks/pre-push << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# Claude Code Pre-Push Hook
# Final checks before pushing to remote
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Read push details
while read local_ref local_sha remote_ref remote_sha; do
    # Prevent force push to main/master
    if [[ "$remote_ref" =~ refs/heads/(main|master)$ ]]; then
        # Check if this is a force push
        if [ "$remote_sha" != "0000000000000000000000000000000000000000" ]; then
            merge_base=$(git merge-base "$local_sha" "$remote_sha" 2>/dev/null)
            if [ "$merge_base" != "$remote_sha" ]; then
                echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${RED}ERROR: Force push to ${remote_ref##*/} is blocked!${NC}"
                echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                echo "Force pushing to protected branches can cause data loss."
                echo "If you really need to do this, use: git push --force --no-verify"
                echo ""
                exit 1
            fi
        fi
    fi
done

echo -e "${GREEN}✓ Pre-push checks passed${NC}"
exit 0
HOOK_EOF
    chmod +x .git/hooks/pre-push
    log_success "Installed pre-push git hook"

    log_success "All git hooks installed (5 hooks total)"
}

install_language_profile() {
    if [ "$INSTALL_PROFILES" = false ] || [ -z "$PROFILE_NAME" ]; then
        return 0
    fi

    log_header "Installing Language Profile: $PROFILE_NAME"

    local profile_dir="$TEMP_DIR/profiles/$PROFILE_NAME"

    if [ ! -d "$profile_dir" ]; then
        log_error "Profile '$PROFILE_NAME' not found. Available: python, java"
        return 1
    fi

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install $PROFILE_NAME profile"
        return 0
    fi

    # Copy profile-specific commands
    if [ -d "$profile_dir/.claude/commands" ]; then
        cp -R "$profile_dir/.claude/commands/"* .claude/commands/ 2>/dev/null || true
        log_success "Installed $PROFILE_NAME commands"
    fi

    # Copy profile-specific skills
    if [ -d "$profile_dir/.claude/skills" ]; then
        cp -R "$profile_dir/.claude/skills/"* .claude/skills/ 2>/dev/null || true
        log_success "Installed $PROFILE_NAME skills"
    fi

    # Copy profile-specific workflows
    if [ -d "$profile_dir/.github/workflows" ]; then
        cp -R "$profile_dir/.github/workflows/"* .github/workflows/ 2>/dev/null || true
        log_success "Installed $PROFILE_NAME CI workflow"
    fi

    # Copy profile CLAUDE.md additions
    if [ -f "$profile_dir/CLAUDE.md" ]; then
        cat >> CLAUDE.md << EOF

---

## Language Profile: $PROFILE_NAME

$(cat "$profile_dir/CLAUDE.md")
EOF
        log_success "Appended $PROFILE_NAME configuration to CLAUDE.md"
    fi
}

update_gitignore() {
    log_header "Updating .gitignore"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would update .gitignore with Claude Code entries"
        return 0
    fi

    # Entries to add
    local entries=(
        "# Claude Code"
        ".claude/notifications.json"
        ".claude/artifacts/"
        ".claude/metrics/"
        "*.backup.*"
    )

    touch .gitignore

    for entry in "${entries[@]}"; do
        if ! grep -qF "$entry" .gitignore 2>/dev/null; then
            echo "$entry" >> .gitignore
        fi
    done

    log_success "Updated .gitignore"
}

# ------------------------------------------------------------------------------
# Summary and Next Steps
# ------------------------------------------------------------------------------
print_summary() {
    log_header "Installation Summary"

    echo ""
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] No changes were made${NC}"
        echo ""
    fi

    echo -e "${BOLD}Components Installed:${NC}"
    echo -e "  ${GREEN}✓${NC} Slash Commands:    $COMMANDS_INSTALLED"
    echo -e "  ${GREEN}✓${NC} Agents:            $AGENTS_INSTALLED"
    echo -e "  ${GREEN}✓${NC} Skills:            $SKILLS_INSTALLED"
    echo -e "  ${GREEN}✓${NC} Hooks:             $HOOKS_INSTALLED"
    echo -e "  ${GREEN}✓${NC} GitHub Workflows:  $WORKFLOWS_INSTALLED"

    if [ "$INSTALL_GIT_HOOKS" = true ]; then
        echo -e "  ${GREEN}✓${NC} Git Hooks:         5 (pre-commit, commit-msg, prepare-commit-msg, post-commit, pre-push)"
    fi

    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Next Steps:${NC}"
    echo ""

    echo -e "${YELLOW}1. Configure Notifications (Optional):${NC}"
    echo "   Edit .claude/notifications.json with your webhook URLs"
    echo ""

    echo -e "${YELLOW}2. Configure GitHub Secrets (Required for CI):${NC}"
    echo "   Repository Settings → Secrets → Actions:"
    echo "   • GH_TOKEN - Personal Access Token with 'repo' scope"
    echo "   • GEMINI_API_KEY - For AI-powered PR reviews"
    echo "   • SLACK_WEBHOOK_URL / DISCORD_WEBHOOK_URL - Notifications"
    echo ""

    echo -e "${YELLOW}3. Commit the Configuration:${NC}"
    echo "   git add .claude .github CLAUDE.md .gitignore"
    echo "   git commit -m \"chore: install claude-code professional team\""
    echo ""

    echo -e "${YELLOW}4. Start Using Claude Code:${NC}"
    echo "   /plan          - Plan before implementing"
    echo "   /ralph         - Autonomous development loop"
    echo "   /qa            - Run tests until green"
    echo "   /ship          - Commit, push, create PR"
    echo ""

    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}Installation Complete!${NC}"
    echo -e "Documentation: ${BLUE}https://github.com/bigdegenenergy/claude-code${NC}"
}

# ------------------------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------------------------
main() {
    print_banner
    parse_arguments "$@"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}${BOLD}DRY RUN MODE - No changes will be made${NC}"
        echo ""
    fi

    check_prerequisites
    download_source
    install_claude_directory
    install_claude_md
    install_github_workflows
    install_git_hooks
    install_language_profile
    update_gitignore
    print_summary
}

main "$@"
