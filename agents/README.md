# Subagents

Custom subagent definitions for Claude Code. Drop these into `.claude/agents/` in your project (or `~/.claude/agents/` for user-wide) and invoke via the `Agent` tool with `subagent_type: <name>`.

## Index

_(none yet — add your first agent and link it here)_

## Format

Each agent is a single Markdown file. The filename (minus `.md`) is the agent name.

```markdown
---
name: <agent-name>
description: When this agent should be used. Be specific — the main agent picks which subagent to invoke based on this string.
tools: [Read, Grep, Bash]  # optional — restrict the agent's toolset
model: sonnet              # optional — sonnet | opus | haiku
---

System prompt for the subagent. Tell it its role, what to do, what to return,
and what to avoid. The subagent only sees this prompt plus the task message
the parent agent sends — it has no memory of the parent conversation.
```

## Adding an agent

1. Create `agents/<name>.md` with the format above.
2. Add a row to the index table.
3. Install into a project with `cp agents/<name>.md /path/to/project/.claude/agents/`.
