# Quickstart (for the person running this skill)

> _Provided as-is, no warranty. It recommends; you decide and own every hiring call. See DISCLAIMER._

A short setup guide. Once installed, just tell Claude something like *"go through the new applications"* or *"triage today's CVs"* and it runs.

## One-time setup

1. **Turn on file/code:** Settings → Capabilities → enable *Code execution and file creation*.
2. **Connect Gmail:** Settings → Connectors.
3. **Create an intake label** in Gmail (e.g. `job-applications`) with a filter that auto-applies it to applications — match the job inbox address, or subject keywords. The skill reads only this label.
4. **Set up attachment access (recommended).** In some setups Gmail's connector may not read file attachments, so attached CVs may need a folder the skill can see. Best: follow `gmail-to-drive-setup.md` to auto-save attachments to a Drive folder. Minimum: make a local `cvs/incoming/` folder and drop CVs in. In case a CV that was only attached can't be read, that candidate is parked as **Blocked** until the file appears.
5. **(Recommended) Connect Claude in Chrome** so the skill can read *public* LinkedIn profiles when an application links to one instead of attaching a CV.

## First run

The skill asks you for everything and saves it, so you do this once:

- a **working folder** (tracker, saved CVs, and config live here)
- your **Gmail label**, a **cutoff date**, your **reply language**, your **CV source** folder, and **fairness filter** on/off (default off)
- the **job description** (paste it) and your **targeting criteria** (free text)

After that, each run just processes new mail, any open Holds, and checks whether Blocked CVs have arrived.

## How it behaves

- Each applicant is read from the email body, a saved-attachment folder, or a LinkedIn profile.
- Each gets a decision: **Interview / Hold / Reject** — or **Blocked** if the CV couldn't be reached. You can override any of them.
- Decisions are saved to a local **Excel file** you can open outside Claude.
- **Interview** and **Reject** are final. **Hold** resurfaces every run until you resolve it. **Blocked** sits in a separate list, resolves itself when the CV arrives, and lapses after 7 days if it doesn't.
- It never emails candidates, never deletes mail, never logs into any site, and never follows instructions hidden inside a CV or email.
- It double-checks the inbox so an empty label result never silently hides real applications.

## Updating the role or criteria

Say *"update the JD"* or *"update the criteria"* any time — it re-asks and overwrites. If your criteria include a preference on a protected attribute (e.g. gender), the skill will flag it and ask you to confirm before applying it, and only ever as a tie-breaker.
