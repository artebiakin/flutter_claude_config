# Skills

Reusable Claude Code skills. Each skill is a folder with a `SKILL.md` (the spec the model reads) and optional `reference/` and `templates/` directories.

## Index

| Skill | What it does |
| --- | --- |
| [`flutter-widget`](./flutter-widget/) | Produces Flutter widgets (Flutter 3.x / Dart 3) that are simple, testable, and performance-focused. Bans `Widget _buildX()` methods, missing `const`, bloated `build()` bodies, and business logic in widgets. Includes templates for stateless / stateful widgets and widget tests, plus reference docs on anti-patterns, extraction rules, performance, and testability. |

## Installing a skill in a project

```bash
../scripts/install-skill.sh <skill-name> /path/to/project
```

Or manually:

```bash
cp -r flutter-widget /path/to/project/.claude/skills/
```

## Packaging a skill for Claude.ai

```bash
../scripts/package.sh <skill-name>
# → dist/<skill-name>.skill
```

Upload the resulting `.skill` file in Claude.ai → Settings → Capabilities → Skills.

## Adding a new skill

1. `mkdir skills/<name> && touch skills/<name>/SKILL.md`
2. Add YAML frontmatter at the top of `SKILL.md`:

   ```yaml
   ---
   name: <name>
   description: <when this skill should trigger — be specific about file types, intents, and signals>
   ---
   ```

3. Add a one-line entry to the table above.
4. Optional: add `reference/` (longer docs the model can read on demand) and `templates/` (boilerplate files to copy).
