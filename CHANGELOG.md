# Changelog

All notable changes to this project are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this project uses semantic-ish versioning.

## [1.1.3]

- **Clearer first-run setup.** The setup step now collects the job description and the targeting criteria as two separate, explicit asks, and tells the user to **paste the full JD text** (not just a role title). Fixes real Cowork feedback where the agent asked only for "the role you're hiring for" and bundled the criteria in, so it wasn't clear the full JD could be pasted or that criteria were a distinct input. Added example prompt wording for the agent to use.

## [1.1.2]

- **Documented running in Claude Code** via `references/running-in-claude-code.md` — MCP connectors plus the built-in **in-session `/loop`** scheduler. Unattended headless/OS-cron scheduling is intentionally not documented, to keep the agent human-present when reading a mailbox.
- **Added an as-is disclaimer** (`DISCLAIMER.md`) and surfaced it in `README.md`, `quickstart.md`, and `SKILL.md`: recommendations only, the human decides, no warranty, no liability, user owns compliance.
- **Expanded code comments** across the Gmail→Drive Apps Script (per-step explanations of scopes, dedup, and folder reuse).

## [1.1.1]

- **Fixed `update.sh`** — it used to `git init` + `git pull` in a fresh folder, creating an "unrelated histories" merge conflict on push. It now auto-detects mode: **REUSE** (inside a clone → commit, rebase, push) or **CLONE** (standalone folder → clone the remote, overlay files, push, and adopt the clone's `.git`). It refuses to run mid-rebase and never force-pushes.
- **Added `test/test_update.sh`** — hermetic tests (local `file://` remotes, no network) covering the REUSE push, the standalone-no-conflict case, and the mid-rebase refusal. Written test-first to reproduce the bug, then fixed.
- Documented the update/release flow and the repo scripts in `CLAUDE.md`.

## [1.1.0]

Adds recruiter-facing value and unattended operation.

- **De-duplication** across repeat and cross-source applicants (same person via multiple boards), matched on message ID + normalized email/name/phone; updated CVs re-evaluate in place instead of duplicating.
- **Explained decisions**: every call states what matched, what's missing, a Confidence level, and the one thing that would change it.
- **Standout spotlight**: exceptional candidates flagged and surfaced first in the digest; near-misses and watch-outs called out; Interview ranked best-first.
- **Funnel + source tracking**: new `Source`, `Confidence`, and `Standout?` columns; run summary reports the source breakdown (including where standouts come from).
- **Loops & scheduling**: idempotent by design; documented unattended/scheduled Cowork mode (triage + digest, never blocks on input, never acts irreversibly).
- Added `CLAUDE.md` engineering knowledgebase; extended evals with standout, dedup, and explanation-quality cases.
- **Softened attachment language** to conditional ("may", "in case") across SKILL.md, README, quickstart, and the Gmail→Drive guide: the skill now tries the attachment first and only falls back to the CV-source folder when it isn't available, so the docs hold whether or not the connector surfaces attachments.

## [1.0.0] — Initial public release

First public version. Hardened against findings from a live end-to-end evaluation:

- **Attachment fallback + lifecycle.** Reads CVs from a Drive/local "CV source" folder
  (Gmail attachments aren't exposed by the connector). Unreadable-CV candidates are
  parked as **Blocked** (separate list), auto-resolve when the file arrives, and
  auto-**Lapse** after 7 days.
- **Empty-label false-negative guard.** Never trusts a zero-result label query; cross-checks
  and warns instead of silently reporting "Nothing new."
- **Deterministic backup.** `scripts/backup_tracker.py` runs as the first step of any write.
- **Fairness guardrail.** Detects protected-attribute preferences in criteria, warns,
  requires confirmation, and applies them only as a logged tie-breaker.
- **Least-privilege Gmail→Drive script.** Gmail read-only + Drive `drive.file` only.
- Honest description and Subject-header (mojibake) handling.
- Synthetic eval fixtures for decision-quality checks.
- **Distributed as a Claude Code plugin marketplace** (`/plugin marketplace add` + `/plugin install`) and as an uploadable `.skill` for Cowork / claude.ai. README documents install for each.
