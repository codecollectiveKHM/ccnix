#!/usr/bin/env bash
# Fail on app runtime state / personal file paths. Public file: patterns only, never literal personal strings;
# prints file names, never matches. Runs on git-tracked files (pre-commit) or the whole tree (flake check).
# (Bracketed chars keep the patterns from matching this file.)
set -euo pipefail
cd "${1:-.}"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  files() { git ls-files -z; }
else
  files() { find . -type f -print0; }
fi
state='(^|/)(vlc-qt-interface\.conf|vifminfo[^/]*|recently-used\.xbel|[^/]*_history|repomix-output[^/]*)$'
bad=$(
  files | grep -zE "$state" | tr '\0' '\n' || true
  files | xargs -0 -r grep -lsIE -e '/run/medi[a]/[^/[:space:]]+/[^[:space:]]' -e '^\[RecentsMR[L]\]' -e 'filedialog-pat[h]' || true
)
bad=$(sort -u <<<"$bad")
[ -z "$bad" ] || {
  printf 'privacy-check: runtime state or personal paths in:\n%s\n' "$bad" >&2
  exit 1
}
