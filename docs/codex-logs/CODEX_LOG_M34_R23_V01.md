# Codex Execution Log — BCM-M34-R23 V01

## Work item and authority

- Work item: `BCM-M34-004` screening and provenance remediation, prompt `CHATGPT_M34_R23_SCREENING_PROVENANCE_MASTER_PROMPT.md`.
- Session: `BCM-M34-END-TO-END-GAME-COMPLETION-V01`.
- Branch / remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge`).
- Start HEAD after required sync: `66d1a7e7e6980ef3b30e7f9a527e24ff0d4af5be`.
- End HEAD for implementation/evidence: `1b35b2215db4c4002eb80610478b2c3aefdb406f` (full SHA verified in Git immediately after commit).

## Sync-first preflight and owner preservation

The mandatory commands ran from the canonical repository root. Before fetch, local `main` was behind-only by three commits (`HEAD...origin/main = 0 3`) at `04ca364`. The eight dirty tracked owner paths were inventoried, and incoming changed paths were confirmed disjoint. A tracked-only stash named `owner-local-safe-sync-04ca364` was created without untracked files, `main` fast-forwarded to `66d1a7e7e6980ef3b30e7f9a527e24ff0d4af5be`, and the stash was applied. No owner work was staged or discarded.

The R23 preflight hash inventory contains 205 pre-existing owner paths. The post-work comparison found 0 missing or changed paths. `TASKS.md` blob remained `ce2653637a053cc6f760979feeac85c6712c0903` before and after. The safe-sync stash remains available and was not dropped.

## Implementation and evidence

- Added the R23 screening runner, trace-integrity audit, and autonomous trial probe under `tools/campaign/`.
- Added the R23 regression harness under `tests/`.
- Added immutable R23 qualification, attempt, mismatch-probe, and regression evidence under `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R23/`.
- Runner verifies canonical VIP metadata against the case record before gameplay and fails closed on disagreement. Normal objective T progress and the 4T limit remain authoritative; optional VIP is not required.
- The trial trace is written to one `final_trace.json` path throughout execution; no parallel live/final trace file is created. The R23 audit checks immutable hashes, trial pair uniqueness, lane parity, VIP provenance, cohort coverage, and wall time.
- The deliberate negative VIP probe used Sunny Cove level 4 with canonical `vip.enabled=true` and runner case `false`; it exited 3 with `ERROR/VIP_PROVENANCE_MISMATCH` before gameplay.
- Two early zero-trial starts closed as `PREFLIGHT_ERROR` on empty-cohort aggregation. They are retained as failed attempts. The corrected pilot subsequently ran. A reserve-budget zero-trial partial attempt is also retained.

## Pilot result and qualification boundary

Main attempt: `20261016T151348575Z_e27593b3f58942ee9a09a7dd8f2ea416`.

- 22/22 unique trials completed; 22 unique levels across all 10 islands.
- Outcomes: 9 `WIN_OBSERVED`, 13 `BUDGET_UNKNOWN`, 0 `LOSS_OBSERVED`, 0 `ERROR`.
- 9 distinct winning levels across 9 islands; all 10 islands received an early-band trial.
- 0 selected/requested/fired lane parity mismatches; 0 VIP metadata mismatches.
- Per-level trials remained under the 120-second timeout. Normal objectives were evaluated under the 4T cap.
- Trace-integrity audit: `TRACE_INTEGRITY_PASS_WITH_GLOBAL_WALL_BUDGET_OVERRUN`.
- Manifest start/end timestamps yield 2,210 seconds, exceeding the 2,100-second global ceiling by 110 seconds. The runner-reported stopwatch was 2,055.659 seconds because resume reset its timer; manifest timestamps are authoritative. This is a failed R23 qualification condition. No further game trials were run after the bounded cohort closed; no 1,000-level expansion is authorized.
- Runtime/evidence storage estimate for 1,000 levels is a naive extrapolation only and is not a completion claim.

The full R23 evidence tree measured 72,264,326 bytes at the manifest/owner-integrity check, below the 262,144,000-byte cap. Regression isolated AppData occupied 3,403,668 bytes. Regression disk free space was 78,597,808,128 bytes before and 78,560,243,712 bytes after (delta -37,564,416 bytes).

## Validation commands and exact results

- `git -c core.whitespace=cr-at-eol diff --cached --check`: passed (retained JSON/process evidence uses CRLF line endings).`r`n- PowerShell parser check for `m34_r23_screening_pilot.ps1`, `m34_r23_audit_pilot.ps1`, and `m34_r23_regression_suite.ps1`: 0 parse errors each.
- R23 VIP mismatch probe: exit 3; classification `ERROR`; reason `VIP_PROVENANCE_MISMATCH`; canonical true / runner false.
- R23 trace audit: 22/22 trial start/finish records, 22 distinct levels, 9 wins, 10 islands, 0 lane parity mismatch, 0 VIP mismatch; status explicitly records the 110-second global wall-budget overrun.
- Fresh Godot editor import (`godot --headless --editor --path . --quit`): exit 0. Godot emitted a warning for `WorldMapScene.tscn` UID `uid://kf3xtrckwhbr`, falling back to the text path; this warning remains visible in retained import evidence.
- Regression suite: `ALL_REQUESTED_REGRESSIONS_PASS`, 10/10 probes passed: economy, daily rewards, campaign navigation, M14 bridge, M15 VIP economy, production routes, scene UID, slim content, VIP optionality, startup smoke.
- Owner-file integrity: 205/205 prior owner paths match their original SHA-256 and lengths; `TASKS.md` unchanged.
- Manifest integrity: 5 attempt starts paired with 5 finishes; 22/22 main trial starts paired with finishes; no duplicate event IDs or final trace paths; retained R23 traces use the single final-trace path.
- Manual GUI/phone acceptance was not performed; this was an autonomous headless qualification task.

## Changed paths

Task-owned paths are only the following; all are explicitly staged for this task:

- `tools/campaign/m34_r23_screening_pilot.ps1`
- `tools/campaign/m34_r23_audit_pilot.ps1`
- `tools/campaign/m34_r23_autonomous_trial.gd`
- `tests/m34_r23_regression_suite.ps1`
- `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R23/`
- `docs/codex-logs/CODEX_LOG_M34_R23_V01.md`

No root `TASKS.md`, prior R19-R22 evidence, or owner-local tracked paths were changed by this task.

## Known limitations and disposition

The R23 pilot does not qualify under its global time ceiling because actual manifest wall time exceeded the limit by 110 seconds. The per-attempt timer reset on resume is defective and must be corrected before any new bounded cohort. Outcomes marked `BUDGET_UNKNOWN` are inconclusive and do not mean the levels are impossible. No owner GUI/phone check was performed. The editor import UID warning was not suppressed or treated as acceptance. This log is builder evidence, not an independent audit or tracker transition.

## Publication and stop marker

- Implementation/evidence commit SHA: `1b35b2215db4c4002eb80610478b2c3aefdb406f` (abbreviated here; full SHA is the first task commit).
- Final repository state: pushed to `origin/main`; local HEAD, `origin/main`, and remote `main` were verified equal after publication. The log is a subsequent log-only commit.
- Required stop marker: `AWAITING_GPT_M34_R23_INDEPENDENT_AUDIT`.

`TASKS.md` was not modified.
