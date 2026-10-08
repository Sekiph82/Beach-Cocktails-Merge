# BCM-M22-R01 — Reduced-policy/matrix consistency remediation

Repository: Sekiph82/Beach-Cocktails-Merge; local: C:\Users\sekip\Desktop\Beach Cocktails - Merge

FIRST: safely fetch/sync origin/main non-destructively; inventory/preserve owner-local tracked and untracked files (including two PNGs). No hard reset/clean/force push. Read root TASKS.md, original M22 criteria, and CHATGPT_M22_MILESTONE_AUDIT_V01.md. Codex MUST NOT edit TASKS.md.

## Task
Correct the contradiction in scripts/presentation_effect_policy.gd between REDUCED prose and allowed nonzero dust budgets for merge, vip_delivery, vip_complete. Minimal diff only. Either explicitly say that restrained non-celebratory dust is permitted, or set their budgets to zero, consistently with locked M22-003 REDUCED rules and <=25% FULL. Preserve all other owner-facing semantics.

Extend tests/m22_003_effect_policy_probe.gd with a semantic consistency regression: any reduced style that categorically forbids particles must permit zero spark count across all chain bands. Keep all 16 semantic kinds and 32 mode rows. Regenerate M22_EFFECT_LANGUAGE_MATRIX.md from policy (not manual independent editing). Add proof source and generated matrix match.

Re-run M22-001/002/003 focused probes plus M02/M09/M15/M21 critical regressions, Godot import/boot, forbidden calls/production-disabled scan, git diff --check. Record exit codes, limitations, checksum/parity and logs. Screenshot capture=0 may remain described as unverified visual evidence; do not claim screenshots passed.

Write remediation log docs/codex-logs/CODEX_LOG_M22_R01.md, commit/push ordinary main, verify local HEAD=origin/main=remote main ahead/behind 0/0, preserve owner-local assets. No M23 work, no visual activation, no owner matrix approval claim.

Stop at **AWAITING_GPT_M22_R01_REAUDIT**.
