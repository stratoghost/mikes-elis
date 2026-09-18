#!/usr/bin/env bash
# Symlink the explain-simply skill and the /elis command into ~/.claude.
# Symlinks mean a `git pull` in this repo updates the installed copy.
# Safe to run twice. Refuses to overwrite anything it did not create.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${HOME}/.claude"

link() {
  local source="$1" target="$2"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    echo "already installed: $target"
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    echo "error: $target already exists and is not this repo's link; remove it first" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  echo "installed: $target -> $source"
}

link "${repo_dir}/skills/explain-simply" "${claude_dir}/skills/explain-simply"
link "${repo_dir}/commands/elis.md" "${claude_dir}/commands/elis.md"
