#!/usr/bin/env bash
#
# conductor.sh - Kleiber Orchestra Task Management
#
# The conductor assigns tasks, monitors progress, and resolves conflicts.
#
# Usage:
#   ./scripts/conductor.sh assign <agent> <task-id> "<description>"
#   ./scripts/conductor.sh status
#   ./scripts/conductor.sh watch
#   ./scripts/conductor.sh review <agent>
#   ./scripts/conductor.sh unblock <agent> <task-id>
#   ./scripts/conductor.sh log <agent> <task-id> <model> <input-tokens> <output-tokens>
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

ROOT_DIR="$(git rev-parse --show-toplevel)"
WORKTREES_DIR="${ROOT_DIR}/../worktrees"

# Agent roles and their default models
declare -A AGENT_MODELS=(
    ["architect"]="opus"
    ["engineer-frontend"]="sonnet"
    ["engineer-backend"]="sonnet"
    ["validator"]="haiku"
    ["scribe"]="haiku"
)

# Model costs per 1M tokens
declare -A MODEL_INPUT_COSTS=(
    ["opus"]="15.00"
    ["sonnet"]="3.00"
    ["haiku"]="0.25"
)

declare -A MODEL_OUTPUT_COSTS=(
    ["opus"]="75.00"
    ["sonnet"]="15.00"
    ["haiku"]="1.25"
)

