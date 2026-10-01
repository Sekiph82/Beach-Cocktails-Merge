# BCM-M21-001 + BCM-M21-004 + BCM-M21-006 — Final Owner Runtime Closure V02-R01

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

This is one combined prompt: **sync recovery + all remaining M21 work**.

## 0 — resolve the current sync blocker without deleting owner/generated files

You previously stopped because local `main` was at:

`814198440dc5c13792087b351a151241bd2664a5`

while `origin/main` was ahead, and the checkout contained 14 untracked Godot `.translation` binaries identified as generated `OptimizedTranslation` resources.

**Do not delete them.**

Do this first:

1. `git fetch origin main`
2. list the exact 14 untracked `.translation` paths;
3. verify they are untracked, unstaged generated files;
4. run `git diff --name-only HEAD..origin/main`;
5. prove none of those 14 paths appears in the incoming tracked diff;
6. prove there are no other unexpected local modifications/files;
7. if useful, add only those exact paths to local-only `.git/info/exclude`;
8. fast-forward with `git merge --ff-only origin/main`;
9. verify local HEAD = origin/main = `git ls-remote` main.

Untracked generated files do **not** block fast-forward when there is no path collision.

If any collision exists, STOP without deleting anything.

## 1 — read after sync

Read:

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `OWNER_RULING_V01.md`
5. `OWNER_RUNTIME_AUDIT_V01.md`
6. `CHATGPT_AUDIT_CRITERIA_V01.md`
7. `CODEX_LOG_OWNER_RUNTIME_REMEDIATION_V01.md`
8. `CHATGPT_FINAL_OWNER_RUNTIME_CLOSURE_CRITERIA_V02.md`
9. `CHATGPT_FINAL_OWNER_RUNTIME_CLOSURE_CRITERIA_V02_R01.md`

## 2 — execute all remaining tasks in this same prompt

Active tasks:

- **BCM-M21-001**
- **BCM-M21-004**
- **BCM-M21-006**

Re-verify current owner-runtime recovery:

- real mouse launch 10/10;
- real touch launch 10/10;
- direct ShotController launch calls 0;
- no countdown / TIME UP;
- one simulated hour cannot timeout;
- no production +Time grant or advertising;
- correct Sunny Cove five-layer campaign theme;
- old fixed board only as fallback;
- accepted R11 geometry unchanged;
- ten World Map hotspots centered on the baked islands;
- no duplicate island thumbnails;
- 486×864 desktop debug override over canonical 720×1280.

If any technical criterion fails, remediate that exact failure **inside this same batch**, then rerun affected checks plus the locked final regression set.

Do not ask for another remediation prompt for a technical defect already found here.

## 3 — final regression

Run the release-relevant regression set locked in V02:

- M02
- R11
- M03
- M07-R06
- M08
- M09
- updated untimed M14
- updated M15 with retired +Time
- updated M16
- M18
- M19
- M20
- M21 progression 100/100
- M21 performance
- `git diff --check`

## 4 — owner handoff

Create/update:

- `OWNER_F5_ACCEPTANCE_CHECKLIST_V02.md`
- `CODEX_LOG_FINAL_OWNER_RUNTIME_CLOSURE_V02.md`

Owner checklist must leave PASS/FAIL blank.

Do not edit root `TASKS.md`.

Do not claim release-ready.

If technically clean, finish exactly:

`AWAITING_OWNER_F5_ACCEPTANCE_V02`

If a blocker remains:

`CHANGES_REQUIRED_OWNER_RUNTIME_V02`
