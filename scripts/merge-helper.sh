#!/usr/bin/env bash
#
# merge-helper.sh - Review and merge completed agent branches
#
# Usage:
#   ./scripts/merge-helper.sh              # Interactive review of all agents
#   ./scripts/merge-helper.sh --list       # List all agent branches with status
#   ./scripts/merge-helper.sh --test-all   # Run tests on all agent branches
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

ROOT_DIR="$(git rev-parse --show-toplevel)"
WORKTREES_DIR="${ROOT_DIR}/../worktrees"

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║         MERGE HELPER                                     ║"
    echo "║         Review & Merge Agent Branches                    ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# List all agent branches with their status
list_agents() {
    print_banner
    echo -e "${BLUE}Agent Branches:${NC}"
    echo ""

    for dir in "${WORKTREES_DIR}"/agent-*; do
        if [[ -d "$dir" ]]; then
            agent_name=$(basename "$dir")
            branch=$(cd "$dir" && git branch --show-current 2>/dev/null || echo "unknown")

            # Check if AGENT_NOTES.md has content
            if [[ -f "$dir/AGENT_NOTES.md" ]]; then
                notes_lines=$(wc -l < "$dir/AGENT_NOTES.md" | tr -d ' ')
                if [[ $notes_lines -gt 20 ]]; then
                    notes_status="${GREEN}[DOCUMENTED]${NC}"
                else
                    notes_status="${YELLOW}[MINIMAL]${NC}"
                fi
            else
                notes_status="${RED}[NO NOTES]${NC}"
            fi

            # Check for uncommitted changes
            changes=$(cd "$dir" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [[ $changes -gt 0 ]]; then
                change_status="${YELLOW}[${changes} uncommitted]${NC}"
            else
                change_status="${GREEN}[clean]${NC}"
            fi

            # Get commit count ahead of main
            ahead=$(cd "$dir" && git rev-list --count main..HEAD 2>/dev/null || echo "?")

            echo -e "  ${MAGENTA}${agent_name}${NC}"
            echo -e "    Branch: ${branch}"
            echo -e "    Commits ahead: ${ahead}"
            echo -e "    Notes: ${notes_status}  Changes: ${change_status}"
            echo ""
        fi
    done
}

# Run tests on all agent branches
test_all() {
    print_banner
    echo -e "${BLUE}Running tests on all agent branches...${NC}"
    echo ""

    results=()

    for dir in "${WORKTREES_DIR}"/agent-*; do
        if [[ -d "$dir" ]]; then
            agent_name=$(basename "$dir")
            echo -e "${YELLOW}Testing ${agent_name}...${NC}"

            # Try to run tests
            if [[ -f "$dir/package.json" ]]; then
                if (cd "$dir" && npm test 2>/dev/null); then
                    results+=("${GREEN}PASS${NC}: ${agent_name}")
                else
                    results+=("${RED}FAIL${NC}: ${agent_name}")
                fi
            else
                results+=("${YELLOW}SKIP${NC}: ${agent_name} (no package.json)")
            fi
        fi
    done

    echo ""
    echo -e "${BLUE}Test Results:${NC}"
    for result in "${results[@]}"; do
        echo -e "  $result"
    done
}

# Interactive review of an agent
review_agent() {
    local dir=$1
    local agent_name=$(basename "$dir")
    local branch=$(cd "$dir" && git branch --show-current)

    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  Reviewing: ${agent_name}${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"

    # Show task
    if [[ -f "$dir/TASK.md" ]]; then
        echo ""
        echo -e "${BLUE}Task:${NC}"
        head -10 "$dir/TASK.md" | tail -8
    fi

    # Show agent notes
    if [[ -f "$dir/AGENT_NOTES.md" ]]; then
        echo ""
        echo -e "${BLUE}Agent Notes:${NC}"
        cat "$dir/AGENT_NOTES.md"
    fi

    # Show diff summary
    echo ""
    echo -e "${BLUE}Changes (summary):${NC}"
    (cd "$dir" && git diff --stat main...HEAD 2>/dev/null) || echo "  (no changes from main)"

    # Show full diff option
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  [d] Show full diff"
    echo "  [m] Merge to main"
    echo "  [r] Rebase on main first, then merge"
    echo "  [x] Discard this branch"
    echo "  [s] Skip (review later)"
    echo "  [q] Quit review"
    echo ""

    read -p "Choice: " -n 1 -r choice
    echo ""

    case $choice in
        d)
            echo ""
            (cd "$dir" && git diff main...HEAD)
            read -p "Press Enter to continue..." -r
            review_agent "$dir"
            ;;
        m)
            echo -e "${BLUE}Merging ${branch} to main...${NC}"
            git checkout main
            git merge "$branch" --no-ff -m "Merge ${branch}: $(head -1 "$dir/TASK.md" | sed 's/# //')"
            echo -e "${GREEN}Merged successfully!${NC}"
            ;;
        r)
            echo -e "${BLUE}Rebasing ${branch} on main...${NC}"
            (cd "$dir" && git fetch origin main && git rebase origin/main)
            echo -e "${BLUE}Now merging...${NC}"
            git checkout main
            git merge "$branch" --no-ff -m "Merge ${branch}: $(head -1 "$dir/TASK.md" | sed 's/# //')"
            echo -e "${GREEN}Rebased and merged!${NC}"
            ;;
        x)
            read -p "Really discard ${agent_name}? (y/N) " -n 1 -r confirm
            echo ""
            if [[ $confirm =~ ^[Yy]$ ]]; then
                git worktree remove "$dir" --force
                git branch -D "$branch" 2>/dev/null || true
                echo -e "${YELLOW}Branch discarded.${NC}"
            fi
            ;;
        s)
            echo -e "${BLUE}Skipping...${NC}"
            ;;
        q)
            echo -e "${BLUE}Exiting review.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            review_agent "$dir"
            ;;
    esac
}

