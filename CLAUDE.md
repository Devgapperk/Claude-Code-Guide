# KLEIBER ORCHESTRATION BLUEPRINT

> Named after conductor Carlos Kleiber—perfectionism, selective brilliance, legendary impact through restraint.
>
> "The greatest conductor of all time" conducted fewer performances than any peer.
> Each one became legendary. This is the model for AI deployment.

## System Architecture

### Stack
- **Frontend**: React 18 + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + PostgreSQL
- **Infrastructure**: Docker + Kubernetes
- **AI Layer**: Claude API (Opus/Sonnet/Haiku routing)

### Services
- API Gateway (rate limiting, auth)
- Core Business Logic (domain services)
- Data Layer (PostgreSQL + Redis cache)
- Message Queue (async task processing)
- Monitoring (Prometheus + Grafana)

### Deployment
- Git-based CI/CD (GitHub Actions)
- Docker containers
- Kubernetes orchestration
- Blue-green deployments

---

## Model Selection Policy

### General Principle
**Use the cheapest model that can reliably do the job.**
Reserve Opus for deep reasoning, high-risk changes, non-obvious architecture.

### Task → Model Routing

#### OPUS (Deep Reasoning) — $15/M input, $75/M output
Use for tasks requiring strategic thinking, complex trade-offs, or high-risk changes.

**When to use Opus:**
- System design, security flows, data models, complex refactors
- Non-obvious trade-offs, regulatory/compliance impact
- Architectural decisions affecting multiple services
- Code touching: money flow, authentication, PII, compliance

**Force Opus + Human Review:**
- Payment processing logic
- Authentication/authorization changes
- Data encryption implementations
- Compliance-related code (GDPR, PCI-DSS, HIPAA)
- Multi-service refactors

**Examples:**
```
"Design event-driven architecture for cross-border payments"
"Refactor authentication across 6 services without downtime"
"Implement PCI-DSS compliant card storage"
"Design rate limiting strategy for 10M requests/day"
```

#### SONNET (Feature Implementation) — $3/M input, $15/M output
The workhorse. Default choice for most development tasks.

**When to use Sonnet:**
- CRUD features, API endpoints, UI components
- Multi-file edits in known codebase
- Integration with external APIs
- Writing and updating tests
- Database migrations (non-destructive)

**Examples:**
```
"Add KYC status column and filter to dashboard"
"Implement webhook handler with integration tests"
"Create user settings page with form validation"
"Add pagination to search results endpoint"
```

#### HAIKU (Boilerplate & Repetitive) — $0.25/M input, $1.25/M output
Speed demon for mechanical tasks. 60x cheaper than Opus.

**When to use Haiku:**
- DTOs, mappers, type definitions
- Docstrings, JSDoc comments, logging statements
- JSON/YAML config files
- Skeleton/boilerplate files
- Task time < 10 minutes AND fully reversible

**Examples:**
```
"Generate TypeScript types from JSON schema"
"Add basic logging to these 5 functions"
"Create DTO classes for these API responses"
"Add JSDoc comments to exported functions"
```

#### CONTENT & DOCUMENTATION
- **First draft**: Sonnet (fast iteration)
- **Final polish** (exec/regulator-facing): Opus (precision matters)
- **Internal docs**: Haiku (speed over polish)

### Orchestration Rules

1. **Planner/Conductor**: Always Opus
   - Breaks work into tasks
   - Assigns models per task
   - Resolves conflicts between agents

2. **Workers**: Default Sonnet
   - Downgrade to Haiku for boilerplate
   - Upgrade to Opus for complexity discovered mid-task

3. **Logging**: Record actual model used per task in `orchestration_log.md`

4. **Cost Guard**: If daily spend > $50, alert human before continuing

---

## Agent Roles

### ARCHITECT (Opus, Strategic)
**Purpose**: High-level design and quality gates

**Responsibilities:**
- Reviews implementation plans before work begins
- Defines module boundaries and interfaces
- Approves architectural changes
- Validates security-sensitive designs

**Constraints:**
- Never writes code directly
- Only operates on design documents and reviews
- Works in: `/docs/architecture/*`, `/tasks/*`

**Communication:**
- Receives: Feature requests, technical proposals
- Produces: Approved designs, rejection with feedback

---

### ENGINEER-FRONTEND (Sonnet, Detail)
**Purpose**: User interface implementation

**Responsibilities:**
- React components with TypeScript
- Tailwind CSS styling
- State management (React Query, Zustand)
- Form validation and error handling
- Accessibility compliance (WCAG 2.1)

**Constraints:**
- Works in: `/src/frontend/*`, `/src/components/*`
- Must not modify backend code
- All components require Storybook stories

**Quality Gates:**
- TypeScript strict mode passes
- No console errors in dev tools
- Mobile responsive (375px minimum)

---

### ENGINEER-BACKEND (Sonnet, Structure)
**Purpose**: Server-side implementation

**Responsibilities:**
- Express routes and middleware
- Database queries (Drizzle ORM)
- Business logic services
- API input validation (Zod)
- Error handling and logging

**Constraints:**
- Works in: `/src/backend/*`, `/src/services/*`, `/src/db/*`
- Must not modify frontend code
- All endpoints require integration tests

**Quality Gates:**
- All tests pass
- No N+1 query patterns
- Proper error responses (not 500 for user errors)

