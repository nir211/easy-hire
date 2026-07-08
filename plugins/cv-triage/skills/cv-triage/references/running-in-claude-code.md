# Running cv-triage in Claude Code

The skill installs and runs in Claude Code just like in Cowork, with two differences.

## 1. Connectors are MCP servers, not built-in toggles

In Cowork/claude.ai, Gmail is a built-in connector. In Claude Code, you give the skill your inbox by adding a **Gmail MCP server** (and a Drive MCP server if you use the attachment auto-save). The filesystem parts — the Excel tracker, the backup script, a local `cvs/incoming/` folder — work natively, since Claude Code has full file and shell access.

## 2. Install

```
/plugin marketplace add nir211/easy-hire
/plugin install cv-triage@easy-hire
```

Connect your Gmail (and optionally Drive) MCP server, then run it interactively:

> Run cv-triage on my applications and give me the digest.

## 3. Schedule it — the safe, in-session way

Claude Code has a built-in `/loop` skill that re-runs a prompt on a cadence **while your session is open**:

```
/loop 1d run cv-triage on my applications and give me the digest
```

That fires the triage once a day for as long as the session stays open, and stops when you close it. This is the recommended way to schedule the skill, and the one this project supports, because it keeps you present: the agent only reads your inbox while you're there, nothing runs unattended, and you don't have to pre-authorize any tools.

> **On purpose, this project does not document an unattended/headless schedule.** Claude Code *can* be driven by an OS cron in headless mode with pre-approved tools, but that means an agent touching your mailbox with no human watching, and it requires loosening permission prompts. If you decide to go that route, follow Claude Code's own automation documentation and scope tools tightly — it is outside what this project recommends or supports.
