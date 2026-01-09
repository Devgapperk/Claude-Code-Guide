# Parallel Agent Tasks

> Each unchecked task spawns one Claude Code agent in its own git worktree.
> Run `./scripts/orchestrate.sh` to create worktrees automatically.

## Core Infrastructure

- [ ] Set up TypeScript tooling (tsconfig.json, eslint, prettier, src/ structure)
- [ ] Create Docker development environment (Dockerfile, docker-compose.yml)
- [ ] Implement git worktree orchestration script with error handling
- [ ] Implement merge-helper script (list branches, run tests, generate PR summaries)
- [ ] Add CI/CD pipeline (GitHub Actions for test, lint, build)

## Example: Settlement Service

- [ ] Design database schema for double-entry ledger (PostgreSQL + Drizzle)
- [ ] Implement transaction service (create, validate, batch processing)
- [ ] Implement account service (balance queries, transaction history)
- [ ] Build REST API layer with authentication middleware
- [ ] Add Prometheus metrics and health check endpoints
- [ ] Write integration tests for settlement workflows

## Documentation

- [ ] Write docs/QUICKSTART.md (5-minute setup guide)
- [ ] Write docs/WORKFLOW.md (how to run 10+ parallel Claude sessions)
- [ ] Write docs/ENTERPRISE.md (scaling patterns for large teams)
- [ ] Create architecture diagrams (Mermaid or ASCII)

## Advanced Features

- [ ] Add WebSocket support for real-time agent status updates
- [ ] Implement cost tracking (estimate API usage per agent)
- [ ] Build dashboard UI for monitoring parallel sessions
- [ ] Create VS Code extension for worktree management

---

## Task Status Legend

- `[ ]` = Pending (will spawn agent)
- `[x]` = Completed (merged to main)
- `[-]` = Discarded (abandoned branch)
- `[~]` = In Progress (agent working)

## How to Add Tasks

1. Add new `- [ ] Task description` line above
2. Run `./scripts/orchestrate.sh` to spawn agents
3. Each agent gets its own worktree + branch
4. Review, merge, or discard as needed