---

### VALIDATOR (Haiku, Verification)
**Purpose**: Continuous quality assurance

**Responsibilities:**
- Runs test suite after each merge
- Checks linting and type errors
- Verifies database migrations
- Reports build status to conductor

**Constraints:**
- Read-only access to code
- Cannot modify source files
- Only creates reports in `/reports/*`

**Triggers:**
- After every `complete/*.md` file created
- On conductor request
- Every 30 minutes during active orchestration

---

### SCRIBE (Haiku, Documentation)
**Purpose**: Knowledge capture and communication

**Responsibilities:**
- Maintains `PROGRESS.md` with session summary
- Documents architectural decisions in `/docs/decisions/*`
- Updates API documentation
- Maintains CHANGELOG.md

**Constraints:**
- Works in: `/docs/*`, `*.md` files
- Cannot modify source code
- Must preserve existing content (append-only for logs)

**Outputs:**
- Daily progress summaries
- Decision records (ADRs)
- API changelog entries

---

## Communication Protocols

### Task Assignment
Conductor creates task file:
```
/tasks/{agent-name}/{task-id}.md
```

Task file format:
```markdown
# Task: {task-id}
Agent: {agent-name}
Model: {opus|sonnet|haiku}
Priority: {p0|p1|p2}
Created: {ISO timestamp}

## Description
{What to build}

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Context
{Relevant background, links to related tasks}

## Constraints
{What NOT to do, files NOT to touch}
```

### Work Started
Agent acknowledges:
```
/progress/{agent-name}/{task-id}-started.md
```

Format:
```markdown
# Started: {task-id}
Agent: {agent-name}
Started: {ISO timestamp}
Estimated: {duration}

## Approach
{How I plan to implement this}

## Files I'll Touch
- path/to/file1.ts
- path/to/file2.ts
```

### Work Complete
Agent signals completion:
```
/complete/{agent-name}/{task-id}-done.md
```

Format:
```markdown
# Complete: {task-id}
Agent: {agent-name}
Completed: {ISO timestamp}
Model Used: {opus|sonnet|haiku}
Tokens: {input}/{output}

## Summary
{What was built}

## Files Changed
- path/to/file1.ts (created)
- path/to/file2.ts (modified)

## Tests Added
- test/file1.test.ts

## Decisions Made
- Chose X over Y because Z

## Ready for Review
- [ ] Tests pass locally
- [ ] No linting errors
- [ ] Documentation updated
```

### Conflict/Blocked
Agent reports blocker:
```
/blocked/{agent-name}/{task-id}-conflict.md
```

Format:
```markdown
# Blocked: {task-id}
Agent: {agent-name}
Blocked Since: {ISO timestamp}
Type: {merge_conflict|dependency|unclear_requirements|technical}

## Problem
{What's blocking progress}

## Attempted Solutions
1. Tried X, failed because Y
2. Tried Z, partial success but...

## Need From Conductor
{Specific ask: resolve conflict, clarify requirements, etc.}
```

---

## Naming Conventions

### Files
- Components: `PascalCase.tsx` (e.g., `UserProfile.tsx`)
- Utilities: `camelCase.ts` (e.g., `formatDate.ts`)
- Tests: `*.test.ts` or `*.spec.ts`
- Types: `*.types.ts` for shared types

### Functions
- Handlers: `handle{Event}` (e.g., `handleSubmit`)
- Fetchers: `fetch{Resource}` (e.g., `fetchUsers`)
- Validators: `validate{Thing}` (e.g., `validateEmail`)
- Transformers: `{from}To{To}` (e.g., `apiToModel`)

### Git Branches
- Features: `feature/{task-id}-{short-description}`
- Fixes: `fix/{task-id}-{short-description}`
- Agents: `agent/{agent-name}` (worktree branches)

### Database
- Tables: `snake_case` plural (e.g., `user_accounts`)
- Columns: `snake_case` (e.g., `created_at`)
- Indexes: `idx_{table}_{columns}` (e.g., `idx_users_email`)

---

## Testing Requirements

### Coverage Targets
- Unit tests: 80% line coverage
- Integration tests: All API endpoints
- E2E tests: Critical user flows

### Required Test Types
1. **Unit**: Pure functions, utilities, validators
2. **Integration**: API endpoints, database operations
3. **Component**: React components with Testing Library
4. **E2E**: User flows with Playwright (critical paths only)

### Test File Location
- Unit: Colocated `*.test.ts` next to source
- Integration: `/tests/integration/*`
- E2E: `/tests/e2e/*`

---

## Cost Tracking

Log every agent session in `orchestration_log.md`:

```markdown
| Timestamp | Agent | Task | Model | Input Tokens | Output Tokens | Cost |
|-----------|-------|------|-------|--------------|---------------|------|
| 2025-01-09T14:30:00Z | engineer-backend | feat-001 | sonnet | 15000 | 8000 | $0.165 |
```

Daily summary at end of session:
```markdown
## Daily Summary: 2025-01-09
- Total tasks: 12
- Opus usage: 2 tasks, $4.50
- Sonnet usage: 8 tasks, $2.40
- Haiku usage: 2 tasks, $0.15
- **Total: $7.05**
```

---

Built by Digital Dali. Orchestrated with Kleiber. Powered by Claude.
