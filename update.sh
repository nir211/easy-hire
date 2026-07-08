#!/usr/bin/env bash
# update.sh — commit local changes and push them to the easy-hire remote, safely.
#
# Two modes, auto-detected:
#   REUSE  — run inside an existing clone that shares history with the remote:
#            commit, rebase onto the remote, push. A normal fast-forward update.
#   CLONE  — run in a folder that is NOT a clone of the remote (e.g. a freshly
#            unzipped repo, no shared history): clone the remote into a temp dir,
#            overlay the current folder's files onto it, commit, push, then adopt
#            the clone's .git so this folder becomes a proper clone for next time.
#
# This avoids the "unrelated histories" merge conflict that a naive
# `git init` + `git pull` produces (the earlier bug). It never force-pushes and
# refuses to run while a rebase/merge is in progress.
#
# Env overrides (used by the test suite):
#   EASYHIRE_REMOTE  default: https://github.com/nir211/easy-hire.git
#   EASYHIRE_BRANCH  default: main
#
# Usage: bash update.sh ["commit message"]
set -euo pipefail

REMOTE="${EASYHIRE_REMOTE:-https://github.com/nir211/easy-hire.git}"
BRANCH="${EASYHIRE_BRANCH:-main}"
MSG="${1:-Update cv-triage}"

die() { echo "update.sh: $*" >&2; exit 1; }

# Must run from the repo root — the tree we intend to publish.
[ -f README.md ] && [ -d .claude-plugin ] || die "run from the repo root (README.md and .claude-plugin/ must be here)."

# Refuse to run mid-rebase/merge — that state caused the earlier breakage.
if [ -e .git/rebase-merge ] || [ -e .git/rebase-apply ]; then
  die "a rebase is in progress. Run 'git rebase --abort' (or finish it) first."
fi
if [ -e .git/MERGE_HEAD ]; then
  die "a merge is in progress. Run 'git merge --abort' (or finish it) first."
fi

# Decide the mode: REUSE only if this is a work tree that shares history with the
# remote branch (or the remote branch does not exist yet, i.e. an empty remote).
mode="CLONE"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "$REMOTE"
  if git fetch -q origin "$BRANCH" 2>/dev/null; then
    if git rev-parse -q --verify HEAD >/dev/null 2>&1 \
       && git merge-base HEAD "origin/$BRANCH" >/dev/null 2>&1; then
      mode="REUSE"          # shared history -> safe to rebase + push
    fi
  else
    # remote branch not found (empty remote): a plain push from here is fine.
    git rev-parse -q --verify "origin/$BRANCH" >/dev/null 2>&1 || mode="REUSE"
  fi
fi

if [ "$mode" = "REUSE" ]; then
  echo "Mode: REUSE (updating this clone)"
  git add -A
  git commit -q -m "$MSG" || echo "(nothing new to commit)"
  if git rev-parse -q --verify "origin/$BRANCH" >/dev/null 2>&1; then
    if ! git pull -q --rebase origin "$BRANCH"; then
      git rebase --abort 2>/dev/null || true
      die "the remote moved and auto-rebase hit a conflict. Resolve manually, then 'git push origin $BRANCH'."
    fi
  fi
  git push -u origin "$BRANCH"
else
  echo "Mode: CLONE (this folder isn't a clone of the remote; cloning and overlaying safely)"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  git clone -q "$REMOTE" "$tmp/repo" || die "could not clone $REMOTE (check access)."
  # Overlay the current folder's files onto the clone (ours win), preserving the clone's .git.
  tar -cf - --exclude='.git' . | ( cd "$tmp/repo" && tar -xf - )
  (
    cd "$tmp/repo"
    git add -A
    git commit -q -m "$MSG" || echo "(nothing new to commit)"
    git push -u origin "$BRANCH"
  )
  # Adopt the clone's history so THIS folder is a real clone from now on.
  rm -rf .git
  cp -a "$tmp/repo/.git" ./.git
  git reset -q --hard "$BRANCH" 2>/dev/null || git reset -q --hard "origin/$BRANCH" 2>/dev/null || true
  echo "This folder is now a proper clone of the remote — future updates will use the REUSE path."
fi

# Best-effort version read for the closing message (portable; no python needed).
VER="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
      plugins/cv-triage/.claude-plugin/plugin.json 2>/dev/null | head -1)"
echo "Done. Pushed to $REMOTE ($BRANCH). CI will build and attach the v${VER:-?} release."
