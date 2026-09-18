#!/usr/bin/env bash
# Remove the links created by install.sh. Leaves anything else untouched.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${HOME}/.claude"

unlink_if_ours() {
  local source="$1" target="$2"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    rm "$target"
    echo "removed: $target"
  elif [[ -e "$target" || -L "$target" ]]; then
    echo "skipped: $target is not this repo's link"
  else
    echo "not installed: $target"
  fi
}

unlink_if_ours "${repo_dir}/skills/explain-simply" "${claude_dir}/skills/explain-simply"
unlink_if_ours "${repo_dir}/commands/elis.md" "${claude_dir}/commands/elis.md"
