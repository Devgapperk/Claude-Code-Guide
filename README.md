# Kleiber Orchestration System

> Named after conductor Erich Kleiber—one orchestrator, many virtuosos, flawless coordination.

**Turn one developer into an orchestration layer for 5-50+ parallel Claude Code agents.**

Ship production systems in days, not months.

## The Player Piano Principle

Traditional development bottlenecks on human typing speed. This repo enables **parallel execution**: one orchestrator managing 10-15 Claude Code agents simultaneously, each in isolated git worktrees.

| Approach | Timeline | Throughput |
|----------|----------|------------|
| Sequential (1 dev) | 10-12 weeks | 500 lines/day |
| Orchestrated (1 + 15 agents) | 3-5 days | 5,000+ lines/day |

The 10x isn't because AI types faster—it's because **parallel execution collapses wall-clock time**.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/Devgapperk/-Claude-Code-Guide.git
cd -Claude-Code-Guide

# Initialize Kleiber orchestra
./scripts/kleiber-setup.sh

# Spawn agent fleet (architect, frontend, backend, validator, scribe)
./scripts/spawn-agents.sh

# Assign tasks to agents
./scripts/conductor.sh assign engineer-backend feat-001 "Build user authentication API"
./scripts/conductor.sh assign engineer-frontend feat-002 "Create login form component"

# Open each worktree in separate terminals
cd ../worktrees/engineer-backend && claude
cd ../worktrees/engineer-frontend && claude

# Monitor orchestra status
./scripts/conductor.sh status
```

## Model Selection Policy

**Use the cheapest model that can reliably do the job.**

| Model | Cost | Use Case |
|-------|------|----------|
| **Opus** | $15/$75 per M | Architecture, security, compliance, complex refactors |
| **Sonnet** | $3/$15 per M | Feature implementation, APIs, UI (default) |
| **Haiku** | $0.25/$1.25 per M | Boilerplate, types, docs, logging |

See `CLAUDE.md` for detailed routing rules.

## Agent Roles

| Agent | Model | Responsibility |
|-------|-------|----------------|
| **Architect** | Opus | Reviews designs, approves architecture, never writes code |
| **Engineer-Frontend** | Sonnet | React, Tailwind, UI components |
| **Engineer-Backend** | Sonnet | Express, PostgreSQL, business logic |
| **Validator** | Haiku | Runs tests, checks types, reports status |
| **Scribe** | Haiku | Maintains docs, progress, changelog |

## Idea Pipeline

Transform messy founder brain dumps into actionable specs:

```
Voice Note → Idea Parser → Router → PRD Writer → Architect → Engineers
```

### Idea Parser
Takes raw input (voice transcripts, Slack dumps, whiteboard photos) and outputs structured `idea_snack.json`.

### Router
Analyzes parsed ideas and routes to:
- **Battalion**: breathe / dynasty / orchestra / brandmind
- **Model**: opus / sonnet / haiku
- **Next Agent**: prd-writer / architect / prototype-builder

See `agents/idea-parser.md` and `agents/router.md` for full prompts.

## Repository Structure

```
kleiber-orchestration/
├── CLAUDE.md                    # Orchestration blueprint + model routing
├── tasks.md                     # Parallel task backlog
├── orchestration_log.md         # Token usage + cost tracking
├── PROGRESS.md                  # Session progress (maintained by Scribe)
├── scripts/
│   ├── kleiber-setup.sh         # Initialize orchestra
│   ├── spawn-agents.sh          # Create agent worktrees
│   ├── conductor.sh             # Task management CLI
│   ├── orchestrate.sh           # Legacy: spawn from tasks.md
│   └── merge-helper.sh          # Review and merge branches
├── schemas/
│   └── idea_snack_v1.json       # Idea parser output schema
├── agents/
│   ├── idea-parser.md           # Voice/text → structured JSON
│   └── router.md                # Routing logic
├── tasks/                       # Task assignments per agent
├── progress/                    # Work-in-progress tracking
├── complete/                    # Completed task records
├── blocked/                     # Blocked task reports
├── docs/
│   ├── QUICKSTART.md
│   ├── WORKFLOW.md
│   └── ENTERPRISE.md
└── examples/
    └── settlement-service/      # Enterprise example
```

## Conductor Commands

```bash
# Assign task to agent
./scripts/conductor.sh assign <agent> <task-id> "<description>" [priority]

# Show orchestra status
./scripts/conductor.sh status

# Watch status in real-time
./scripts/conductor.sh watch

# Review agent's completed work
./scripts/conductor.sh review <agent>

# Unblock a stuck task
./scripts/conductor.sh unblock <agent> <task-id>

# Log token usage
./scripts/conductor.sh log <agent> <task-id> <model> <input-tokens> <output-tokens>

# Show cost summary
./scripts/conductor.sh costs
```

## Scaling Patterns

| Scale | Agents | Timeline | Traditional |
|-------|--------|----------|-------------|
| MVP | 5 | 6-8 hours | 2-3 weeks |
| Production | 15 | 3-5 days | 2-3 months |
| Enterprise | 50+ | 1-2 weeks | 4-6 months |

## Communication Protocol

```
Conductor → /tasks/{agent}/{task-id}.md        # Assignment
Agent     → /progress/{agent}/{task-id}-started.md  # Acknowledgment
Agent     → /complete/{agent}/{task-id}-done.md     # Completion
Agent     → /blocked/{agent}/{task-id}-conflict.md  # Blocker
```

## Cost Tracking

Every session logged in `orchestration_log.md`:

```markdown
| Timestamp | Agent | Task | Model | Input | Output | Cost |
|-----------|-------|------|-------|-------|--------|------|
| 2025-01-09T14:30:00Z | engineer-backend | feat-001 | sonnet | 15000 | 8000 | $0.165 |
```

Daily budget guard: Alert if spend exceeds $50.

## Documentation

- [Quick Start](docs/QUICKSTART.md) - 5 minutes to first agents
- [Workflow Guide](docs/WORKFLOW.md) - Daily orchestration patterns
- [Enterprise Guide](docs/ENTERPRISE.md) - Scaling to 50+ agents

## The Mental Shift

**Old job**: Write code line by line, debug, repeat.

**New job**: Define architecture, decompose into parallel tasks, route to models, review outputs, merge winners.

Skills that matter now:
- **Blueprint design**: How you structure CLAUDE.md
- **Task decomposition**: How you split work across agents
- **Model routing**: When to use Opus vs Sonnet vs Haiku
- **Quality validation**: How you review and merge
- **Cost management**: Tracking spend, optimizing routing

---

Built by [DevGap](https://devgap.co). Orchestrated with Digital Dali. Powered by Claude.
