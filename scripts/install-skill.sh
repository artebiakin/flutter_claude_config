#!/usr/bin/env bash
# Install a skill from this repo into a target project's .claude/skills/.
#
# Usage:
#   scripts/install-skill.sh <skill-name> <target-project-path>
#
# Example:
#   scripts/install-skill.sh flutter-widget ~/code/my-flutter-app
#
# Re-run any time to refresh the skill in the target project.

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <skill-name> <target-project-path>" >&2
  exit 2
fi

SKILL="$1"
TARGET="$2"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/skills/$SKILL"

if [[ ! -d "$SRC" ]]; then
  echo "Error: skill '$SKILL' not found at $SRC" >&2
  echo "Available skills:" >&2
  ls -1 "$REPO_ROOT/skills" | grep -v '^README.md$' >&2 || true
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Error: target directory does not exist: $TARGET" >&2
  exit 1
fi

DEST="$TARGET/.claude/skills/$SKILL"
mkdir -p "$TARGET/.claude/skills"

if [[ -d "$DEST" ]]; then
  echo "Replacing existing skill at $DEST"
  rm -rf "$DEST"
fi

cp -r "$SRC" "$DEST"
echo "Installed '$SKILL' → $DEST"
