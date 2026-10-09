# CODEX LOG — BCM-M25-R02

- Work item / prompt: `BCM-M25-R02_TERMINAL_ROUTE_MASTER_PROMPT.md`
- Locked criteria: `BCM-M25-R02_AUDIT_CRITERIA_V01.md`
- Start HEAD: `a5441c4ae1a3e2e794ad50a4b7325f8b90039c5a`
- Branch / remote: `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`
- Sync preflight: local `main` fast-forwarded to `origin/main` before task read; ahead/behind `0/0`. Tracked-only preservation stash `owner-local-safe-sync-3f2949d` was created and reapplied without dropping. No owner changes staged.
- Start state: seven tracked owner-local diffs, owner-local untracked files, and isolated task evidence inventoried in `pre_probe_integrity_snapshot.json`.
- Isolated task APPDATA: `C:\Users\sekip\AppData\Local\Temp\BCM-M25-R02-20261009-064109\APPDATA`.
- Isolated regression APPDATA: `C:\Users\sekip\AppData\Local\Temp\BCM-M25-R02-20261009-064109\APPDATA_REGRESSION`.

## Files changed for R02

- `coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-R02/` — probe runner, per-scenario screenshots/state/log/exit results, integrity snapshot, regression/runtime outputs, native-input diagnostic, and validation summary.
- `docs/codex-logs/CODEX_LOG_M25_R02.md` — this execution record.
- No production gameplay/UI source was changed. The probe runner's stdout label was corrected from `M25_R01_REAL_INPUT_RESULT` to `M25_R02_REAL_INPUT_RESULT`.
- `project.godot` was not staged or committed. Godot/editor newline normalization changed its bytes during probes; it was restored byte-for-byte to its pre-probe SHA-256 from the retained safe-sync stash and snapshot. Final hash matches `pre_probe_integrity_snapshot.json`.

## Results against locked criteria

1. **Natural FULL and REDUCED LOSE:** not achieved. Five real gameplay runs expected to explore loss all reached genuine WIN: FULL Level 1 at scores 3,244; 725; and 1,101; FULL Level 6 at 5,083; REDUCED Level 7 at 2,454. These are failed attempts to obtain LOSE, not evidence of loss unreachability. No fail-state result, fail semantic, or fail-effect absence was established. Criteria remain UNVERIFIED.
2. **Genuine one-/two-star WIN:** not achieved. Production Island Map selection of Sunny Cove Level 4 followed by real gameplay yielded 3-star WINs at 3,831 and 3,540. No score/star/result mutation was used. No structural impossibility proof was established. Criteria remain UNVERIFIED.
3. **Results pointer/touch routes:** a correctly transformed fixture mouse event activated Island Map exactly once and routed successfully (`FULL_WIN_SCALED_ISLAND_MAP`). The raw viewport coordinate was mis-scaled and could activate Next Level; the resulting discrepancy was in the runner coordinate conversion, not evidence of a production hitbox defect. Touch `InputEventScreenTouch` routed Island Map once at rendered 720x1280 and 720x1440 (`FULL_WIN_TOUCH_720x1280`, `FULL_WIN_TOUCH_720x1440`). Native mouse remains UNVERIFIED: Windows did not grant/confirm foreground focus (`foreground_verified=false`), so the guard sent no mouse down/up. Results Retry was not exercised. No production input/navigation defect was demonstrated.
4. **Isolation, preservation, regressions/runtime:** isolated task and regression APPDATA were used. Four owner save files, seven tracked owner-local files, R01 evidence, prompt/criteria, AGENTS, and root `TASKS.md` match their pre-probe snapshot hashes after restoring `project.godot` bytes. Root `TASKS.md` is unchanged. Focused M25 Results presentation probe: exit 0, 22 checks. Previous 11 regression probes (M21 persistence; M22-001/002/003; M23-001/002/003/color restoration; M24-001/002/003) passed with exit 0 on rerun. Initial persistence attempt used a reused profile and failed; the isolated fresh-profile rerun passed. Initial M22-M24 runner attempts used an incorrect nested output path; corrected-path rerun passed. M21 real GL mobile QA ran twice, both exit 0. Godot headless editor import exit 0; 120-frame boot exit 0. No manual owner-device/native mouse acceptance was completed.
5. **Evidence and stop:** per-run evidence is retained under `evidence/M25-R02/`; no self-acceptance or tracker change. No M26 work started.

## Pointer calibration finding

The R02 game window used a logical viewport of 800x1422 while the captured rendered image was 720x1280 (0.9 rendered/logical scale). Fixture events must map screenshot coordinates into viewport coordinates. The corrected Island Map event center was approximately `[400, 962.07]` for rendered center `[360, 866]`. At 720x1440, the logical viewport was 800x1600 and touch mapping used the same rendered-to-viewport ratio. Correctly transformed GUI fixture input succeeded; raw centers sometimes activated Next Level. Native OS input is not claimed.

## Commands / exact results

- Mandatory sync sequence: `git status --short --branch`; `git remote -v`; `git fetch origin main`; `git rev-list --left-right --count HEAD...origin/main` — synchronized at start, `0/0` after fast-forward.
- Godot editor import: `godot_console --headless --editor --path . --quit` — exit `0`.
- Godot boot: `godot_console --path . --quit-after 120` — exit `0`.
- Focused M25 Results presentation probe — exit `0`, 22 checks.
- M21 GL mobile QA runs 01 and 02 — exit `0` each.
- Regression rerun matrix — 11/11 exit `0`; see `regression/runs/headless_regression_rerun_results.json` and individual logs.
- All gameplay scenario process exit records and screenshots are retained per scenario. Outcomes are recorded in each `result_metadata.json` and stdout file.
- `git diff --check` and `git diff --cached --check`: exit `0` before evidence commit.

## Preservation / limits

- Owner campaign save files and all pre-probe protected hashes: match.
- `TASKS.md`: SHA-256 unchanged (`8B66C447F2D3361FD2BDD6EA36DCA415F7F7C28061137B7C0E455911140F338C`); never edited.
- Seven tracked owner-local files, including `project.godot`, remain unstaged and outside the R02 publication commit. Owner-local untracked files remain untouched.
- No production code fix was indicated by current evidence.
- Native mouse, Results Retry, natural FULL/REDUCED LOSE, one-/two-star WIN, owner-device acceptance, and independent audit remain open/unverified.

## Publication

- R02 evidence bundle commit SHA: `11b35092a6096eb5d25dbf0e26dcb08fb29e2da0`.
- After evidence push, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `11b35092a6096eb5d25dbf0e26dcb08fb29e2da0`; ahead/behind `0/0`. This log finalization is a separate follow-up commit; final branch parity is rechecked after that push.
- Required stop marker: `AWAITING_GPT_M25_R02_REAUDIT`.
