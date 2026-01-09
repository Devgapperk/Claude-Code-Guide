# Quick Start Guide

> Get 5 parallel Claude Code agents running in under 5 minutes.

## Prerequisites

- Git installed
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code` or similar)
- Terminal that supports multiple tabs/windows

## Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/claude-code-orchestration.git
cd claude-code-orchestration
```

## Step 2: Review the Tasks

Open `tasks.md` to see what parallel work is available:

```bash
cat tasks.md
```

Each unchecked task (`- [ ]`) becomes one Claude Code agent.

## Step 3: Spawn the Agent Fleet

```bash
./scripts/orchestrate.sh
```

This creates:
- One git worktree per task
- One feature branch per agent
- CLAUDE.md blueprint in each worktree
- TASK.md with specific instructions
- Empty AGENT_NOTES.md for documentation

## Step 4: Launch Claude Code Sessions

Open a new terminal tab for each agent:

```bash
# Terminal 1
cd ../worktrees/agent-1
claude

# Terminal 2
cd ../worktrees/agent-2
claude

# Terminal 3
cd ../worktrees/agent-3
claude

# ... and so on
```

## Step 5: Orchestrate

Now you're the conductor:

1. **Tab-switch** between sessions
2. **Don't wait** for one agent to finish—check on others
3. **Review outputs** as agents complete
4. **Accept 80%**, discard 20%—that's normal

## Step 6: Merge Results

When agents complete their tasks:

```bash
./scripts/merge-helper.sh
```

This walks you through:
- Viewing diffs
- Reading agent notes
- Merging to main
- Discarding failed attempts

## That's It

You just ran 5 parallel development streams. Traditional timeline: 2-3 weeks. Your timeline: 6-8 hours.

## Next Steps

- Read [WORKFLOW.md](./WORKFLOW.md) for advanced patterns
- Check [ENTERPRISE.md](./ENTERPRISE.md) for scaling to 50+ agents
- Explore `examples/settlement-service/` for a real-world use case
