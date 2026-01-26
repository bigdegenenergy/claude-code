#!/bin/bash

# ==============================================================================
# AI Dev Toolkit - Development Workflow Configuration Installer
# Source: https://github.com/bigdegenenergy/ai-dev-toolkit
#
# DISCLAIMER: This is a COMMUNITY PROJECT and is NOT affiliated with,
# endorsed by, or officially connected to Anthropic, OpenAI, Google, or any
# AI vendor. This toolkit provides workflow configurations that work with
# any AI coding assistant or can be used standalone.
#
# LICENSE: MIT License - See repository for full terms
# SECURITY: All scripts are open source and auditable. No telemetry or
#           data collection. All data remains local to your machine.
#
# Installs development workflow configurations:
#   - 38 Slash Commands (workflows and orchestration)
#   - 19 Specialized Agents (subagents for different domains)
#   - 18 Auto-Discovered Skills (context-aware expertise)
#   - 11 Automated Hooks (quality gates and automation)
#   - 13 GitHub Actions Workflows (CI/CD automation)
#   - 5 Git Hooks (pre-commit, commit-msg, prepare-commit-msg, post-commit, pre-push)
#
# Usage (Multiple Methods):
#
#   Method 1 - Direct git clone (RECOMMENDED - uses local files, no re-download):
#     git clone https://github.com/bigdegenenergy/ai-dev-toolkit.git /tmp/ai-dev-toolkit && \
#     bash /tmp/ai-dev-toolkit/install.sh && \
#     rm -rf /tmp/ai-dev-toolkit
#
#   Method 2 - One-liner via curl (downloads fresh each time):
#     curl -fsSL https://raw.githubusercontent.com/bigdegenenergy/ai-dev-toolkit/main/install.sh | bash
#
#   Method 3 - Download script only (will fetch source on run):
#     curl -fsSL -o install.sh https://raw.githubusercontent.com/bigdegenenergy/ai-dev-toolkit/main/install.sh
#     bash install.sh
#
# Note: When run from a cloned repo, uses local files automatically (no extra download).
#
# With options:
#   bash install.sh [OPTIONS]
#
# Options:
#   --update         Update existing installation to latest version
#   --no-github      Skip GitHub Actions workflows
#   --no-git-hooks   Skip git hooks setup
#   --no-profiles    Skip language profiles
#   --profile=NAME   Install specific profile (python, java)
#   --web            Install web-compatible configuration
#   --force          Overwrite existing files without prompting (non-interactive)
#   --dry-run        Show what would be installed without making changes
#   --help           Show this help message
# ==============================================================================

# Ensure we're running in bash (not sh/dash)
if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
fi

set -e

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
VERSION="2.3.0"
# Use main branch until first release is tagged
# TODO: Update to "v2.3.0" after creating the release tag
SOURCE_TAG="main"
SOURCE_REPO="https://github.com/bigdegenenergy/ai-dev-toolkit.git"
SOURCE_RAW="https://raw.githubusercontent.com/bigdegenenergy/ai-dev-toolkit/main"

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
UPDATE_MODE=false

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
    _    ___   ____                 _____           _ _    _ _
   / \  |_ _| |  _ \  _____   __   |_   _|__   ___ | | | _(_) |_
  / _ \  | |  | | | |/ _ \ \ / /     | |/ _ \ / _ \| | |/ / | __|
 / ___ \ | |  | |_| |  __/\ V /      | | (_) | (_) | |   <| | |_
/_/   \_\___| |____/ \___| \_/       |_|\___/ \___/|_|_|\_\_|\__|

EOF
    echo -e "${NC}"
    echo -e "${BOLD}AI Dev Toolkit - Workflow Configuration Installer v${VERSION}${NC}"
    echo -e "Source: ${BLUE}https://github.com/bigdegenenergy/ai-dev-toolkit${NC}"
    echo ""
    echo -e "${YELLOW}NOTICE: Community project - NOT affiliated with any AI vendor${NC}"
    echo -e "${YELLOW}Works with any AI assistant (Claude, GPT, Gemini, etc.) or standalone${NC}"
    echo ""
}