print_banner() {
    echo -e "${MAGENTA}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║   🎼  KLEIBER CONDUCTOR                                       ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Assign a task to an agent
cmd_assign() {
    local agent=$1
    local task_id=$2
    local description=$3
    local model="${AGENT_MODELS[$agent]:-sonnet}"
    local priority="${4:-p1}"

    if [[ -z "$agent" || -z "$task_id" || -z "$description" ]]; then
        echo "Usage: conductor.sh assign <agent> <task-id> \"<description>\" [priority]"
        echo ""
        echo "Agents: architect, engineer-frontend, engineer-backend, validator, scribe"
        echo "Priority: p0 (critical), p1 (high), p2 (normal), p3 (low)"
        exit 1
    fi

    mkdir -p "${ROOT_DIR}/tasks/${agent}"

    cat > "${ROOT_DIR}/tasks/${agent}/${task_id}.md" << EOF
# Task: ${task_id}

**Agent**: ${agent}
**Model**: ${model}
**Priority**: ${priority}
**Created**: $(date -Iseconds)
**Status**: assigned

## Description

${description}

## Acceptance Criteria

- [ ] Implementation complete
- [ ] Tests written and passing
- [ ] Documentation updated

## Context

<!-- Add relevant context here -->

## Constraints

<!-- Add any constraints here -->

---

*Assigned by Conductor at $(date)*
EOF

    echo -e "${GREEN}[✓]${NC} Task ${CYAN}${task_id}${NC} assigned to ${MAGENTA}${agent}${NC} (${model})"
    echo "    📋 ${ROOT_DIR}/tasks/${agent}/${task_id}.md"
}

# Show orchestra status
cmd_status() {
    print_banner

    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  ORCHESTRA STATUS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Count tasks by state
    local assigned=$(find "${ROOT_DIR}/tasks" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    local in_progress=$(find "${ROOT_DIR}/progress" -name "*-started.md" 2>/dev/null | wc -l | tr -d ' ')
    local completed=$(find "${ROOT_DIR}/complete" -name "*-done.md" 2>/dev/null | wc -l | tr -d ' ')
    local blocked=$(find "${ROOT_DIR}/blocked" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

    echo -e "  ${YELLOW}📋 Assigned:${NC}     ${assigned}"
    echo -e "  ${CYAN}🔄 In Progress:${NC}  ${in_progress}"
    echo -e "  ${GREEN}✅ Completed:${NC}    ${completed}"
    echo -e "  ${RED}🚫 Blocked:${NC}      ${blocked}"
    echo ""

    # Show agents
    echo -e "${BLUE}AGENTS:${NC}"
    echo ""

    for agent in architect engineer-frontend engineer-backend validator scribe; do
        local model="${AGENT_MODELS[$agent]}"
        local worktree="${WORKTREES_DIR}/${agent}"
        local agent_tasks=$(find "${ROOT_DIR}/tasks/${agent}" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
        local agent_progress=$(find "${ROOT_DIR}/progress/${agent}" -name "*-started.md" 2>/dev/null | wc -l | tr -d ' ')

        if [[ -d "$worktree" ]]; then
            local status="${GREEN}[ACTIVE]${NC}"
            local branch=$(cd "$worktree" && git branch --show-current 2>/dev/null || echo "?")
        else
            local status="${YELLOW}[NOT SPAWNED]${NC}"
            local branch="-"
        fi

        printf "  🎻 %-20s ${status} (%s) Tasks: %d/%d\n" \
            "${agent}" "${model}" "${agent_progress}" "${agent_tasks}"
    done

    echo ""

    # Show blocked tasks if any
    if [[ $blocked -gt 0 ]]; then
        echo -e "${RED}BLOCKED TASKS:${NC}"
        find "${ROOT_DIR}/blocked" -name "*.md" -exec basename {} \; 2>/dev/null | while read -r file; do
            echo "  ⚠️  ${file}"
        done
        echo ""
    fi

    # Show recent completions
    if [[ $completed -gt 0 ]]; then
        echo -e "${GREEN}RECENT COMPLETIONS:${NC}"
        find "${ROOT_DIR}/complete" -name "*-done.md" -mmin -60 2>/dev/null | head -5 | while read -r file; do
            echo "  ✅ $(basename "$file")"
        done
        echo ""
    fi
}

# Watch orchestra status (refreshes every 2 seconds)
cmd_watch() {
    watch -n 2 -c "$0 status"
}

# Review an agent's work
cmd_review() {
    local agent=$1

    if [[ -z "$agent" ]]; then
        echo "Usage: conductor.sh review <agent>"
        exit 1
    fi

    print_banner
    echo -e "${BLUE}Reviewing ${MAGENTA}${agent}${BLUE} work...${NC}"
    echo ""

    # Check for completed work
    local complete_files=$(find "${ROOT_DIR}/complete/${agent}" -name "*-done.md" 2>/dev/null)

    if [[ -z "$complete_files" ]]; then
        echo -e "${YELLOW}No completed tasks from ${agent}${NC}"
        return
    fi

    for file in $complete_files; do
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  $(basename "$file")${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        cat "$file"
        echo ""
        echo -e "${YELLOW}Options:${NC} [a]pprove  [r]eject  [s]kip  [q]uit"
        read -p "Choice: " -n 1 -r choice
        echo ""

        case $choice in
            a|A)
                echo -e "${GREEN}✓ Approved${NC}"
                # Could move to approved/ directory or update status
                ;;
            r|R)
                echo -e "${RED}✗ Rejected${NC}"
                read -p "Reason: " reason
                echo "Rejected: $reason" >> "$file"
                ;;
            q|Q)
                echo "Exiting review"
                return
                ;;
            *)
                echo "Skipping..."
                ;;
        esac
    done
}

# Unblock a task
cmd_unblock() {
    local agent=$1
    local task_id=$2

    if [[ -z "$agent" || -z "$task_id" ]]; then
        echo "Usage: conductor.sh unblock <agent> <task-id>"
        exit 1
    fi

    local blocked_file="${ROOT_DIR}/blocked/${agent}/${task_id}-conflict.md"

    if [[ ! -f "$blocked_file" ]]; then
        echo -e "${YELLOW}No blocked task found: ${task_id}${NC}"
        return
    fi

    echo -e "${BLUE}Unblocking ${task_id}...${NC}"
    echo ""
    cat "$blocked_file"
    echo ""

    read -p "Resolution notes: " resolution

    # Add resolution to the file
    cat >> "$blocked_file" << EOF

---

## Resolution

**Resolved by**: Conductor
**Resolved at**: $(date -Iseconds)

${resolution}
EOF

    # Move to progress to signal agent can continue
    mkdir -p "${ROOT_DIR}/progress/${agent}"
    mv "$blocked_file" "${ROOT_DIR}/progress/${agent}/${task_id}-unblocked.md"

    echo -e "${GREEN}✓ Task unblocked. Agent can continue.${NC}"
}

# Log a completed task to orchestration log
cmd_log() {
    local agent=$1
    local task_id=$2
    local model=$3
    local input_tokens=$4
    local output_tokens=$5

    if [[ -z "$agent" || -z "$task_id" || -z "$model" || -z "$input_tokens" || -z "$output_tokens" ]]; then
        echo "Usage: conductor.sh log <agent> <task-id> <model> <input-tokens> <output-tokens>"
        exit 1
    fi

    # Calculate cost
    local input_cost=$(echo "scale=4; ${input_tokens} * ${MODEL_INPUT_COSTS[$model]:-3.00} / 1000000" | bc)
    local output_cost=$(echo "scale=4; ${output_tokens} * ${MODEL_OUTPUT_COSTS[$model]:-15.00} / 1000000" | bc)
    local total_cost=$(echo "scale=4; ${input_cost} + ${output_cost}" | bc)

    local timestamp=$(date -Iseconds)
    local log_entry="| ${timestamp} | ${agent} | ${task_id} | ${model} | ${input_tokens} | ${output_tokens} | \$${total_cost} |"

    echo "$log_entry" >> "${ROOT_DIR}/orchestration_log.md"

    echo -e "${GREEN}✓ Logged${NC}: ${agent}/${task_id} (${model}) - \$${total_cost}"
}

# Daily cost summary
cmd_costs() {
    print_banner
    echo -e "${BLUE}COST SUMMARY${NC}"
    echo ""

    if [[ ! -f "${ROOT_DIR}/orchestration_log.md" ]]; then
        echo "No orchestration log found"
        return
    fi

    # Simple parsing of log file
    local total_cost=0
    local opus_cost=0
    local sonnet_cost=0
    local haiku_cost=0

    while IFS='|' read -r _ timestamp agent task model input output cost _; do
        # Skip header and empty lines
        [[ "$agent" =~ ^[[:space:]]*Agent ]] && continue
        [[ -z "$cost" ]] && continue

        # Extract numeric cost
        cost_num=$(echo "$cost" | tr -d '$ ')
        total_cost=$(echo "$total_cost + $cost_num" | bc 2>/dev/null || echo "$total_cost")

        case $(echo "$model" | tr -d ' ') in
            opus) opus_cost=$(echo "$opus_cost + $cost_num" | bc 2>/dev/null || echo "$opus_cost") ;;
            sonnet) sonnet_cost=$(echo "$sonnet_cost + $cost_num" | bc 2>/dev/null || echo "$sonnet_cost") ;;
            haiku) haiku_cost=$(echo "$haiku_cost + $cost_num" | bc 2>/dev/null || echo "$haiku_cost") ;;
        esac
    done < "${ROOT_DIR}/orchestration_log.md"

    echo "  Opus:   \$${opus_cost:-0}"
    echo "  Sonnet: \$${sonnet_cost:-0}"
    echo "  Haiku:  \$${haiku_cost:-0}"
    echo "  ─────────────"
    echo "  Total:  \$${total_cost:-0}"
}

