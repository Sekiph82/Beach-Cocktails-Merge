# BCM-M00-001 — Repository Sync and Baseline V01

Execute only the authoritative work order below.

## Authoritative work order

Local file:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge\docs\prompts\BCM-M00-001.md`

GitHub:
https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/docs/prompts/BCM-M00-001.md

Before execution, also read:

- Local: `C:\Users\sekip\Desktop\Beach Cocktails - Merge\AGENTS.md`
  GitHub: https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/AGENTS.md

- Local: `C:\Users\sekip\Desktop\Beach Cocktails - Merge\TASKS.md`
  GitHub: https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/TASKS.md

## Mandatory tracker rule

Codex must never edit:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge\TASKS.md`

Codex must not self-audit for acceptance, mark tasks complete, advance milestones, or alter project status. Codex produces implementation/synchronization evidence only.

After Codex pushes the required immutable log, ChatGPT will independently audit GitHub repository truth and the Codex log. Only ChatGPT may update `TASKS.md` after that audit.

## Required output log

Local path:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge\docs\codex-logs\BCM-M00-001_REPOSITORY_SYNC_AND_BASELINE_V01_CODEX_LOG.md`

GitHub URL after push:
https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/docs/codex-logs/BCM-M00-001_REPOSITORY_SYNC_AND_BASELINE_V01_CODEX_LOG.md

Safely synchronize the local project with GitHub `main`, preserve owner work, commit and push the reconciled baseline, verify local HEAD / `origin/main` / remote `main` equality, write and push the required log, and then STOP for independent ChatGPT audit. Do not begin BCM-M00-002 or Godot v7 integration.
