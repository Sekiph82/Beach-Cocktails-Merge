# BCM-M21-001 + BCM-M21-006 — Codex Execution Log V07-R02

Status: FINAL BUILDER HANDOFF — OWNER F5 ACCEPTANCE PENDING

## Work item and authorization

- Prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07_R02.md`
- Locked criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R02.md`
- Start UTC: 2026-10-03
- Start HEAD: `b11710c353250b982c1f74ae2370adc09eda2c53`
- Branch: `main`
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`

## Sync-first preflight

- `git status --short --branch`: `## main...origin/main`; owner-local `project.godot`, `addons/`, and 14 translation sidecars are present and preserved.
- `git remote -v`: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git` for fetch and push.
- `git fetch origin main`: completed.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
- Start refs: local `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` all equal `b11710c353250b982c1f74ae2370adc09eda2c53`.
- Existing preservation stashes remain: `pre-v07-owner-godot-ai-project-settings` and `pre-v04-owner-local-preserve`.
- Godot version: `4.7.2.stable.official.ed1daf0bf`.

## Scope and execution

Created a new single-scene Sunny Cove image from a blank canvas and froze it before producing geometry. Frozen image SHA-256: `cdd60a2169a8a859a3b412c4cb023bae1da1324272115237e773e522dd48d8d1`. New geometry is a pixel trace inset along the visible tabletop rim; its profile records the same frozen art hash. R02 World Map centers stay within ±0.025 of the V04 seeds and Sunny Cove remains lower-left. The owner-local Godot AI integration and both preservation stashes are excluded from staging. Root `TASKS.md` was read-only to Codex.

## Files changed

- `data/campaign/islands.json` — bind the new Sunny Cove surface/profile and locally calibrate the ten V04 semantic positions.
- `assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface_v07_r02.png` and `.provenance.json` — fresh 720×1280 image and art-first provenance.
- `assets/ui_assets/campaign/islands/sunny_cove/playable_geometry_calibration_v07_r02.json`, `playable_geometry_debug_v07_r02.png`, and `playable_geometry_12_glass_stress_v07_r02.png` — image-derived profile and overlays.
- `tools/calibrate_sunny_cove_geometry_v07_r02.py` — reproducible pixel trace and overlay generation from the frozen image only.
- `tests/m21_owner_f5_remediation_v07_r02_gui_probe.gd` and `tests/m21_owner_f5_remediation_v07_r02_gameplay_probe.gd` — versioned production navigation/input probes.
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/BUILDER_SELF_VISUAL_AUDIT_V07_R02.md/json` and `OWNER_F5_ACCEPTANCE_CHECKLIST_V07_R02.md`.
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v07-r02/` — final full-frame runtime PNGs, `_REVIEW.jpg` copies where PNGs exceed 700 KB, final probe logs, and runtime reports.
- This execution log under `docs/codex-logs/`.

## Commands and exact results

- `git fetch origin main`; `git rev-list --left-right --count HEAD...origin/main` → `0 0` at session start.
- `godot --version` → `4.7.2.stable.official.ed1daf0bf`.
- `godot_console.exe --headless --editor --path . --quit` → project import/class scan completed without parse errors.
- `python tools/calibrate_sunny_cove_geometry_v07_r02.py` → image hash `cdd60a...d8d1`; profile `be5f02...c0e3`; debug overlay `0da249...ba21`; 12-glass illustration `625e75...36ae`.
- GUI production probe → `M21_OWNER_F5_REMEDIATION_V07_R02_GUI_RESULT=PASS clicks=15 captures=6`; final stderr empty.
- Gameplay viewport probe → `M21_OWNER_F5_REMEDIATION_V07_R02_RESULT=PASS mouse=10/10 touch=10/10 drinks=0 effects=0 captures=17`; final stderr empty. It covers the 12-glass state, left/right/rear contacts, untimed behavior, Pause/Resume, WIN/Next/Island Map, and terminal visual counts.
- Persistence regression in an isolated project-name/user-data namespace → `M21_RELEASE_PERSISTENCE_RESULT=PASS`; onboarding, settings, and campaign completion survive shell restart. Owner campaign data was not used.
- Machine audit validation → 21/21 builder visual/process/map checks `PASS`; all ten semantic positions remain within the V04 tolerance.
- For each runtime PNG over 700 KB, a full-frame 720×1280 `_REVIEW.jpg` was created under 500 KB. Fifteen review copies were generated; canonical PNGs remain present.
- `git diff --cached --check` → passed after removing trailing whitespace from the two new Markdown handoff files. `git diff --check` → passed before staging. `git diff --exit-code -- TASKS.md` → passed (unchanged).

## Manual checks and limitations

- Directly inspected the full World Map, Sunny Cove initial/held/10-shot/12-glass/left-right-rear/WIN/pause screenshots. All SC-01..08 and WM-01..10 builder items are PASS in the machine-readable and human-readable audits.
- Production mouse clicks were sent through the viewport on Main Menu, Settings, World Map, Island Map, gameplay, and result actions.
- Physical-device/touchscreen hardware acceptance and owner-native F5 acceptance were not performed; they remain with the owner.
- No release-ready or milestone-completion claim is made.

## Final evidence

Final implementation/evidence commit SHA: `aa04abb89fc10d18ca6b54af69fc99abbdcbb189`. This commit was pushed to `origin/main`; the final log-only commit will follow, then local `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` equality will be verified. Root `TASKS.md` is unmodified. Handoff marker: `AWAITING_OWNER_F5_ACCEPTANCE_V07_R02`.
