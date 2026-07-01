#!/usr/bin/env python3
"""Back up the candidate tracker before any write — deterministic and verified.

Usage:
    python scripts/backup_tracker.py /path/to/Candidates.xlsx

Behavior:
- First run (no tracker yet): prints a notice and exits 0 (nothing to back up).
- Otherwise: copies the tracker to <folder>/backups/<name>-<timestamp>.xlsx and
  verifies the copy exists and is non-empty. Exits non-zero on failure so the
  caller MUST stop before writing. This is Rule 7 made non-skippable.
"""
import shutil
import sys
import datetime
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python scripts/backup_tracker.py <tracker.xlsx>")
        return 2

    src = Path(sys.argv[1]).expanduser()
    if not src.exists():
        print(f"No tracker yet at {src} — nothing to back up (first run). OK.")
        return 0

    backups = src.parent / "backups"
    backups.mkdir(exist_ok=True)
    ts = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    dst = backups / f"{src.stem}-{ts}{src.suffix}"

    shutil.copy2(src, dst)

    if not dst.exists() or dst.stat().st_size == 0:
        print(f"BACKUP FAILED: {dst} missing or empty. DO NOT PROCEED with the write.")
        return 1

    print(f"Backup OK: {dst} ({dst.stat().st_size} bytes). Safe to proceed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
