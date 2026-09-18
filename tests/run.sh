#!/usr/bin/env bash
# Runs every offline test. For a live check against Claude, see tests/eval.sh.
set -euo pipefail

tests_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(dirname "$tests_dir")"

echo "== shellcheck"
shellcheck "$repo_dir"/*.sh "$tests_dir"/*.sh
echo "ok"

echo "== skill and command"
(cd "$tests_dir" && python3 -m unittest -v test_skill)

echo "== install"
"$tests_dir/test_install.sh"
