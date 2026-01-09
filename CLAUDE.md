# Claude Code Orchestration Blueprint

> One orchestrator. 5-15 parallel Claude Code agents. Production systems in days, not months.

## The Player Piano Principle

Git worktrees enable multiple Claude Code instances to work simultaneously on the same repository. Each agent operates in an isolated directory with its own branch. You become the conductor—reviewing outputs, merging winners, discarding failures.

**Traditional Development:**
- 1 architect + 5 engineers → 10-12 weeks
- Sequential execution, human bottlenecks
- Integration conflicts discovered late

**Orchestrated Development:**
- 1 orchestrator + 15 Claude agents → 3-5 days
- Parallel execution, isolated worktrees
- Merge gates validate continuously

## Architecture Standards

### Code Conventions
- **TypeScript** with strict mode enabled
- **Zod** for runtime schema validation
- **Repository pattern** for data access layer
- **Dependency injection** via constructor (no magic)
- **Unit test coverage** minimum 80%
- **Integration tests** for all API endpoints

### API Design
- RESTful endpoints with OpenAPI documentation
- GraphQL for complex queries (optional)
- Rate limiting on all public endpoints
- JWT authentication with refresh tokens
- Request/response logging for audit trails

### Data Layer
- PostgreSQL as primary database
- Redis for caching and session storage
- Migrations via Drizzle or Prisma
- Soft deletes for audit compliance
- Encrypted PII fields

### Infrastructure
- Docker containers for all services
- Kubernetes manifests (or Docker Compose for dev)
- Health check endpoints (`/health`, `/ready`)
- Prometheus metrics (`/metrics`)
- Structured JSON logging

## Agent Protocol

When you are a Claude Code agent working in a worktree:

### 1. Read Your Assignment
```bash
cat TASK.md  # Your specific task
cat CLAUDE.md  # Architecture rules (this file)
```

### 2. Implement the Feature
- Follow architecture standards above
- Stay within your task scope—don't refactor unrelated code
- Create or update tests for your changes
- Run tests locally: `npm test`

### 3. Document Your Work
Write a summary in `AGENT_NOTES.md`:
```markdown
## What I Built
[Brief description]

## Key Decisions
- [Why you chose approach X over Y]

## Files Changed
- src/feature/...
- tests/feature/...

## Dependencies Added
- [Any new packages]

## Open Questions
- [Anything the orchestrator should review]
```

### 4. Signal Completion
Your branch is ready for review when:
- [ ] All tests pass
- [ ] AGENT_NOTES.md is updated
- [ ] No unrelated changes included

## Human Orchestrator Protocol

### Spawning Agents
```bash
# Run the orchestration script
./scripts/orchestrate.sh

# This creates ../worktrees/agent-1, agent-2, etc.
# Each with CLAUDE.md, TASK.md, and empty AGENT_NOTES.md
```

### Managing Sessions
1. Open each worktree in a separate terminal
2. Run `claude` in each directory
3. Paste the task context or let Claude read TASK.md
4. Tab-switch between sessions, review progress
5. Don't wait—if one agent is thinking, check another

### Merging Results
```bash
# Review what each agent produced
./scripts/merge-helper.sh

# For each branch:
# - Run tests
# - Review AGENT_NOTES.md
# - Approve, request changes, or discard
```

### Acceptable Abandonment
10-20% rejection rate is normal. With 15 parallel agents:
- 12 successful implementations = 10x throughput
- 3 discarded = exploration cost, not failure

## Task Decomposition Patterns

### 5-Agent MVP (6-8 hours)
| Agent | Task |
|-------|------|
| 1 | Database schema + migrations |
| 2 | Core API endpoints (CRUD) |
| 3 | Authentication + authorization |
| 4 | Health checks + basic monitoring |
| 5 | Integration tests |

### 15-Agent Production System (3-5 days)
| Agents | Domain |
|--------|--------|
| 1-3 | Infrastructure (Terraform, K8s, CI/CD) |
| 4-8 | Backend services (microservices, queues) |
| 9-10 | API layer (REST, GraphQL, WebSocket) |
| 11-12 | Security (OAuth, encryption, audit) |
| 13-15 | Operations (Prometheus, Grafana, alerts) |

### 50+ Agent Enterprise Platform (1-2 weeks)
| Agents | Domain |
|--------|--------|
| 1-10 | Multi-region infrastructure + DR |
| 11-25 | Microservices with complex business logic |
| 26-33 | Compliance (GDPR, PCI-DSS, SOC 2) |
| 34-40 | Security (threat detection, anomaly monitoring) |
| 41-50 | Testing (unit, integration, load, security) |

## Merge Strategy

### Before Merging
```bash
# Fetch latest main
git fetch origin main

# Rebase your feature branch
git rebase origin/main

# Run full test suite
npm test

# Push with lease (safe force push)
git push --force-with-lease
```

### Conflict Resolution
1. **Automated checks** must pass (tests, linting, security)
2. **Human review** validates implementation against CLAUDE.md
3. **Logical conflicts** (two agents built incompatible approaches) → orchestrator decides
4. **Merge order** matters: infrastructure → services → API → tests

## Anti-Patterns to Avoid

### Agents Should NOT:
- Modify shared config files (package.json, tsconfig) without explicit instruction
- Refactor code outside their task scope
- Add dependencies without documenting why
- Skip tests "to save time"
- Commit secrets or credentials

### Orchestrators Should NOT:
- Assign overlapping tasks to multiple agents
- Wait for one agent to finish before starting others
- Micromanage—trust the blueprint, review the output
- Force merges without running tests

---

Built by DevGap. Orchestrated with Digital Dali. Powered by Claude.
