# BCM-M21-001 + BCM-M21-004 + BCM-M21-006 — Final Owner Runtime Closure V02

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `OWNER_RULING_V01.md`
5. `OWNER_RUNTIME_AUDIT_V01.md`
6. `CHATGPT_AUDIT_CRITERIA_V01.md`
7. `CODEX_LOG_OWNER_RUNTIME_REMEDIATION_V01.md`
8. `CHATGPT_FINAL_OWNER_RUNTIME_CLOSURE_CRITERIA_V02.md`

Current recovery handoff:
`814198440dc5c13792087b351a151241bd2664a5`

## One combined job

Close the remaining active M21 tasks in one bounded batch:

- **BCM-M21-001** — final runtime/mobile-layout/touch/input validation;
- **BCM-M21-004** — final accepted gameplay regression after owner no-timer ruling;
- **BCM-M21-006** — final owner-runtime handoff and release-closure gate.

### Step 1 — verify current recovery

Re-run the locked technical checks on current `main`.

Verify all of these from production paths:
- mouse 10/10;
- touch 10/10;
- direct launch calls 0;
- no timer / no timeout after simulated hour;
- no production +Time grant/advertising;
- correct Sunny Cove five-layer theme;
- old board only fallback;
- R11 geometry unchanged;
- ten World Map hotspots centered on baked islands;
- no duplicate island art;
- 486×864 debug override over 720×1280 viewport.

### Step 2 — conditional remediation

If any check above fails, fix that exact failure now in this same batch.

Do not wait for another prompt for a technical defect already visible in current source/evidence.

After any fix:
- rerun affected focused tests;
- rerun the locked final regression set;
- regenerate only affected evidence;
- preserve historical evidence.

Do not change normal To-Go objectives, merge physics, drink radii, R11 rails/contact coordinates, scoring, unrelated economy, or accepted save/progression.

### Step 3 — audit-readable evidence

Ensure World Map and Sunny Cove gameplay evidence can be independently inspected.

If original PNG transport size prevents review, add same-dimension compressed review derivatives with provenance. No crop, resize, retouch or content edits.

### Step 4 — owner handoff

Create:
`OWNER_F5_ACCEPTANCE_CHECKLIST_V02.md`

and:
`CODEX_LOG_FINAL_OWNER_RUNTIME_CLOSURE_V02.md`

The checklist must contain the 10 owner F5 steps from the locked criteria and must leave PASS/FAIL blank for the owner.

Do not fill in owner acceptance yourself.

## Hard rules

- Do not edit root `TASKS.md`.
- Do not reintroduce any timer.
- Do not reintroduce +Time.
- Do not invent replacement rewards.
- Do not start a new milestone.
- Do not claim release-ready.

If technical re-verification is clean, finish exactly:

`AWAITING_OWNER_F5_ACCEPTANCE_V02`

If a technical blocker remains:

`CHANGES_REQUIRED_OWNER_RUNTIME_V02`
