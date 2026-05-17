# flutter_claude_config

Personal Claude config for Flutter (and adjacent) development. Skills, CLAUDE.md templates, slash commands, subagents, prompts, and MCP examples — all in one place so I can drop them into any new project.

## Quick use

- **New Flutter project?** Copy `skills/flutter-widget` to `<project>/.claude/skills/`, or run `scripts/install-skill.sh flutter-widget <project>`.
- **Need a CLAUDE.md?** Pick from `claude-md/` and copy to your project root as `CLAUDE.md`.
- **Installing in Claude.ai?** Grab the packaged `.skill` file from the latest [release](https://github.com/artebiakin/flutter_claude_config/releases).

## What's where

| Path | What it is |
| --- | --- |
| `skills/` | Reusable Claude Code skills (one folder each). See `skills/README.md` for the index. |
| `claude-md/` | `CLAUDE.md` templates per project type (Flutter app, etc.). |
| `commands/` | Slash commands for Claude Code (drop into `.claude/commands/`). |
| `agents/` | Subagent definitions (drop into `.claude/agents/`). |
| `prompts/` | One-shot prompts I reuse. |
| `mcp/` | MCP server config examples (sanitized — no secrets). |
| `scripts/` | Install/sync/package helpers. |

## Three ways to reuse this in a project

Pick whichever fits — they're not mutually exclusive.

### 1. Git submodule (best for solo use, full version control)

In any new project:

```bash
git submodule add git@github.com:artebiakin/flutter_claude_config.git .claude/shared
ln -s shared/skills/flutter-widget .claude/skills/flutter-widget
```

Update later with:

```bash
git submodule update --remote .claude/shared
```

### 2. Install script (simplest, no submodule complexity)

```bash
# from this repo's root
./scripts/install-skill.sh flutter-widget /path/to/your/project
```

Re-run any time to refresh.

### 3. Packaged `.skill` files (for Claude.ai)

Claude.ai can't reference a repo — you upload `.skill` files in Settings. Build one with:

```bash
./scripts/package.sh flutter-widget
# → dist/flutter-widget.skill
```

Attach the result to a GitHub Release; "installing" on any machine becomes "download → upload to Claude.ai".

## Adding a new skill

1. Create `skills/<name>/SKILL.md` (with frontmatter — see `skills/flutter-widget/SKILL.md` for shape).
2. Add a one-line entry to `skills/README.md`.
3. Optional: `./scripts/package.sh <name>` to build a `.skill` file.
4. Optional: tag a release with the `.skill` attached.

## License

MIT — see [LICENSE](./LICENSE).