# Show help
cmd_help() {
    echo "Kleiber Conductor - Orchestra Task Management"
    echo ""
    echo "Usage: conductor.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  assign <agent> <task-id> \"<description>\" [priority]"
    echo "      Assign a task to an agent"
    echo ""
    echo "  status"
    echo "      Show orchestra status (tasks, agents, blockers)"
    echo ""
    echo "  watch"
    echo "      Watch status in real-time (refreshes every 2s)"
    echo ""
    echo "  review <agent>"
    echo "      Review completed work from an agent"
    echo ""
    echo "  unblock <agent> <task-id>"
    echo "      Resolve a blocked task"
    echo ""
    echo "  log <agent> <task-id> <model> <input-tokens> <output-tokens>"
    echo "      Log task completion with token usage"
    echo ""
    echo "  costs"
    echo "      Show cost summary from orchestration log"
    echo ""
    echo "Agents: architect, engineer-frontend, engineer-backend, validator, scribe"
    echo "Models: opus, sonnet, haiku"
    echo "Priority: p0, p1, p2, p3"
}

# Parse command
case "${1:-}" in
    assign)
        cmd_assign "$2" "$3" "$4" "$5"
        ;;
    status)
        cmd_status
        ;;
    watch)
        cmd_watch
        ;;
    review)
        cmd_review "$2"
        ;;
    unblock)
        cmd_unblock "$2" "$3"
        ;;
    log)
        cmd_log "$2" "$3" "$4" "$5" "$6"
        ;;
    costs)
        cmd_costs
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        cmd_help
        ;;
esac
