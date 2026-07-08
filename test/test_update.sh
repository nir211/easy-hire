#!/usr/bin/env bash
# Hermetic tests for update.sh — no network, uses local file:// bare repos.
#   T1 REUSE      : run inside a clone -> the change reaches the remote.
#   T2 STANDALONE : run in an unzipped folder (no shared history) -> pushes
#                   cleanly and NEVER produces an "unrelated histories" conflict.
#   T3 PREFLIGHT  : a rebase in progress -> refuses and does not push.
# Override the script under test with UPDATE_SH=/path/to/update.sh
set -uo pipefail

UPDATE_SH="${UPDATE_SH:-$(cd "$(dirname "$0")/.." && pwd)/update.sh}"
export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.com

pass=0; fail=0
ok(){ echo "  PASS: $1"; pass=$((pass+1)); }
no(){ echo "  FAIL: $1"; fail=$((fail+1)); }

seed_remote(){ # echoes path to a seeded bare repo on branch main
  local bare seed; bare="$(mktemp -d)/o.git"
  git init -q --bare -b main "$bare" 2>/dev/null || { git init -q --bare "$bare"; git --git-dir="$bare" symbolic-ref HEAD refs/heads/main; }
  seed="$(mktemp -d)/seed"; git clone -q "$bare" "$seed" 2>/dev/null
  ( cd "$seed"
    git checkout -q -B main
    mkdir -p .claude-plugin plugins/cv-triage/.claude-plugin
    echo "# easy-hire" > README.md
    echo '{"name":"easy-hire","plugins":[]}' > .claude-plugin/marketplace.json
    echo '{"name":"cv-triage","version":"1.0.0"}' > plugins/cv-triage/.claude-plugin/plugin.json
    git add -A; git commit -q -m "seed"; git push -q origin main )
  echo "$bare"
}
remote_has(){ git --git-dir="$1" show "main:$2" 2>/dev/null | grep -q "$3"; }

t1(){ local bare w; bare="$(seed_remote)"
  w="$(mktemp -d)/repo"; git clone -q "$bare" "$w"; cp "$UPDATE_SH" "$w/update.sh"
  ( cd "$w"; echo "reuse-change" >> README.md
    EASYHIRE_REMOTE="$bare" EASYHIRE_BRANCH=main bash update.sh "t1" ) >/dev/null 2>&1 || true
  remote_has "$bare" README.md "reuse-change" && ok "T1 REUSE pushes to remote" || no "T1 REUSE did not push"
}

t2(){ local bare w out rc; bare="$(seed_remote)"
  w="$(mktemp -d)/unzipped"; git clone -q "$bare" "$w"; rm -rf "$w/.git"   # simulate unzip
  echo "standalone-change" >> "$w/README.md"; cp "$UPDATE_SH" "$w/update.sh"
  out="$( cd "$w"; EASYHIRE_REMOTE="$bare" EASYHIRE_BRANCH=main bash update.sh "t2" 2>&1 )"; rc=$?
  if echo "$out" | grep -qiE "conflict|unrelated histories"; then no "T2 standalone hit a conflict (the bug)"
  elif [ $rc -ne 0 ]; then no "T2 standalone exited $rc"
  elif remote_has "$bare" README.md "standalone-change"; then ok "T2 standalone pushes cleanly, no conflict"
  else no "T2 standalone did not push the change"; fi
}

t3(){ local bare w out rc; bare="$(seed_remote)"
  w="$(mktemp -d)/repo"; git clone -q "$bare" "$w"; cp "$UPDATE_SH" "$w/update.sh"
  mkdir -p "$w/.git/rebase-merge"
  out="$( cd "$w"; EASYHIRE_REMOTE="$bare" EASYHIRE_BRANCH=main bash update.sh "t3" 2>&1 )"; rc=$?
  { [ $rc -ne 0 ] && echo "$out" | grep -qi rebase; } && ok "T3 refuses while mid-rebase" || no "T3 did not refuse mid-rebase (rc=$rc)"
}

t1; t2; t3
echo "----"; echo "passed=$pass failed=$fail"
[ "$fail" -eq 0 ]
