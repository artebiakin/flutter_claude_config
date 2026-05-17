# Slash commands

Custom slash commands for Claude Code. Drop these into `.claude/commands/` in your project (or `~/.claude/commands/` for user-wide) and invoke with `/<name>`.

## Index

_(none yet — add your first command and link it here)_

## Format

Each command is a single Markdown file. The filename (minus `.md`) is the slash name.

```markdown
---
description: One-line description shown in the command picker.
allowed-tools: [Bash, Read, Edit]  # optional — restrict tools for this command
---

Body of the prompt. Use `$ARGUMENTS` for the text passed after the slash command.
```

## Adding a command

1. Create `commands/<name>.md` with the format above.
2. Add a row to the index table.
3. Install into a project with `cp commands/<name>.md /path/to/project/.claude/commands/`.
