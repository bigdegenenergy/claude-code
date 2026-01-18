#!/bin/bash

# ==============================================================================
# Claude Code Team Setup Script
# Source: https://github.com/bigdegenenergy/ai-dev-toolkit
# Description: Hydrates a target repository with the Claude Code & GitHub DNA.
# ==============================================================================

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SOURCE_REPO="https://github.com/bigdegenenergy/ai-dev-toolkit.git"
TEMP_DIR=$(mktemp -d)

echo -e "${BLUE}🤖 Claude Code Team Setup Initiated...${NC}"

# 1. Prerequisites Check
# ------------------------------------------------------------------------------
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed.${NC}"
    exit 1
fi

# Ensure we are inside a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo -e "${RED}Error: You must run this script inside a git repository.${NC}"
    exit 1
fi

# Move to the root of the repo to ensure paths are correct
GIT_ROOT=$(git rev-parse --show-toplevel)
cd "$GIT_ROOT"
echo -e "${BLUE}📍 Target Repository Root: ${GIT_ROOT}${NC}"

# 2. Clone Source DNA
# ------------------------------------------------------------------------------
echo -e "${BLUE}📥 Downloading configuration DNA from source...${NC}"
git clone --quiet --depth 1 "$SOURCE_REPO" "$TEMP_DIR"

# 3. Install .claude (The Brain)
# ------------------------------------------------------------------------------
echo -e "${GREEN}🧠 Installing Claude Code configuration (.claude)...${NC}"
if [ -d ".claude" ]; then
    echo -e "${YELLOW}   Note: Merging with existing .claude directory...${NC}"
fi
cp -R "$TEMP_DIR/.claude" .

# Handle CLAUDE.md specifically (Project Context)
if [ -f "CLAUDE.md" ]; then
    echo -e "${YELLOW}   Note: CLAUDE.md exists. Creating CLAUDE.md.new to avoid overwrite.${NC}"
    cp "$TEMP_DIR/CLAUDE.md" "CLAUDE.md.new"
else
    cp "$TEMP_DIR/CLAUDE.md" .
fi

# 4. Install .github (The Nervous System)
# ------------------------------------------------------------------------------
echo -e "${GREEN}⚡ Installing CI/CD workflows (.github)...${NC}"
mkdir -p .github
cp -R "$TEMP_DIR/.github" .

# 5. Configuration & Security
# ------------------------------------------------------------------------------
echo -e "${GREEN}🔒 Configuring permissions and security...${NC}"

# Make hooks executable
if [ -d ".claude/hooks" ]; then
    chmod +x .claude/hooks/*.sh 2>/dev/null || true
    chmod +x .claude/hooks/*.py 2>/dev/null || true
    echo -e "   ✓ Hooks made executable"
fi

# Handle notifications.json (Do not overwrite credentials)
if [ -f ".claude/notifications.json" ]; then
    echo -e "${YELLOW}   ✓ notifications.json already exists. Skipping template copy.${NC}"
else
    if [ -f ".claude/notifications.json.template" ]; then
        cp .claude/notifications.json.template .claude/notifications.json
        echo -e "   ✓ Created notifications.json from template"
    fi
fi

# Update .gitignore
if ! grep -q ".claude/notifications.json" .gitignore 2>/dev/null; then
    echo ".claude/notifications.json" >> .gitignore
    echo -e "   ✓ Added .claude/notifications.json to .gitignore"
fi

# 6. Cleanup
# ------------------------------------------------------------------------------
rm -rf "$TEMP_DIR"

# 7. Final Instructions
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}✅ Setup Complete!${NC}"
echo -e "------------------------------------------------------------------"
echo -e "${BLUE}NEXT STEPS:${NC}"
echo -e "1. ${YELLOW}Configure Notifications:${NC}"
echo -e "   Edit .claude/notifications.json with your local webhook URLs."
echo -e "   (This file is git-ignored and safe to edit)."
echo -e ""
echo -e "2. ${YELLOW}Configure GitHub Secrets:${NC}"
echo -e "   Go to Repo Settings -> Secrets -> Actions and add:"
echo -e "   - GH_TOKEN (Classic PAT with 'repo' scope) - REQUIRED"
echo -e "   - SLACK_WEBHOOK_URL (if using Slack)"
echo -e "   - DISCORD_WEBHOOK_URL (if using Discord)"
echo -e ""
echo -e "3. ${YELLOW}Commit Changes:${NC}"
echo -e "   git add .claude .github CLAUDE.md .gitignore"
echo -e "   git commit -m \"chore: install claude-code professional team DNA\""
echo -e "------------------------------------------------------------------"
