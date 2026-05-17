# CLAUDE.md templates

Drop-in `CLAUDE.md` templates per project type. Copy one to your project root, rename to `CLAUDE.md`, and edit the bracketed placeholders.

## Index

| Template | For |
| --- | --- |
| [`flutter-app.md`](./flutter-app.md) | A standard Flutter app (Flutter 3.x / Dart 3, plain state management). |

## Usage

```bash
cp claude-md/flutter-app.md /path/to/your/project/CLAUDE.md
```

Then open and fill in the `[bracketed]` placeholders (project name, package layout, state management choice, etc.).

## Adding a new template

1. Create `claude-md/<project-type>.md`.
2. Use `[bracketed]` placeholders for anything project-specific.
3. Add an entry to the table above.
