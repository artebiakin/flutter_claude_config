#!/usr/bin/env bash
# Sync a selection of skills, commands, and agents from this repo into a target project.
#
# Usage:
#   scripts/sync-to-project.sh <target-project-path> [--skills <names>] [--commands <names>] [--agents <names>] [--claude-md <template>]
#
# Examples:
#   # Just the flutter-widget skill
#   scripts/sync-to-project.sh ~/code/my-app --skills flutter-widget
#
#   # Everything available
#   scripts/sync-to-project.sh ~/code/my-app --skills all --commands all --agents all
#
#   # Skills + a CLAUDE.md template
#   scripts/sync-to-project.sh ~/code/my-app --skills flutter-widget --claude-md flutter-app

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  sed -n '2,16p' "$0"
  exit "${1:-2}"
}

if [[ $# -lt 1 ]]; then usage; fi

TARGET="$1"; shift
SKILLS=""
COMMANDS=""
AGENTS=""
CLAUDE_MD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills)    SKILLS="$2"; shift 2 ;;
    --commands)  COMMANDS="$2"; shift 2 ;;
    --agents)    AGENTS="$2"; shift 2 ;;
    --claude-md) CLAUDE_MD="$2"; shift 2 ;;
    -h|--help)   usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 2 ;;
  esac
done

if [[ ! -d "$TARGET" ]]; then
  echo "Error: target directory does not exist: $TARGET" >&2
  exit 1
fi

sync_set() {
  # $1 = kind (skills|commands|agents), $2 = comma-list or "all"
  local kind="$1"
  local list="$2"
  local src_dir="$REPO_ROOT/$kind"
  local dest_dir="$TARGET/.claude/$kind"

  [[ -z "$list" ]] && return 0
  mkdir -p "$dest_dir"

  local names=()
  if [[ "$list" == "all" ]]; then
    for entry in "$src_dir"/*; do
      local b
      b="$(basename "$entry")"
      [[ "$b" == "README.md" ]] && continue
      names+=("$b")
    done
  else
    IFS=',' read -r -a names <<< "$list"
  fi

  for name in "${names[@]}"; do
    local src="$src_dir/$name"
    if [[ ! -e "$src" ]]; then
      echo "Warning: $kind/$name not found, skipping" >&2
      continue
    fi
    local dest="$dest_dir/$name"
    rm -rf "$dest"
    cp -r "$src" "$dest"
    echo "Synced $kind/$name → $dest"
  done
}

sync_set skills   "$SKILLS"
sync_set commands "$COMMANDS"
sync_set agents   "$AGENTS"

if [[ -n "$CLAUDE_MD" ]]; then
  src="$REPO_ROOT/claude-md/$CLAUDE_MD.md"
  if [[ ! -f "$src" ]]; then
    echo "Error: CLAUDE.md template not found: $src" >&2
    exit 1
  fi
  dest="$TARGET/CLAUDE.md"
  if [[ -f "$dest" ]]; then
    echo "CLAUDE.md already exists at $dest — leaving it alone. (Remove it first to overwrite.)"
  else
    cp "$src" "$dest"
    echo "Wrote $dest from claude-md/$CLAUDE_MD.md"
  fi
fi

echo "Done."
