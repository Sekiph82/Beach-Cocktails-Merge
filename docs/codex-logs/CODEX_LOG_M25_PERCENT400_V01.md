# BCM-M25-PERCENT400 master execution log

## Scope and repository state

- Prompt: `coordination/sessions/BCM-M25-MASTER-V01/BCM-M25-PERCENT400_MASTER_PROMPT.md`.
- Locked criteria/ruling: `BCM-M25-PERCENT400_AUDIT_CRITERIA_V01.md` and `BCM-M25-PERCENT400_OWNER_RULING.md`.
- Start HEAD: `80ebf4cacbf13d75b08973c25bdd88137c0e76a0`; branch `main`; remote `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Preflight began 0 ahead / 6 behind. The full inventory found seven tracked owner-local paths and fourteen untracked paths; the actual later integrity manifest covers 262 protected files. Incoming prompt/ruling paths were disjoint. Used only a newly named tracked-only safe-sync stash `owner-local-safe-sync-8310775`, fast-forwarded, reapplied without dropping, and kept untracked owner files untouched.
- At task start `TASKS.md` was read-only. During implementation GitHub published the CAL02 audit/log-isolation gate; its changes were read, path-checked, and merged without conflict. The merge changed only `TASKS.md` and added `CHATGPT_M25_CAL02_AUDIT_V01.md`. No Codex edit to `TASKS.md` occurred.
- Protected pretest hash manifest: `evidence/M25-PERCENT400/pretest_protected_hashes.json`. After proof: `protected_hashes_after.json` and `protected_hash_integrity_report.json` (262 files, changed 0, missing 0, new real app_userdata files 0, PASS).

## Implementation and child commits

Four child prompts and logs are published. Product/evidence commits:

1. Child 01 formula audit: `a06e2e817fbf3b54ed6fa06dd45bbfd7a01cf635`.
2. Child 02 runtime move budget: `c507c5c0cab5c19088c43dce5a4136d933235456`.
3. Child 03 move-star progression: `99e746e310b6584ef30ccef36723bec4b9b10410`.
4. Child 04 runtime acceptance evidence: `7eb35fc02a4c41b9012d00cd1b45d25fd294c750`.

Changes derive finite `T_to_go`, enabled `T_vip`, `T_total`, and `4*T` for all canonical levels; expose and enforce the dynamic budget; count committed launches once; use move-only stars; preserve optional VIP normal wins, score records, reward paths, and replay progression; and remove score-based star progress signals. The stale explicit L6 limit was removed. No order targets, physics, timers, spawn distributions, or economy rules were changed.

Formula audit: 100 levels, 25 VIP levels, same-level To-Go/VIP overlap at `[8,24,32,36,56,64,72,76,80,92,96,100]`. L6 = 12/48; L8 = 16/64; L100 = 76/304. Evidence explicitly says VIP remains in inclusive T even when normal To-Go completion ends the level first; normal-first delivery semantics do not double-credit a cocktail.

## Verification evidence

- Godot 4.7.2 clean import: exit 0; 120-frame boot: exit 0. Stdout and exit-code evidence are under `evidence/M25-PERCENT400/final_*`; raw editor logs remain in the disposable sandbox and were not staged.
- Runtime isolation: project copy at `C:\Users\sekip\AppData\Local\Temp\BCM-M25-PERCENT400-20261009-182322`, renamed project identity `BCM-M25-PERCENT400-SANDBOX`, actual Godot user data and file logs observed under the disposable `isolated_appdata` tree. Hash comparison confirms no changes to real protected files.
- M25 property probe: all 100 formulas and all integer boundaries PASS; 4T+1 rejected; last-shot completion precedence; natural MOVES_EXHAUSTED LOSE; Retry reset; score independence and optional VIP assertions.
- Production GL: FULL objective WIN at 43 committed shots; REDUCED objective WIN at 42; FULL and REDUCED MAX_SPREAD natural LOSE at 48 with zero stars; Retry reset and Island Map route pass. Screenshots/results cover 720x1280 and 720x1440.
- M21 mobile GL QA run 01 and run 02: both normal exit 0 and 16 captures each.
- Regressions: M02, M03, M09, M15–M18, M21–M25 and focused M14/M20 passed in final runs. M22 001/002/003 and M23 001/002/003 passed. M20's earlier isolated Retry assertion was debugged read-only; unchanged probe passed on rerun. An early M18 progression assertion used the superseded score-based rule; migrated fixture at T=4 and 300% then passed. Raw histories are retained.
- `git diff --cached --check` was run before every child commit and passed (Git emitted line-ending normalization warnings only).

## Files changed

Product files: `data/campaign/levels/sunny_cove.json`, `scripts/campaign/level_database.gd`, `scripts/campaign/gameplay_session_bridge.gd`, `scripts/game_manager.gd`; tests: `tests/m25_move_limit_probe.gd`, `tests/m14_gameplay_session_bridge_probe.gd`, M18 star/progression probes, M23 score-milestone probes and closeout clone. New child prompts, execution logs, formula/runtime probes, JSON and screenshot/stdout/hash evidence are under the paths above.

## Limits and handoff

- No physical-device QA was performed; simulator/GL evidence is not device acceptance.
- No human-balance claim follows from the mathematical denominator.
- CAL02's previously rotated-away owner diagnostic logs remain missing as disclosed by the independent CAL02 audit; this task's hash verification establishes no additional owner-file changes.
- Final product/evidence commit: `7eb35fc02a4c41b9012d00cd1b45d25fd294c750`. At that verification snapshot, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` matched. Owner-local changes remained present, unstaged, and uncommitted; the canonical checkout is therefore not reported clean.
- `TASKS.md` was not modified by Codex. Do not advance status or begin M26. Stop marker: `AWAITING_GPT_M25_PERCENT400_AUDIT`.
