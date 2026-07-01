# Changelog

All notable changes to this project are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this project uses semantic-ish versioning.

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
