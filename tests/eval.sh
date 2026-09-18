#!/usr/bin/env bash
# Live check: runs /elis through Claude Code in a throwaway project that has
# the skill and command linked into its .claude directory. Your ~/.claude is
# not touched. Uses real tokens.
#
# Usage: tests/eval.sh [topic]
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
topic="${1:-how does DNS work}"

project="$(mktemp -d)"
trap 'rm -rf "$project"' EXIT
mkdir -p "$project/.claude/skills" "$project/.claude/commands"
ln -s "$repo_dir/skills/explain-simply" "$project/.claude/skills/explain-simply"
ln -s "$repo_dir/commands/elis.md" "$project/.claude/commands/elis.md"

output="$(cd "$project" && claude -p "/elis $topic" </dev/null)"
printf '%s\n\n' "$output"

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

check "has the In one line section" grep -q '\*\*I\*\*n \*\*on\*\*e \*\*li\*\*ne' <<<"$output"
check "has a diagram code block" grep -q '^```' <<<"$output"
check "uses Bionic bolding" grep -qE '\*\*[A-Za-z]+\*\*[a-z]' <<<"$output"
no_html() { ! grep -qi "<html" <<<"$output"; }
check "no HTML" no_html

prose_words="$(python3 - "$output" <<'EOF'
import re, sys
text = re.sub(r"```.*?```", "", sys.argv[1], flags=re.DOTALL)
prose = [l for l in text.splitlines() if not l.lstrip().startswith("|")]
print(len(" ".join(prose).replace("**", "").split()))
EOF
)"
# The skill budgets 120 words. The model cannot count words exactly, so allow a
# small margin here and fail only on real drift.
check "prose under 140 words (got $prose_words)" test "$prose_words" -lt 140

diagram_lines="$(python3 - "$output" <<'EOF'
import re, sys
blocks = re.findall(r"```.*?```", sys.argv[1], flags=re.DOTALL)
print(max((b.count("\n") - 1 for b in blocks), default=0))
EOF
)"
check "longest diagram is 15 lines or fewer (got $diagram_lines)" \
  test "$diagram_lines" -le 15

# Bionic accuracy: how many words are more than one letter off the rule.
bionic_errors="$(cd "$repo_dir/tests" && python3 - "$output" <<'EOF'
import re, sys
from bionic import cut_errors, strip_bold, TOKEN, strip_inline_code
text = re.sub(r"```.*?```", "", sys.argv[1], flags=re.DOTALL)
lines = [l for l in text.splitlines() if l.strip() and not re.fullmatch(r"\|[-| ]+\|", l.strip())]
words = sum(len(TOKEN.findall(strip_inline_code(l))) for l in lines)
errors = [e for l in lines for e in cut_errors(l)]
for error in errors:
    print(f"  {error}", file=sys.stderr)
print(100 * len(errors) // max(words, 1))
EOF
)"
check "Bionic errors under 5% of words (got ${bionic_errors}%)" \
  test "$bionic_errors" -lt 5

echo
if ((failures > 0)); then
  echo "$failures eval check(s) failed"
  exit 1
fi
echo "all eval checks passed"
