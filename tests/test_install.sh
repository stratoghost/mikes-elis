#!/usr/bin/env bash
# Runs install.sh and uninstall.sh against a throwaway HOME.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

check() {
  local description="$1"
  shift
  if "$@"; then
    echo "ok   - $description"
  else
    echo "FAIL - $description"
    failures=$((failures + 1))
  fi
}

fresh_home() {
  HOME="$(mktemp -d)"
  export HOME
}

skill_link() { echo "$HOME/.claude/skills/explain-simply"; }
command_link() { echo "$HOME/.claude/commands/elis.md"; }

points_at() { [[ -L "$1" && "$(readlink "$1")" == "$2" ]]; }
absent() { [[ ! -e "$1" && ! -L "$1" ]]; }

# Fresh install creates both links.
fresh_home
"$repo_dir/install.sh" >/dev/null
check "skill linked" points_at "$(skill_link)" "$repo_dir/skills/explain-simply"
check "command linked" points_at "$(command_link)" "$repo_dir/commands/elis.md"
check "skill file readable through link" test -f "$(skill_link)/SKILL.md"

# Second run changes nothing and succeeds.
output="$("$repo_dir/install.sh")"
check "second install succeeds and reports already installed" \
  grep -q "already installed" <<<"$output"

# Uninstall removes both links.
"$repo_dir/uninstall.sh" >/dev/null
check "skill link removed" absent "$(skill_link)"
check "command link removed" absent "$(command_link)"

# Install refuses to overwrite a file it did not create, and fails loudly.
fresh_home
mkdir -p "$HOME/.claude/commands"
echo "someone else's command" >"$(command_link)"
if "$repo_dir/install.sh" >/dev/null 2>&1; then
  check "install fails on existing foreign file" false
else
  check "install fails on existing foreign file" true
fi
check "foreign file left untouched" grep -q "someone else's command" "$(command_link)"

# Uninstall leaves a foreign file alone.
"$repo_dir/uninstall.sh" >/dev/null
check "uninstall leaves foreign file" grep -q "someone else's command" "$(command_link)"

echo
if ((failures > 0)); then
  echo "$failures install test(s) failed"
  exit 1
fi
echo "all install tests passed"
