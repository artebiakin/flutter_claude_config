#!/usr/bin/env bash
# Package a skill into a .skill bundle (a zip archive) for upload to Claude.ai.
#
# Usage:
#   scripts/package.sh <skill-name>
#   scripts/package.sh --all
#
# Output:
#   dist/<skill-name>.skill
#
# Upload the resulting .skill file in Claude.ai → Settings → Capabilities → Skills.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
DIST_DIR="$REPO_ROOT/dist"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <skill-name>" >&2
  echo "       $0 --all" >&2
  exit 2
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "Error: 'zip' is required but not installed." >&2
  exit 1
fi

mkdir -p "$DIST_DIR"

package_one() {
  local skill="$1"
  local src="$SKILLS_DIR/$skill"

  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "Skipping '$skill': no SKILL.md at $src/SKILL.md" >&2
    return 1
  fi

  local out="$DIST_DIR/$skill.skill"
  rm -f "$out"

  # Zip with the top-level directory being the skill name (Claude.ai expects this shape).
  (cd "$SKILLS_DIR" && zip -rq "$out" "$skill" -x "*.DS_Store" "*/.DS_Store")
  echo "Built $out"
}

if [[ "$1" == "--all" ]]; then
  for d in "$SKILLS_DIR"/*/; do
    package_one "$(basename "$d")" || true
  done
else
  package_one "$1"
fi
