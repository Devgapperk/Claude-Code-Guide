#!/usr/bin/env bash
#
# orchestrate.sh - Spawn parallel Claude Code agents via git worktrees
#
# Usage:
#   ./scripts/orchestrate.sh           # Spawn agents for all pending tasks
#   ./scripts/orchestrate.sh --clean   # Remove all worktrees
#   ./scripts/orchestrate.sh --status  # Show current worktree status
#
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get repository root
ROOT_DIR="$(git rev-parse --show-toplevel)"
WORKTREES_DIR="${ROOT_DIR}/../worktrees"
TASKS_FILE="${ROOT_DIR}/tasks.md"
CLAUDE_FILE="${ROOT_DIR}/CLAUDE.md"

print_banner() {
    echo -e "${MAGENTA}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║         CLAUDE CODE ORCHESTRATION                        ║"
    echo "║         Parallel Agent Fleet Manager                     ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    echo -e "${BLUE}[STATUS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show current worktree status
show_status() {
    print_banner
    echo -e "${BLUE}Current Worktrees:${NC}"
    echo ""
    git worktree list
    echo ""

    if [[ -d "${WORKTREES_DIR}" ]]; then
        echo -e "${BLUE}Agent Directories:${NC}"
        for dir in "${WORKTREES_DIR}"/agent-*; do
            if [[ -d "$dir" ]]; then
                agent_name=$(basename "$dir")
                branch=$(cd "$dir" && git branch --show-current 2>/dev/null || echo "unknown")
                if [[ -f "$dir/AGENT_NOTES.md" ]] && [[ -s "$dir/AGENT_NOTES.md" ]]; then
                    status="${GREEN}[NOTES]${NC}"
                else
                    status="${YELLOW}[WORKING]${NC}"
                fi
                echo -e "  ${status} ${agent_name} → ${branch}"
            fi
        done
    else
        print_warning "No worktrees directory found. Run without --status to create agents."
    fi
}

# Clean up all worktrees
clean_worktrees() {
    print_banner
    print_warning "This will remove ALL agent worktrees!"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove each worktree
        for dir in "${WORKTREES_DIR}"/agent-*; do
            if [[ -d "$dir" ]]; then
                agent_name=$(basename "$dir")
                print_status "Removing ${agent_name}..."
                git worktree remove "$dir" --force 2>/dev/null || true
            fi
        done

        # Clean up any stale worktree references
        git worktree prune

        # Remove the worktrees directory if empty
        rmdir "${WORKTREES_DIR}" 2>/dev/null || true

        print_success "All worktrees cleaned up."
    else
        print_status "Aborted."
    fi
}

# Main orchestration logic
orchestrate() {
    print_banner

    # Validate requirements
    if [[ ! -f "${TASKS_FILE}" ]]; then
        print_error "tasks.md not found at ${TASKS_FILE}"
        exit 1
    fi

    if [[ ! -f "${CLAUDE_FILE}" ]]; then
        print_error "CLAUDE.md not found at ${CLAUDE_FILE}"
        exit 1
    fi

    # Create worktrees directory
    mkdir -p "${WORKTREES_DIR}"

    # Extract pending tasks (lines starting with "- [ ]")
    mapfile -t TASKS < <(grep "^- \[ \] " "${TASKS_FILE}" | sed 's/^- \[ \] //')

    if [[ ${#TASKS[@]} -eq 0 ]]; then
        print_warning "No pending tasks found in tasks.md"
        print_status "Add tasks with: - [ ] Task description"
        exit 0
    fi

    print_status "Found ${#TASKS[@]} pending tasks"
    echo ""

    # Create worktree for each task
    idx=1
    for task in "${TASKS[@]}"; do
        branch_name="feature/agent-${idx}"
        worktree_path="${WORKTREES_DIR}/agent-${idx}"

        # Skip if worktree already exists
        if [[ -d "${worktree_path}" ]]; then
            print_warning "Worktree agent-${idx} already exists, skipping..."
            idx=$((idx + 1))
            continue
        fi

        print_status "Creating agent-${idx}: ${task:0:50}..."

        # Create worktree with new branch
        git worktree add "${worktree_path}" -b "${branch_name}" 2>/dev/null || {
            # Branch might exist, try checking it out
            git worktree add "${worktree_path}" "${branch_name}" 2>/dev/null || {
                print_error "Failed to create worktree for agent-${idx}"
                idx=$((idx + 1))
                continue
            }
        }

        # Copy CLAUDE.md to worktree
        cp "${CLAUDE_FILE}" "${worktree_path}/CLAUDE.md"

        # Create task-specific instruction file
        cat > "${worktree_path}/TASK.md" << EOF
# Assigned Task

${task}

## Instructions

1. Read CLAUDE.md for architecture standards and conventions
2. Implement ONLY this task—stay within scope
3. Write tests for any logic you create
4. Document your work in AGENT_NOTES.md
5. Run tests before signaling completion

## Context

- You are Agent ${idx} of ${#TASKS[@]}
- Your branch: ${branch_name}
- Other agents are working in parallel on different tasks
- Do NOT modify shared config files unless explicitly required

## Completion Checklist

- [ ] Implementation complete
- [ ] Tests written and passing
- [ ] AGENT_NOTES.md updated
- [ ] No unrelated changes included
EOF

        # Create empty AGENT_NOTES.md
        cat > "${worktree_path}/AGENT_NOTES.md" << EOF
# Agent ${idx} Notes

## Task
${task}

## What I Built
[Describe your implementation]

## Key Decisions
- [Why you chose approach X over Y]

## Files Changed
- [List modified files]

## Dependencies Added
- [Any new packages]

## Open Questions
- [Anything the orchestrator should review]

## Status
- [ ] Implementation complete
- [ ] Tests passing
- [ ] Ready for review
EOF

        print_success "Created agent-${idx} → ${worktree_path}"
        idx=$((idx + 1))
    done

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  All agents spawned successfully!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Open a new terminal for each agent directory"
    echo "  2. cd into each worktree: cd ${WORKTREES_DIR}/agent-N"
    echo "  3. Start Claude Code: claude"
    echo "  4. Tab-switch between sessions to review progress"
    echo ""
    echo -e "${BLUE}Worktree locations:${NC}"
    for dir in "${WORKTREES_DIR}"/agent-*; do
        if [[ -d "$dir" ]]; then
            echo "  → $dir"
        fi
    done
    echo ""
    echo -e "${YELLOW}Tip:${NC} Run './scripts/merge-helper.sh' when agents complete their tasks"
}

# Parse arguments
case "${1:-}" in
    --clean)
        clean_worktrees
        ;;
    --status)
        show_status
        ;;
    --help|-h)
        echo "Usage: $0 [--clean|--status|--help]"
        echo ""
        echo "Options:"
        echo "  (none)    Spawn agents for all pending tasks in tasks.md"
        echo "  --clean   Remove all agent worktrees"
        echo "  --status  Show current worktree status"
        echo "  --help    Show this help message"
        ;;
    *)
        orchestrate
        ;;
esac
