# Orchestration Workflow

> How to run 10+ parallel Claude Code sessions like a symphony conductor.

## The Player Piano Principle

A player piano doesn't make pianists obsolete—it transforms what musicianship means. One conductor can orchestrate performances previously impossible for a solo performer.

Claude Code follows the same pattern: you're not replaced, you're elevated from executor to orchestrator.

## Mental Model Shift

### Old Way (Sequential)
```
Write code → Wait → Review → Write more → Wait → Review → ...
```
- One task at a time
- Human bottleneck on typing speed
- 500 lines of quality code per day

### New Way (Parallel)
```
Configure agents → Launch 10 sessions → Tab-switch → Review → Merge winners
```
- 10 tasks simultaneously
- Human bottleneck on review speed (much faster)
- 5,000 lines across 10 features per day

## Daily Workflow

### Morning: Task Definition (30 minutes)

1. **Review backlog** in `tasks.md`
2. **Decompose work** into parallelizable chunks
3. **Add new tasks** as unchecked items
4. **Estimate agent count** (typically 5-15)

### Mid-Morning: Agent Spawn (15 minutes)

```bash
# Spawn agents
./scripts/orchestrate.sh

# Verify worktrees
./scripts/orchestrate.sh --status
```

### Core Hours: Parallel Execution (4-6 hours)

1. **Open terminals** for each worktree
2. **Launch Claude Code** in each
3. **Initial prompts**: "Read TASK.md and CLAUDE.md, then implement the task"
4. **Tab-switch pattern**:
   - Check agent-1 → progressing → switch
   - Check agent-2 → stuck → provide clarification → switch
   - Check agent-3 → completed → quick review → switch
   - ...

### Afternoon: Merge & Review (2-3 hours)

```bash
# Interactive review
./scripts/merge-helper.sh

# Or list status first
./scripts/merge-helper.sh --list
```

For each agent:
- Read `AGENT_NOTES.md`
- Review diff
- Run tests if available
- Merge, request changes, or discard

### End of Day: Housekeeping (15 minutes)

```bash
# Clean up merged worktrees
./scripts/orchestrate.sh --clean

# Update tasks.md with completed items
# Plan tomorrow's parallel work
```

## Tab-Switching Techniques

### The Rotation Pattern
Visit each agent in sequence, spending 2-3 minutes max:
```
Agent 1 → Agent 2 → Agent 3 → ... → Agent 10 → Agent 1
```

### The Priority Queue
Check high-priority/blocking tasks first:
```
Critical → High → Medium → Low → Critical
```

### The Completion Check
Focus on agents that seem close to done:
```
Check notes → If substantial content → Deep review → Else → Move on
```

## Handling Common Situations

### Agent is Stuck

**Symptoms**: Asking clarifying questions, going in circles

**Solution**: Provide specific context
```
"The database uses PostgreSQL with Drizzle ORM.
 The schema is in src/db/schema.ts.
 Use the existing transaction service pattern."
```

### Agent Went Off-Track

**Symptoms**: Implementing features not in TASK.md

**Solution**: Redirect firmly
```
"Stop. You're only implementing [specific task].
 Do not modify [unrelated files].
 Focus on [core deliverable]."
```

### Agent Finished Early

**Symptoms**: Completed task, waiting for next

**Solution**: Assign bonus tasks or wind down
```
"Great work. Write additional tests for edge cases."
OR
"Document your implementation in AGENT_NOTES.md and wait for review."
```

### Two Agents Conflict

**Symptoms**: Both modified same file

**Solution**: Pick winner, merge manually
```bash
# View both approaches
diff worktrees/agent-3/src/file.ts worktrees/agent-7/src/file.ts

# Merge preferred version
git checkout agent-3 -- src/file.ts
# Or manually combine best parts
```

## Advanced Patterns

### The Architect-First Pattern

1. Spawn 1 architect agent first
2. Wait for system design
3. Spawn 5-10 implementation agents
4. All reference architect's design

### The Test-First Pattern

1. Spawn 2 agents: one for tests, one for implementation
2. Test agent writes test suite first
3. Implementation agent makes tests pass
4. Natural TDD at agent scale

### The Review-Integrated Pattern

1. Spawn N implementation agents
2. Spawn 1-2 reviewer agents
3. Implementation agents complete → Reviewer agents review
4. Parallel code review, not sequential

## Metrics to Track

| Metric | Target | Meaning |
|--------|--------|---------|
| Agents spawned | 10-15/day | Parallel capacity |
| Merge rate | 80%+ | Quality of task decomposition |
| Wall-clock time | 6-8 hours | Total elapsed time |
| Features shipped | 8-12/day | Actual throughput |

## Common Mistakes

### Spawning Too Few Agents
- **Problem**: Only running 2-3 agents
- **Solution**: Push to 10+; the overhead is minimal

### Waiting on Individual Agents
- **Problem**: Watching one agent type code
- **Solution**: Tab-switch immediately; check back later

### Over-Specifying Tasks
- **Problem**: 2-page task descriptions
- **Solution**: Keep tasks to 2-3 sentences; trust CLAUDE.md for standards

### Not Discarding Failures
- **Problem**: Trying to salvage every agent's output
- **Solution**: 20% discard rate is healthy; move on

## The 10x Reality Check

You're not 10x faster because AI types faster. You're 10x faster because:

1. **Parallelism**: 10 tasks run simultaneously
2. **Exploration**: Try 3 approaches, pick the best
3. **No context-switching cost**: Each agent maintains its own context
4. **Failure is cheap**: Discard bad outputs without guilt

The skill shift: from "can I write this code?" to "can I decompose this into 10 parallel tasks and validate the outputs?"
