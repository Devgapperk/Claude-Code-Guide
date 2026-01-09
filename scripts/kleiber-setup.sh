#!/usr/bin/env bash
#
# kleiber-setup.sh - Initialize the Kleiber Orchestration System
#
# Named after conductor Erich Kleiber: one orchestrator, many virtuosos.
#
# Usage:
#   ./scripts/kleiber-setup.sh [project-name]
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

PROJECT_NAME="${1:-kleiber-orchestra}"

print_banner() {
    echo -e "${MAGENTA}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   🎼  KLEIBER ORCHESTRATION SYSTEM                           ║
    ║                                                               ║
    ║   "One conductor, many virtuosos, flawless coordination"     ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Start setup
print_banner

log_step "Initializing Kleiber Orchestra: ${PROJECT_NAME}"

# Check if we're in an existing git repo or need to create one
if git rev-parse --git-dir > /dev/null 2>&1; then
    log_info "Already in a git repository"
    ROOT_DIR=$(git rev-parse --show-toplevel)
else
    log_step "Creating new git repository"
    mkdir -p "${PROJECT_NAME}"
    cd "${PROJECT_NAME}"
    git init
    ROOT_DIR=$(pwd)
fi

cd "${ROOT_DIR}"

# Create directory structure
log_step "Creating orchestration directories..."

directories=(
    "tasks/architect"
    "tasks/engineer-frontend"
    "tasks/engineer-backend"
    "tasks/validator"
    "tasks/scribe"
    "progress/architect"
    "progress/engineer-frontend"
    "progress/engineer-backend"
    "progress/validator"
    "progress/scribe"
    "complete"
    "blocked"
    "schemas"
    "agents"
    "reports"
    "docs/architecture"
    "docs/decisions"
)

for dir in "${directories[@]}"; do
    mkdir -p "${dir}"
    log_success "Created ${dir}/"
done

# Create .gitkeep files to preserve empty directories
find . -type d -empty -not -path "./.git/*" -exec touch {}/.gitkeep \;

# Create orchestration log
log_step "Creating orchestration log..."
cat > orchestration_log.md << 'EOF'
# Orchestration Log

Track all agent sessions, model usage, and costs.

| Timestamp | Agent | Task | Model | Input Tokens | Output Tokens | Cost |
|-----------|-------|------|-------|--------------|---------------|------|

## Daily Summaries

<!-- Add daily summaries here -->
EOF
log_success "Created orchestration_log.md"

# Create PROGRESS.md
log_step "Creating progress tracker..."
cat > PROGRESS.md << 'EOF'
# Orchestration Progress

## Current Sprint

### In Progress
<!-- Tasks currently being worked on -->

### Completed Today
<!-- Tasks completed in current session -->

### Blocked
<!-- Tasks waiting on resolution -->

## Session History

<!-- Scribe agent maintains this section -->
EOF
log_success "Created PROGRESS.md"

# Create tasks.md with Kleiber-specific tasks
log_step "Creating task backlog..."
cat > tasks.md << 'EOF'
# Kleiber Orchestration Tasks

> Each unchecked task spawns one agent in its own git worktree.
> Run `./scripts/spawn-agents.sh` after defining tasks.

## Infrastructure Setup

- [ ] ARCHITECT: Design system architecture and module boundaries
- [ ] ENGINEER-BACKEND: Set up Express server with TypeScript
- [ ] ENGINEER-BACKEND: Configure PostgreSQL with Drizzle ORM
- [ ] ENGINEER-FRONTEND: Initialize React app with Tailwind
- [ ] VALIDATOR: Set up test infrastructure (Vitest, Testing Library)
- [ ] SCRIBE: Create initial documentation structure

## Core Features

<!-- Add feature tasks here -->

## Task Status Legend

- `[ ]` = Pending (will spawn agent)
- `[~]` = In Progress (agent working)
- `[x]` = Completed (merged to main)
- `[-]` = Discarded (abandoned)
- `[!]` = Blocked (needs resolution)
EOF
log_success "Created tasks.md"

# Check if CLAUDE.md exists (we may have already created it)
if [[ ! -f "CLAUDE.md" ]]; then
    log_step "Creating CLAUDE.md blueprint..."
    echo "# KLEIBER ORCHESTRATION BLUEPRINT" > CLAUDE.md
    echo "" >> CLAUDE.md
    echo "See the full template in the repository." >> CLAUDE.md
    log_success "Created CLAUDE.md (placeholder - replace with full template)"
else
    log_info "CLAUDE.md already exists"
fi

# Create example idea snack
log_step "Creating example idea snack..."
cat > schemas/example_idea.json << 'EOF'
{
  "meta": {
    "idea_id": "idea-abc12345",
    "timestamp": "2025-01-09T14:30:00Z",
    "source": "voice_note",
    "author": "founder",
    "energy_level": "high",
    "confidence": 0.85
  },
  "signal": {
    "one_line_hook": "AI that turns messy founder brain dumps into actionable specs",
    "category": "product",
    "domain": "productivity",
    "urgency": "this_week",
    "strategic_fit": "core"
  },
  "problem": {
    "user_segment": "Solo founders and small teams",
    "core_pain": "Ideas get lost between capture and execution",
    "current_workaround": "Notion docs that never get read",
    "job_to_be_done": "Turn chaotic thoughts into structured action items"
  },
  "solution": {
    "concept": "Voice-first idea capture with AI parsing and routing",
    "mode": "agent_fleet",
    "key_capabilities": [
      "Voice transcription",
      "Structured extraction",
      "Automatic routing to appropriate agent"
    ],
    "success_criteria": [
      "Idea to actionable spec in < 5 minutes",
      "90% extraction accuracy"
    ]
  },
  "constraints": {
    "timeline": "1_week",
    "budget_band": "lean",
    "risk_tolerance": "medium",
    "compliance": []
  },
  "architecture_hint": {
    "orchestration_pattern": "small_ensemble",
    "required_integrations": ["whisper", "claude"],
    "preferred_stack": ["typescript", "react", "express"]
  },
  "impact_model": {
    "value_lens": "focus_restoration",
    "north_star_metric": "Ideas shipped per week",
    "leading_indicators": ["Ideas captured", "Specs generated"],
    "lagging_indicators": ["Features deployed"]
  },
  "execution": {
    "stage": "parsed",
    "owner": "orchestrator",
    "next_step": "Route to PRD writer",
    "dependencies": []
  },
  "notes": {
    "raw_dump": "okay so I keep having these ideas in the shower and by the time I get to my laptop they're gone or I write them down but they're just gibberish later...",
    "quotes": [
      "by the time I get to my laptop they're gone",
      "just gibberish later"
    ],
    "mood": "frustrated"
  }
}
EOF
log_success "Created schemas/example_idea.json"

# Stage and commit if this is a new repo
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
    log_step "Staging files for commit..."
    git add .

    if [[ $(git log --oneline 2>/dev/null | wc -l) -eq 0 ]]; then
        log_step "Creating initial commit..."
        git commit -m "feat: Initialize Kleiber orchestration system

- CLAUDE.md: Orchestration blueprint with model routing
- tasks.md: Parallel task backlog
- schemas/: Idea snack JSON schema
- Directory structure for agent communication
- orchestration_log.md for cost tracking

🤖 Generated with Claude Code"
        log_success "Initial commit created"
    fi
fi

# Print summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Kleiber Orchestra initialized successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Directory structure:${NC}"
echo "  tasks/          - Agent task assignments"
echo "  progress/       - Work-in-progress tracking"
echo "  complete/       - Completed task records"
echo "  blocked/        - Blocked task reports"
echo "  schemas/        - JSON schemas (idea_snack, etc.)"
echo "  agents/         - Agent prompts and configs"
echo "  reports/        - Validator outputs"
echo "  docs/           - Architecture and decisions"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review and customize CLAUDE.md"
echo "  2. Add tasks to tasks.md"
echo "  3. Run: ./scripts/spawn-agents.sh"
echo "  4. Open each worktree in Claude Code"
echo "  5. Orchestrate!"
echo ""
echo -e "${YELLOW}Tip:${NC} Run './scripts/conductor.sh status' to see orchestra state"