print_help() {
    print_banner
    cat << EOF
Usage: $0 [OPTIONS]

Installs AI Dev Toolkit configuration to amplify solo developer capabilities.

OPTIONS:
    --update         Update existing installation to latest version
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

    # Update existing installation to latest
    $0 --update

    # Install with Python profile
    $0 --profile=python

    # Web-compatible installation
    $0 --web

    # Preview what would be installed
    $0 --dry-run

WHAT GETS INSTALLED:
    .claude/
    ├── commands/     (38 slash commands)
    ├── agents/       (19 specialized subagents)
    ├── skills/       (18 auto-discovered skills)
    ├── hooks/        (11 automated quality gates)
    ├── templates/    (project templates)
    └── settings.json (permissions & hook config)

    .github/
    ├── workflows/    (13 CI/CD workflows)
    ├── scripts/      (Claude Code SDK scripts)
    └── ISSUE_TEMPLATE/

    docs/             (setup guides and references)
    tools/            (utilities like onefilellm)

    .mcp.json.template (MCP server configuration)

    NOTE: CLAUDE.md is NOT installed - each repo maintains its own project instructions.

For more information, visit: https://github.com/bigdegenenergy/ai-dev-toolkit
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
        echo ""
        echo "This script must be run from within an existing git repository."
        echo "To create a new repository: git init"
        exit 1
    fi

    # Verify .git directory exists (explicit check)
    if [ ! -d ".git" ] && [ ! -d "$(git rev-parse --git-dir 2>/dev/null)" ]; then
        log_error "Cannot find .git directory. Please run from repository root."
        exit 1
    fi

    # Move to git root
    GIT_ROOT=$(git rev-parse --show-toplevel)
    cd "$GIT_ROOT"
    log_success "Git root: $GIT_ROOT"

    # Auto-detect existing installation and switch to update mode
    if [ -d "$GIT_ROOT/.claude/commands" ] && [ -d "$GIT_ROOT/.claude/agents" ]; then
        log_info "Existing installation detected - updating to latest version"
        UPDATE_MODE=true
        FORCE_MODE=true
    fi

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

    # Check for Python3 (optional - used by some hooks)
    if command -v python3 &> /dev/null; then
        log_success "python3 found (optional hooks will be enabled)"
    else
        log_warning "python3 not found - some optional hooks will be disabled"
        log_info "Git hooks will still work, but commit-context and notification features won't run"
    fi
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --update)
                UPDATE_MODE=true
                FORCE_MODE=true  # Updates should overwrite without prompting
                shift
                ;;
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

# Detect script directory for local source detection
# When piped via curl, BASH_SOURCE[0] may be empty or /dev/stdin, so SCRIPT_DIR becomes current dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

# Check if we're running from a real file (not piped via curl)
RUNNING_FROM_FILE=false
if [ -f "$SCRIPT_DIR/install.sh" ]; then
    RUNNING_FROM_FILE=true
fi

download_source() {
    log_header "Locating AI Dev Toolkit Configuration"

    # If piped via curl (not running from a file), always download from remote
    if [ "$RUNNING_FROM_FILE" = false ]; then
        log_info "Downloading from remote repository..."

        TEMP_DIR=$(mktemp -d)
        USE_LOCAL_SOURCE=false
        trap 'rm -rf "$TEMP_DIR"' EXIT

        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY RUN] Would clone $SOURCE_REPO (tag: $SOURCE_TAG) to $TEMP_DIR"
            return 0
        fi

        log_info "Cloning repository (version: $SOURCE_TAG)..."
        if ! git clone --quiet --depth 1 --branch "$SOURCE_TAG" "$SOURCE_REPO" "$TEMP_DIR" 2>/dev/null; then
            log_error "Failed to clone version $SOURCE_TAG"
            log_error "The requested version may not exist or there may be a network issue."
            log_error "Available versions: https://github.com/bigdegenenergy/ai-dev-toolkit/tags"
            exit 1
        fi
        log_success "Downloaded configuration source (pinned to $SOURCE_TAG)"
        return 0
    fi

    # Running from a local file - check if it's the toolkit source repo
    if [ -d "$SCRIPT_DIR/.claude" ] && [ -d "$SCRIPT_DIR/.github" ] && [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
        log_success "Using local source files from: $SCRIPT_DIR"
        TEMP_DIR="$SCRIPT_DIR"
        USE_LOCAL_SOURCE=true
        return 0
    fi

    # Local file but not a complete toolkit - download from remote
    log_info "Downloading from remote repository..."

    TEMP_DIR=$(mktemp -d)
    USE_LOCAL_SOURCE=false
    trap 'rm -rf "$TEMP_DIR"' EXIT

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would clone $SOURCE_REPO (tag: $SOURCE_TAG) to $TEMP_DIR"
        return 0
    fi

    log_info "Cloning repository (version: $SOURCE_TAG)..."
    if ! git clone --quiet --depth 1 --branch "$SOURCE_TAG" "$SOURCE_REPO" "$TEMP_DIR" 2>/dev/null; then
        log_error "Failed to clone version $SOURCE_TAG"
        log_error "The requested version may not exist or there may be a network issue."
        log_error "Available versions: https://github.com/bigdegenenergy/ai-dev-toolkit/tags"
        exit 1
    fi
    log_success "Downloaded configuration source (pinned to $SOURCE_TAG)"
}

