# Claude Code Orchestration

> Turn one developer into an orchestration layer for 5-50+ parallel Claude Code agents.

**Ship production systems in days, not months.**

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
git clone https://github.com/YOUR_USERNAME/claude-code-orchestration.git
cd claude-code-orchestration

# Spawn agents for all pending tasks
./scripts/orchestrate.sh

# Open each worktree in a separate terminal
cd ../worktrees/agent-1 && claude
cd ../worktrees/agent-2 && claude
# ... etc

# When done, review and merge
./scripts/merge-helper.sh
```

## How It Works

### 1. Define Your Blueprint (CLAUDE.md)

Encode your architecture standards, coding conventions, and domain knowledge:

```markdown
## Architecture Standards
- TypeScript with strict mode
- Repository pattern for data access
- 80% test coverage minimum

## Agent Protocol
1. Read TASK.md
2. Implement within scope
3. Document in AGENT_NOTES.md
```

### 2. List Parallel Tasks (tasks.md)

```markdown
- [ ] Database schema + migrations
- [ ] Core API endpoints
- [ ] Authentication middleware
- [ ] Integration tests
- [ ] Monitoring dashboards
```

### 3. Spawn the Fleet

```bash
./scripts/orchestrate.sh
```

Creates:
- One git worktree per task
- One feature branch per agent
- CLAUDE.md + TASK.md + AGENT_NOTES.md in each

### 4. Orchestrate

- Tab-switch between Claude Code sessions
- Don't wait—check on others while one thinks
- Accept ~80%, discard ~20% (exploration cost)

### 5. Merge Winners

```bash
./scripts/merge-helper.sh
```

Interactive review: view diffs, read notes, merge or discard.

## Repository Structure

```
claude-code-orchestration/
├── CLAUDE.md                 # Orchestration blueprint
├── tasks.md                  # Parallel task backlog
├── scripts/
│   ├── orchestrate.sh        # Spawn agent worktrees
│   └── merge-helper.sh       # Review and merge branches
├── docs/
│   ├── QUICKSTART.md         # 5-minute setup
│   ├── WORKFLOW.md           # Daily orchestration patterns
│   └── ENTERPRISE.md         # Scaling to 50+ agents
└── examples/
    └── settlement-service/   # Real-world enterprise example
```

## Scaling Patterns

| Scale | Agents | Use Case |
|-------|--------|----------|
| MVP | 5 | Proof of concept (6-8 hours) |
| Production | 15 | Full-featured system (3-5 days) |
| Enterprise | 50+ | Mission-critical platform (1-2 weeks) |

See [docs/ENTERPRISE.md](docs/ENTERPRISE.md) for multi-team orchestration, compliance patterns, and cost management.

## The Mental Shift

**Old job**: Write code line by line, debug, repeat.

**New job**: Define architecture, decompose into parallel tasks, review outputs, merge winners.

The skills that matter now:
- **Prompt architecture**: How you structure CLAUDE.md
- **Task decomposition**: How you split work across agents
- **Quality validation**: How you review and merge
- **Workflow orchestration**: How you manage 10+ parallel sessions

## Example: Settlement Service

The `examples/settlement-service/` demonstrates a real-world pattern:

- Double-entry bookkeeping ledger
- Idempotent transaction processing
- Immutable audit trails
- Enterprise database schema

6 agents build this in 24-48 hours. Traditional timeline: 2-3 months.

## Commands

```bash
# Spawn agents for pending tasks
./scripts/orchestrate.sh

# Check status of all agents
./scripts/orchestrate.sh --status

# Clean up all worktrees
./scripts/orchestrate.sh --clean

# Interactive merge review
./scripts/merge-helper.sh

# List agent branches
./scripts/merge-helper.sh --list

# Run tests on all branches
./scripts/merge-helper.sh --test-all
```

## Why This Works

1. **Isolation**: Each agent works in its own worktree—no conflicts during development
2. **Context**: CLAUDE.md provides consistent architectural guidance
3. **Parallel**: 10 agents = 10x throughput (wall-clock time)
4. **Exploration**: Generate 15 implementations, pick the best 12
5. **Cheap failure**: Discard 20% without guilt—net positive with 80%

## Enterprise Applications

This methodology applies to:
- **Financial systems**: Settlement, payment processing, ledgers
- **Healthcare**: HIPAA-compliant data platforms
- **E-commerce**: Multi-tenant SaaS, inventory systems
- **Infrastructure**: Terraform modules, Kubernetes operators

Traditional enterprise timeline: 4-6 months with 8-person team.
Orchestrated timeline: 1-2 weeks with 50 agents.

## Documentation

- [Quick Start](docs/QUICKSTART.md) - 5 minutes to first agents
- [Workflow Guide](docs/WORKFLOW.md) - Daily orchestration patterns
- [Enterprise Guide](docs/ENTERPRISE.md) - Scaling to 50+ agents

---

Built by [DevGap](https://devgap.co). Orchestrated with Digital Dali. Powered by Claude.
