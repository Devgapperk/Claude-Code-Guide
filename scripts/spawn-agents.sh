#!/usr/bin/env bash
#
# spawn-agents.sh - Create git worktrees for each Kleiber agent
#
# Each agent gets its own worktree (isolated working directory)
# sharing the same git history but with independent branches.
#
# Usage:
#   ./scripts/spawn-agents.sh              # Spawn default agents
#   ./scripts/spawn-agents.sh --custom     # Interactive agent selection
#   ./scripts/spawn-agents.sh --clean      # Remove all agent worktrees
#
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
ROOT_DIR="$(git rev-parse --show-toplevel)"
WORKTREES_DIR="${ROOT_DIR}/../worktrees"
CLAUDE_FILE="${ROOT_DIR}/CLAUDE.md"

# Default agent roster
DEFAULT_AGENTS=(
    "architect:opus:Reviews designs and approves architecture"
    "engineer-frontend:sonnet:React, Tailwind, UI components"
    "engineer-backend:sonnet:Express, PostgreSQL, business logic"
    "validator:haiku:Runs tests, checks types, reports status"
    "scribe:haiku:Maintains docs, progress, changelog"
)

print_banner() {
    echo -e "${MAGENTA}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   🎻  KLEIBER AGENT SPAWNER                                  ║
    ║                                                               ║
    ║   Creating virtuoso worktrees for parallel orchestration     ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log_step() {
    echo -e "${CYAN}[SPAWN]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Clean up all agent worktrees
clean_agents() {
    print_banner
    echo -e "${YELLOW}This will remove ALL agent worktrees!${NC}"
    echo ""

    # List current worktrees
    echo -e "${BLUE}Current worktrees:${NC}"
    git worktree list
    echo ""

    read -p "Are you sure? (y/N) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Find and remove agent worktrees
        for dir in "${WORKTREES_DIR}"/*; do
            if [[ -d "$dir" ]]; then
                agent_name=$(basename "$dir")
                log_step "Removing ${agent_name}..."
                git worktree remove "$dir" --force 2>/dev/null || true
            fi
        done

        # Prune stale worktree references
        git worktree prune

        # Remove worktrees directory if empty
        rmdir "${WORKTREES_DIR}" 2>/dev/null || true

        log_success "All agent worktrees cleaned up"
    else
        log_warning "Aborted"
    fi
}

# Create a single agent worktree
spawn_agent() {
    local agent_name=$1
    local model=$2
    local description=$3

    local branch_name="agent/${agent_name}"
    local worktree_path="${WORKTREES_DIR}/${agent_name}"

    # Skip if already exists
    if [[ -d "${worktree_path}" ]]; then
        log_warning "Agent ${agent_name} already exists, skipping..."
        return 0
    fi

    log_step "Spawning ${agent_name} (${model})..."

    # Create worktree with new branch
    if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
        # Branch exists, check it out
        git worktree add "${worktree_path}" "${branch_name}" 2>/dev/null || {
            log_error "Failed to create worktree for ${agent_name}"
            return 1
        }
    else
        # Create new branch
        git worktree add "${worktree_path}" -b "${branch_name}" 2>/dev/null || {
            log_error "Failed to create worktree for ${agent_name}"
            return 1
        }
    fi

    # Copy CLAUDE.md to worktree
    if [[ -f "${CLAUDE_FILE}" ]]; then
        cp "${CLAUDE_FILE}" "${worktree_path}/CLAUDE.md"
    fi

    # Create agent-specific README
    cat > "${worktree_path}/AGENT_README.md" << EOF
# Agent: ${agent_name}

**Model**: ${model}
**Role**: ${description}

## Your Workspace

This is your isolated working directory. You have your own branch (\`${branch_name}\`)
and can make changes without affecting other agents.

## Protocol

1. Check \`/tasks/${agent_name}/\` for assigned tasks
2. Create progress file when starting: \`/progress/${agent_name}/{task-id}-started.md\`
3. Work within your designated directories (see CLAUDE.md)
4. Signal completion: \`/complete/${agent_name}/{task-id}-done.md\`
5. Report blockers: \`/blocked/${agent_name}/{task-id}-conflict.md\`

## Files to Read

- \`CLAUDE.md\` - Orchestration blueprint and your role definition
- \`tasks/${agent_name}/*.md\` - Your assigned tasks

## Remember

- Stay within your scope
- Document decisions in completion files
- Run tests before signaling done
- Don't modify files outside your domain
EOF

    # Create my-work directory for agent's scratch space
    mkdir -p "${worktree_path}/my-work"
    echo "# ${agent_name} scratch space" > "${worktree_path}/my-work/README.md"

    log_success "Created ${agent_name} → ${worktree_path}"
}

# Spawn all default agents
spawn_all_agents() {
    print_banner

    log_step "Creating worktrees directory..."
    mkdir -p "${WORKTREES_DIR}"

    echo ""
    echo -e "${BLUE}Spawning agent fleet:${NC}"
    echo ""

    for agent_spec in "${DEFAULT_AGENTS[@]}"; do
        IFS=':' read -r name model desc <<< "$agent_spec"
        spawn_agent "$name" "$model" "$desc"
    done

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Agent fleet spawned successfully!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Agent worktrees:${NC}"
    for dir in "${WORKTREES_DIR}"/*; do
        if [[ -d "$dir" ]]; then
            agent_name=$(basename "$dir")
            branch=$(cd "$dir" && git branch --show-current 2>/dev/null || echo "unknown")
            echo "  🎻 ${agent_name} → ${branch}"
        fi
    done
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Open a terminal for each agent"
    echo "  2. cd into the worktree: cd ${WORKTREES_DIR}/{agent-name}"
    echo "  3. Start Claude Code: claude"
    echo "  4. Provide context: 'Read CLAUDE.md and AGENT_README.md'"
    echo ""
    echo -e "${YELLOW}Tip:${NC} Use './scripts/conductor.sh assign {agent} {task-id} \"description\"' to assign work"
}

# Show usage
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  (none)    Spawn all default agents (architect, frontend, backend, validator, scribe)"
    echo "  --clean   Remove all agent worktrees"
    echo "  --help    Show this help message"
    echo ""
    echo "Default agents:"
    for agent_spec in "${DEFAULT_AGENTS[@]}"; do
        IFS=':' read -r name model desc <<< "$agent_spec"
        echo "  ${name} (${model}): ${desc}"
    done
}

# Parse arguments
case "${1:-}" in
    --clean)
        clean_agents
        ;;
    --help|-h)
        show_help
        ;;
    *)
        spawn_all_agents
        ;;
esac
