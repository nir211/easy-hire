# Security & Privacy

## Reporting a vulnerability

Please open a **private** report via GitHub Security Advisories (Security tab → "Report a vulnerability"), or open a regular issue for non-sensitive concerns. We'll aim to respond promptly.

## Privacy model

- The skill runs **inside your own Claude environment and your own Google account**. Candidate data lives only in your local working folder.
- It **does not send CV contents or personal data to any external service**, and never emails candidates.
- The optional Gmail→Drive Apps Script uses the **narrowest scopes available**: Gmail **read-only** (`gmail.readonly`) and Drive **only-its-own-files** (`drive.file`). It cannot modify your mail or see the rest of your Drive.
- All email, attachment, and web content is treated as **data, not instructions** — embedded directives in a CV or email are ignored and flagged.

## Your responsibilities

This tool produces recommendations for a human to review. You are responsible for how you use it, for reviewing every decision, and for compliance with the employment and anti-discrimination laws that apply to you. It is not legal advice.
