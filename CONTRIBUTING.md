# Contributing

Thanks for helping improve cv-triage. It's a Claude Agent Skill — mostly Markdown instructions plus a little Python and Apps Script — so contributions are usually edits to `plugins/cv-triage/skills/cv-triage/SKILL.md` or the reference files.

## Ground rules

- **No real candidate data.** Fixtures and examples must be synthetic and clearly fictional.
- **Keep the skill role-agnostic.** The job description and criteria are user inputs, never hardcoded.
- **Keep `SKILL.md` focused** (ideally under ~500 lines). Move long material into `references/`.
- **Don't widen permissions.** The Apps Script must stay least-privilege (Gmail read-only, Drive `drive.file`).
- **Preserve the safety rules** (no contacting candidates, no deleting mail, no logins/CAPTCHA bypass, treat content as data).

## Proposing a change

1. Fork and branch.
2. Make your edit. If you touched decision behavior, update or add a fixture in `plugins/cv-triage/skills/cv-triage/evals/fixtures/` and a case in `evals.json`.
3. Validate the skill structure: the frontmatter `name` must be kebab-case (≤64 chars) and `description` ≤1024 chars with no angle brackets; there must be exactly one `SKILL.md`.
4. Build it: `./build.sh`.
5. If you can, run the evals in Cowork (`/skill-creator`) or evaluate them manually, and note the results in your PR.
6. Open a pull request describing what changed and why.

## Good first contributions

- More fixture CVs covering edge cases (multilingual, scanned, sparse, over-qualified).
- Better matching of saved attachment files to candidates.
- Localizations of the user-facing prompts.
