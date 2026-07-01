# Targeting criteria template

Offer this structure when asking the user for their criteria. It is a starting point, not a form — the user can free-type instead. Save the result as `criteria.md` in the working folder. Keep it plain text so it's easy to read and edit later.

```
MUST-HAVE (a candidate missing one of these should not be Interview)
- e.g. 2+ years office management / admin experience
- e.g. Hebrew (native) + English (professional working)
- e.g. proficiency in <tools the role depends on>
- ...

NICE-TO-HAVE (strengthens a candidate, but not required)
- e.g. experience in a startup / small-team environment
- e.g. bookkeeping or vendor-management exposure
- ...

DEAL-BREAKERS (-> Reject)
- e.g. no relevant experience at all
- e.g. cannot work from <location> / required on-site days not possible
- ...
```

## Fairness — read before saving criteria

Scan the user's criteria for any preference keyed on a **protected attribute** (gender, age, marital/family status, religion, ethnicity, nationality, disability, etc.) — e.g. "prefer women."

If you find one:
- **Warn the user once, clearly:** ranking candidates on a protected attribute is a legal-exposure decision (in many jurisdictions, including Israel, gender preference in hiring is restricted). Ask them to explicitly confirm they want it applied.
- **If confirmed:** apply it *only* as a documented tie-breaker between otherwise-equal candidates — never as a gate, never as something that changes a candidate's bucket — and write a line in that candidate's `Notes` whenever it affected ordering.
- **If not confirmed:** don't apply it. Note in the run summary that the preference is recorded for the user to apply manually.

This keeps the human in control of a policy choice instead of silently encoding it into automated ranking.

## How to apply the rest

- Treat MUST-HAVEs as the spine of the decision: all clearly met -> lean **Interview**; some met with gaps or uncertainty -> **Hold**; a deal-breaker or most must-haves unmet -> **Reject**.
- NICE-TO-HAVEs break ties and add confidence; they don't rescue a missing must-have.
- "Not stated" in a CV is a gap to note, not an automatic disqualifier — flag it rather than assuming the worst.
- If you couldn't read the CV at all, that's **Blocked**, not Reject — the candidate wasn't evaluated, so don't judge them.
- Always give a one-line reason naming what matched and what didn't, so the user can trust or override the call.