# Interactive review of all agents
interactive_review() {
    print_banner

    if [[ ! -d "${WORKTREES_DIR}" ]]; then
        echo -e "${YELLOW}No worktrees directory found.${NC}"
        echo "Run ./scripts/orchestrate.sh first to spawn agents."
        exit 0
    fi

    agent_count=0
    for dir in "${WORKTREES_DIR}"/agent-*; do
        if [[ -d "$dir" ]]; then
            agent_count=$((agent_count + 1))
        fi
    done

    if [[ $agent_count -eq 0 ]]; then
        echo -e "${YELLOW}No agent worktrees found.${NC}"
        exit 0
    fi

    echo -e "${BLUE}Found ${agent_count} agent(s) to review.${NC}"
    echo ""

    for dir in "${WORKTREES_DIR}"/agent-*; do
        if [[ -d "$dir" ]]; then
            review_agent "$dir"
        fi
    done

    echo ""
    echo -e "${GREEN}Review complete!${NC}"
}

# Generate PR summaries for all agents
generate_pr_summaries() {
    print_banner
    echo -e "${BLUE}Generating PR summaries...${NC}"
    echo ""

    for dir in "${WORKTREES_DIR}"/agent-*; do
        if [[ -d "$dir" ]]; then
            agent_name=$(basename "$dir")
            branch=$(cd "$dir" && git branch --show-current)

            echo -e "${MAGENTA}## ${agent_name} (${branch})${NC}"
            echo ""

            # Get task
            if [[ -f "$dir/TASK.md" ]]; then
                echo "### Task"
                grep "^[^#]" "$dir/TASK.md" | head -3
                echo ""
            fi

            # Get summary from notes
            if [[ -f "$dir/AGENT_NOTES.md" ]]; then
                echo "### Summary"
                sed -n '/## What I Built/,/## Key Decisions/p' "$dir/AGENT_NOTES.md" | head -10
                echo ""
            fi

            # Files changed
            echo "### Files Changed"
            (cd "$dir" && git diff --name-only main...HEAD 2>/dev/null) || echo "(none)"
            echo ""
            echo "---"
            echo ""
        fi
    done
}

# Parse arguments
case "${1:-}" in
    --list)
        list_agents
        ;;
    --test-all)
        test_all
        ;;
    --pr-summaries)
        generate_pr_summaries
        ;;
    --help|-h)
        echo "Usage: $0 [--list|--test-all|--pr-summaries|--help]"
        echo ""
        echo "Options:"
        echo "  (none)         Interactive review of all agents"
        echo "  --list         List all agent branches with status"
        echo "  --test-all     Run tests on all agent branches"
        echo "  --pr-summaries Generate PR summaries for documentation"
        echo "  --help         Show this help message"
        ;;
    *)
        interactive_review
        ;;
esac