install_claude_directory() {
    log_header "Installing .claude Directory"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install .claude directory with:"
        log_info "  - commands/ (38 slash commands)"
        log_info "  - agents/ (19 subagents)"
        log_info "  - skills/ (18 skills)"
        log_info "  - hooks/ (11 hooks)"
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

install_mcp_template() {
    log_header "Installing MCP Server Template"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install .mcp.json.template for MCP server configuration"
        return 0
    fi

    if [ -f "$TEMP_DIR/.mcp.json.template" ]; then
        if [ -f ".mcp.json.template" ]; then
            if confirm_overwrite ".mcp.json.template"; then
                cp "$TEMP_DIR/.mcp.json.template" .mcp.json.template
                log_success "Updated .mcp.json.template"
            else
                log_warning "Kept existing .mcp.json.template"
            fi
        else
            cp "$TEMP_DIR/.mcp.json.template" .mcp.json.template
            log_success "Installed .mcp.json.template (MCP server configuration)"
        fi
        log_info "To enable MCP servers: cp .mcp.json.template .mcp.json && edit"
    fi
}

install_docs() {
    log_header "Installing Documentation"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install docs/ directory with setup guides and references"
        return 0
    fi

    if [ -d "$TEMP_DIR/docs" ]; then
        mkdir -p docs

        # Copy documentation files (excluding generated content like onefilellm/)
        for doc in "$TEMP_DIR/docs/"*.md; do
            [ -f "$doc" ] || continue
            local basename
            basename=$(basename "$doc")
            cp "$doc" "docs/$basename"
        done

        local DOCS_INSTALLED
        DOCS_INSTALLED=$(find docs -maxdepth 1 -name "*.md" 2>/dev/null | wc -l)
        if [ "$DOCS_INSTALLED" -gt 0 ]; then
            log_success "Installed $DOCS_INSTALLED documentation files"
        fi
    fi
}

install_tools() {
    log_header "Installing Tools"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install tools/ directory with utilities"
        return 0
    fi

    if [ -d "$TEMP_DIR/tools" ]; then
        mkdir -p tools

        # Copy tools directories
        for tool_dir in "$TEMP_DIR/tools/"*/; do
            [ -d "$tool_dir" ] || continue
            local toolname
            toolname=$(basename "$tool_dir")
            cp -R "$tool_dir" "tools/"
            log_success "Installed tools/$toolname"
        done

        # Set executable permissions on scripts/binaries within tools/
        # Similar to .claude/hooks/ and .github/scripts/ handling
        find tools -type f \( -name "*.sh" -o -name "*.py" -o -name "*.mjs" -o -name "*.cjs" -o -name "*.js" \) -exec chmod +x {} \; 2>/dev/null || true
        log_info "Set executable permissions on tool scripts"
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

    # Verify source .github directory exists
    if [ ! -d "$TEMP_DIR/.github" ]; then
        log_error "Source .github directory not found in: $TEMP_DIR"
        log_error "GitHub workflows cannot be installed. Please report this issue."
        return 1
    fi

    if [ ! -d "$TEMP_DIR/.github/workflows" ]; then
        log_warning "Source .github/workflows directory not found"
        log_warning "No GitHub Actions workflows will be installed"
    fi

    # Check for existing workflows and warn before overwriting
    if [ -d ".github/workflows" ] && [ "$(ls -A .github/workflows 2>/dev/null)" ]; then
        local EXISTING_WORKFLOWS
        EXISTING_WORKFLOWS=$(ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | wc -l)
        if [ "$EXISTING_WORKFLOWS" -gt 0 ]; then
            log_warning "Found $EXISTING_WORKFLOWS existing workflow(s) in .github/workflows/"
            if [ "$FORCE_MODE" = false ]; then
                echo -en "${YELLOW}Existing workflows may be overwritten. Continue? [y/N] ${NC}"
                read -r response
                case "$response" in
                    [yY][eE][sS]|[yY]) ;;
                    *)
                        log_info "Skipping GitHub workflows installation"
                        return 0
                        ;;
                esac
            else
                log_warning "Force mode: proceeding with workflow installation"
            fi
        fi
    fi

    # Copy workflows (with backup for existing files)
    if [ -d "$TEMP_DIR/.github/workflows" ]; then
        local TIMESTAMP
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        for workflow in "$TEMP_DIR/.github/workflows/"*.yml "$TEMP_DIR/.github/workflows/"*.yaml; do
            [ -f "$workflow" ] || continue
            local basename
            basename=$(basename "$workflow")
            if [ -f ".github/workflows/$basename" ]; then
                cp ".github/workflows/$basename" ".github/workflows/${basename}.backup.${TIMESTAMP}"
                log_info "Backed up existing $basename"
            fi
            cp "$workflow" ".github/workflows/"
        done
        WORKFLOWS_INSTALLED=$(find .github/workflows -maxdepth 1 \( -name "*.yml" -o -name "*.yaml" \) ! -name "*.backup.*" 2>/dev/null | wc -l)
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

    # Copy scripts directory (Claude Code SDK implementation scripts)
    if [ -d "$TEMP_DIR/.github/scripts" ]; then
        mkdir -p .github/scripts
        cp -R "$TEMP_DIR/.github/scripts/"* .github/scripts/ 2>/dev/null || true
        chmod +x .github/scripts/*.cjs .github/scripts/*.js .github/scripts/*.sh 2>/dev/null || true
        log_success "Installed GitHub scripts (Claude Code SDK)"
    fi

    # Copy MCP config template
    if [ -f "$TEMP_DIR/.github/mcp-config.json.template" ]; then
        cp "$TEMP_DIR/.github/mcp-config.json.template" .github/
        log_success "Installed MCP config template"
    fi
}

install_git_hooks() {
    if [ "$INSTALL_GIT_HOOKS" = false ]; then
        log_info "Skipping git hooks (--no-git-hooks)"
        return 0
    fi

    log_header "Installing Git Hooks"

    # -------------------------------------------------------------------------
    # Check for custom core.hooksPath (used by Husky, etc.)
    # -------------------------------------------------------------------------
    local CUSTOM_HOOKS_PATH
    CUSTOM_HOOKS_PATH=$(git config core.hooksPath 2>/dev/null || true)

    if [ -n "$CUSTOM_HOOKS_PATH" ]; then
        log_warning "Custom hooks path detected: $CUSTOM_HOOKS_PATH"
        log_warning "Git is configured to use '$CUSTOM_HOOKS_PATH' instead of '.git/hooks/'"
        if [ "$FORCE_MODE" = false ]; then
            echo -e "${YELLOW}Options:${NC}"
            echo "  1) Install to custom path ($CUSTOM_HOOKS_PATH)"
            echo "  2) Install to default (.git/hooks/) - hooks won't run until core.hooksPath is unset"
            echo "  3) Skip git hooks installation"
            echo -en "${YELLOW}Choose [1/2/3]: ${NC}"
            read -r response
            case "$response" in
                1)
                    HOOKS_DIR="$CUSTOM_HOOKS_PATH"
                    mkdir -p "$HOOKS_DIR"
                    log_info "Installing to custom hooks path: $HOOKS_DIR"
                    ;;
                2)
                    HOOKS_DIR=".git/hooks"
                    log_warning "Installing to default path - run 'git config --unset core.hooksPath' to activate"
                    ;;
                *)
                    log_info "Skipping git hooks installation"
                    return 0
                    ;;
            esac
        else
            # Force mode: install to custom path
            HOOKS_DIR="$CUSTOM_HOOKS_PATH"
            mkdir -p "$HOOKS_DIR"
            log_warning "Force mode: installing to custom hooks path: $HOOKS_DIR"
        fi
    else
        HOOKS_DIR=".git/hooks"
    fi

    # -------------------------------------------------------------------------
    # Detect existing hook managers
    # -------------------------------------------------------------------------
    local HOOK_MANAGER_DETECTED=""

    # Check for Husky (Node.js)
    if [ -d ".husky" ] || grep -q '"husky"' package.json 2>/dev/null; then
        HOOK_MANAGER_DETECTED="husky"
    # Check for lint-staged
    elif grep -q '"lint-staged"' package.json 2>/dev/null; then
        HOOK_MANAGER_DETECTED="lint-staged"
    # Check for pre-commit (Python)
    elif [ -f ".pre-commit-config.yaml" ] || [ -f ".pre-commit-config.yml" ]; then
        HOOK_MANAGER_DETECTED="pre-commit (Python)"
    # Check for lefthook
    elif [ -f "lefthook.yml" ] || [ -f ".lefthook.yml" ]; then
        HOOK_MANAGER_DETECTED="lefthook"
    fi

    if [ -n "$HOOK_MANAGER_DETECTED" ]; then
        log_warning "Detected existing hook manager: $HOOK_MANAGER_DETECTED"
        if [ "$FORCE_MODE" = false ]; then
            echo -en "${YELLOW}Installing AI Dev Toolkit hooks may conflict with $HOOK_MANAGER_DETECTED. Continue? [y/N] ${NC}"
            read -r response
            case "$response" in
                [yY][eE][sS]|[yY]) ;;
                *)
                    log_info "Skipping git hooks installation"
                    return 0
                    ;;
            esac
        else
            log_warning "Force mode enabled - proceeding despite hook manager detection"
        fi
    fi

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would install git hooks:"
        log_info "  - pre-commit (linting, formatting, PII scan)"
        log_info "  - commit-msg (conventional commits)"
        log_info "  - prepare-commit-msg (context generation)"
        log_info "  - post-commit (notifications)"
        log_info "  - pre-push (force-push protection)"
        return 0
    fi

    # Create git hooks directory if needed
    mkdir -p "$HOOKS_DIR"

    # -------------------------------------------------------------------------
    # Backup existing hooks with timestamps
    # -------------------------------------------------------------------------
    local TIMESTAMP=$(date +%Y%m%d%H%M%S)
    local HOOKS_TO_INSTALL=(pre-commit commit-msg prepare-commit-msg post-commit pre-push)

    for hook in "${HOOKS_TO_INSTALL[@]}"; do
        if [ -f "$HOOKS_DIR/$hook" ] && [ ! -L "$HOOKS_DIR/$hook" ]; then
            # Check if it's not already a AI Dev Toolkit hook
            if ! grep -q "AI Dev Toolkit" "$HOOKS_DIR/$hook" 2>/dev/null; then
                local backup_path="$HOOKS_DIR/${hook}.backup.${TIMESTAMP}"
                cp "$HOOKS_DIR/$hook" "$backup_path"
                log_info "Backed up existing $hook to ${hook}.backup.${TIMESTAMP}"
            fi
        fi
    done

    # -------------------------------------------------------------------------
    # Pre-commit Hook - Linting, Formatting, Security Checks
    # -------------------------------------------------------------------------
    cat > "$HOOKS_DIR/pre-commit" << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# AI Dev Toolkit Pre-Commit Hook
# Runs before each commit to ensure code quality and security
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Running AI Dev Toolkit pre-commit checks...${NC}"

# Get staged files with null-delimiter for proper handling of special characters
# Using process substitution which works in Bash 3.2+ (macOS compatible)
STAGED_FILES=()
while IFS= read -r -d '' file; do
    [[ -n "$file" ]] && STAGED_FILES+=("$file")
done < <(git diff --cached --name-only -z --diff-filter=ACM)

if [ ${#STAGED_FILES[@]} -eq 0 ]; then
    echo "No staged files to check"
    exit 0
fi

EXIT_CODE=0
SECRETS_FOUND=false

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

for file in "${STAGED_FILES[@]}"; do
    if [ -f "$file" ]; then
        for pattern in "${SECRET_PATTERNS[@]}"; do
            # IMPORTANT: Scan staged content, not working directory
            if git show ":$file" 2>/dev/null | grep -iE "$pattern" | grep -v "example\|sample\|test\|mock\|dummy" > /dev/null; then
                echo -e "${RED}✗ Potential secret found in: $file${NC}"
                echo "  Pattern: $pattern"
                SECRETS_FOUND=true
                EXIT_CODE=1
            fi
        done
    fi
done

if [ "$SECRETS_FOUND" = false ]; then
    echo -e "${GREEN}✓ No secrets detected${NC}"
fi

# -------------------------------------------------------------------------
# 3. Check for PII (Personal Identifiable Information)
# Only SSN and credit cards block commits; emails are warnings only
# -------------------------------------------------------------------------
echo -e "\n${YELLOW}→ Scanning for PII...${NC}"

PII_FOUND=false
for file in "${STAGED_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Skip common config files and documentation by extension (PII scan only)
        # Note: These files ARE still scanned for secrets in section 2 above
        case "$file" in
            *.md|*.txt|*.json|*.yaml|*.yml|*.toml|LICENSE*|CHANGELOG*|AUTHORS*)
                continue
                ;;
        esac

        # Skip binary files - stream content directly (no variable buffering)
        # This avoids memory issues and binary data corruption from null bytes
        if ! git show ":$file" 2>/dev/null | file - 2>/dev/null | grep -q "text"; then
            continue
        fi

        # Email addresses - WARNING only (too many false positives)
        if git show ":$file" 2>/dev/null | grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | \
           grep -vE '@example|@test|@localhost|@email\.com|@mail\.com|@users\.noreply\.github\.com' > /dev/null; then
            echo -e "${YELLOW}⚠ Email address found in: $file (warning only)${NC}"
            PII_FOUND=true
            # Note: Not setting EXIT_CODE - emails don't block commits
        fi

        # SSN pattern - BLOCKS commit (use [^0-9] instead of \b for portability)
        if git show ":$file" 2>/dev/null | grep -E '(^|[^0-9])[0-9]{3}-[0-9]{2}-[0-9]{4}([^0-9]|$)' > /dev/null; then
            echo -e "${RED}✗ SSN pattern found in: $file${NC}"
            PII_FOUND=true
            EXIT_CODE=1
        fi

        # Credit card pattern - BLOCKS commit (use [^0-9] instead of \b for portability)
        if git show ":$file" 2>/dev/null | grep -E '(^|[^0-9])[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}([^0-9]|$)' > /dev/null; then
            echo -e "${RED}✗ Credit card pattern found in: $file${NC}"
            PII_FOUND=true
            EXIT_CODE=1
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

# Filter files by extension (handles spaces in filenames)
JS_FILES=()
PY_FILES=()
SH_FILES=()
for file in "${STAGED_FILES[@]}"; do
    case "$file" in
        *.js|*.jsx|*.ts|*.tsx) JS_FILES+=("$file") ;;
        *.py) PY_FILES+=("$file") ;;
        *.sh) SH_FILES+=("$file") ;;
    esac
done

# JavaScript/TypeScript
if [ ${#JS_FILES[@]} -gt 0 ] && command -v npx &> /dev/null; then
    if [ -f "package.json" ] && grep -q "eslint" package.json 2>/dev/null; then
        echo "  Linting JavaScript/TypeScript..."
        if npx eslint --quiet "${JS_FILES[@]}" 2>/dev/null; then
            echo -e "${GREEN}  ✓ ESLint passed${NC}"
        else
            echo -e "${RED}  ✗ ESLint found issues${NC}"
            EXIT_CODE=1
        fi
    fi
fi

# Python
if [ ${#PY_FILES[@]} -gt 0 ]; then
    if command -v ruff &> /dev/null; then
        echo "  Linting Python with ruff..."
        if ruff check --quiet "${PY_FILES[@]}" 2>/dev/null; then
            echo -e "${GREEN}  ✓ Ruff passed${NC}"
        else
            echo -e "${RED}  ✗ Ruff found issues${NC}"
            EXIT_CODE=1
        fi
    elif command -v flake8 &> /dev/null; then
        echo "  Linting Python with flake8..."
        if flake8 --quiet "${PY_FILES[@]}" 2>/dev/null; then
            echo -e "${GREEN}  ✓ Flake8 passed${NC}"
        else
            echo -e "${RED}  ✗ Flake8 found issues${NC}"
            EXIT_CODE=1
        fi
    fi
fi

# Shell scripts
if [ ${#SH_FILES[@]} -gt 0 ] && command -v shellcheck &> /dev/null; then
    echo "  Checking shell scripts..."
    if shellcheck -S warning "${SH_FILES[@]}" 2>/dev/null; then
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
    chmod +x "$HOOKS_DIR/pre-commit"
    log_success "Installed pre-commit git hook"

    # -------------------------------------------------------------------------
    # Commit-msg Hook - Conventional Commits Validation
    # -------------------------------------------------------------------------
    cat > "$HOOKS_DIR/commit-msg" << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# AI Dev Toolkit Commit Message Hook
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
    chmod +x "$HOOKS_DIR/commit-msg"
    log_success "Installed commit-msg git hook"

    # -------------------------------------------------------------------------
    # Prepare-commit-msg Hook - Auto-generate context
    # -------------------------------------------------------------------------
    cat > "$HOOKS_DIR/prepare-commit-msg" << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# AI Dev Toolkit Prepare Commit Message Hook
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
    chmod +x "$HOOKS_DIR/prepare-commit-msg"
    log_success "Installed prepare-commit-msg git hook"

    # -------------------------------------------------------------------------
    # Post-commit Hook - Notifications and cleanup
    # -------------------------------------------------------------------------
    cat > "$HOOKS_DIR/post-commit" << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# AI Dev Toolkit Post-Commit Hook
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
    chmod +x "$HOOKS_DIR/post-commit"
    log_success "Installed post-commit git hook"

    # -------------------------------------------------------------------------
    # Pre-push Hook - Final checks before push
    # -------------------------------------------------------------------------
    cat > "$HOOKS_DIR/pre-push" << 'HOOK_EOF'
#!/bin/bash
# ==============================================================================
# AI Dev Toolkit Pre-Push Hook
# Final checks before pushing to remote
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Null SHA used by git for new branches (40 zeros)
NULL_SHA=$(printf '0%.0s' {1..40})

# Read push details
while read local_ref local_sha remote_ref remote_sha; do
    # Prevent force push to main/master
    if [[ "$remote_ref" =~ refs/heads/(main|master)$ ]]; then
        # Check if this is a force push (not a new branch)
        if [ "$remote_sha" != "$NULL_SHA" ]; then
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
    chmod +x "$HOOKS_DIR/pre-push"
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
        log_info "[DRY RUN] Would update .gitignore with AI Dev Toolkit entries"
        return 0
    fi

    touch .gitignore

    # Add entries with explanatory comments (only if not already present)
    # These entries protect sensitive local data from being committed

    if ! grep -qF "# AI Dev Toolkit local configuration" .gitignore 2>/dev/null; then
        cat >> .gitignore << 'GITIGNORE_EOF'

# AI Dev Toolkit local configuration
# These files contain LOCAL-ONLY data and should never be committed:

# User's notification webhook URLs (contains personal service tokens)
.claude/notifications.json

# Generated analysis artifacts (temporary files)
.claude/artifacts/

# Local performance metrics (machine-specific)
.claude/metrics/

# Backup files created during hook installation
*.backup.*
GITIGNORE_EOF
        log_success "Updated .gitignore with documented entries"
    else
        log_info ".gitignore already contains AI Dev Toolkit entries"
    fi
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

    echo -e "${YELLOW}1. Review installed files:${NC}"
    echo "   All installed scripts are plain text and auditable:"
    echo "   • .claude/commands/  - Workflow templates (markdown)"
    echo "   • .claude/hooks/     - Quality gate scripts (bash/python)"
    echo "   • .github/workflows/ - CI/CD pipelines (yaml)"
    echo "   • docs/              - Setup guides and references"
    echo "   • tools/             - Utilities (onefilellm, etc.)"
    echo ""

    echo -e "${YELLOW}2. Commit the Configuration:${NC}"
    echo "   git add .claude .github docs tools .gitignore .mcp.json.template"
    echo "   git commit -m \"chore: add development workflow configuration\""
    echo ""

    echo -e "${YELLOW}3. (Optional) Configure GitHub Actions:${NC}"
    echo "   If using the CI workflows, add secrets to YOUR repository:"
    echo "   Repository Settings → Secrets → Actions"
    echo "   See: .github/workflows/ for which secrets each workflow needs"
    echo ""

    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}Installation Complete!${NC}"
    echo ""
    echo -e "${YELLOW}SECURITY NOTE:${NC} This installer does NOT collect any data."
    echo "All configuration is local to your repository."
    echo ""
    echo -e "Documentation: ${BLUE}https://github.com/bigdegenenergy/ai-dev-toolkit${NC}"
    echo -e "${YELLOW}Community project - works with any AI assistant or standalone${NC}"
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
    install_mcp_template
    install_docs
    install_tools
    install_github_workflows
    install_git_hooks
    install_language_profile
    update_gitignore
    print_summary
}

main "$@"
