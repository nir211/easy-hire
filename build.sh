#!/usr/bin/env bash
# Build a standalone cv-triage.skill (zip of the skill folder) for upload to
# Cowork / claude.ai. Claude Code users don't need this — install via the
# marketplace (see README). Evals are excluded from the artifact.
set -euo pipefail
SKILL_PARENT="plugins/cv-triage/skills"
SKILL_NAME="cv-triage"
OUT="cv-triage.skill"

if [ ! -f "${SKILL_PARENT}/${SKILL_NAME}/SKILL.md" ]; then
  echo "Error: run from repo root (no ${SKILL_PARENT}/${SKILL_NAME}/SKILL.md)."; exit 1
fi

rm -f "$OUT"
( cd "$SKILL_PARENT" && zip -r "../../../${OUT}" "$SKILL_NAME" \
    -x "${SKILL_NAME}/evals/*" -x "*/__pycache__/*" -x "*.pyc" -x "*.DS_Store" >/dev/null )

echo "Built $OUT"
echo "Upload: Claude → Customize → Skills → + Create skill → $OUT"
