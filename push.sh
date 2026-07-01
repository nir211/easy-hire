#!/usr/bin/env bash
# Publish THIS repo as the clean first version of github.com/nir211/easy-hire.
# Replaces whatever is currently on main with a single initial commit.
# Requires: git + push access already configured (gh auth / PAT / SSH).
set -euo pipefail
REMOTE="https://github.com/nir211/easy-hire.git"
BRANCH="main"

[ -f README.md ] && [ -d .claude-plugin ] || { echo "Run this from the repo root."; exit 1; }

rm -rf .git
git init -q
git checkout -q -B "$BRANCH"
git add -A
git commit -q -m "Initial release: easy-hire CV-triage skill + Claude Code plugin"
git remote add origin "$REMOTE"

echo "Force-pushing clean first version to $REMOTE ($BRANCH)..."
git push -f -u origin "$BRANCH"
echo "Done: https://github.com/nir211/easy-hire"
