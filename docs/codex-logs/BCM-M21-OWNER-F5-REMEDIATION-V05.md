# CODEX Execution Log — BCM-M21 Owner F5 Remediation V05

Status: **TECHNICAL WORK COMPLETE — OWNER F5 ACCEPTANCE PENDING**

Active tasks: BCM-M21-001, BCM-M21-006. BCM-M21-004 remains closed; no gameplay regression was discovered.
Prompt: `CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V05.md`
Branch: `main`
Remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`)
Godot runtime: `4.7.2.stable.official.ed1daf0bf`, Compatibility renderer.

## Sync preflight and preserved work

- Starting V05 HEAD: `a9c45764883340d3a977c42d23f238b862656c4e`.
- Pre-sync divergence before V05 contract review: local ahead `0`, behind `7`; fetched `origin/main`, inspected the incoming paths, and fast-forwarded safely to `a9c45764883340d3a977c42d23f238b862656c4e`.
- Post-sync starting `HEAD` and `origin/main` matched at `a9c45764883340d3a977c42d23f238b862656c4e`.
- Tracked files were clean before edits. The 14 existing untracked `.translation` sidecars were left untouched.
- Existing `stash@{0}` named `pre-v04-owner-local-preserve` remains retained.
- Root `TASKS.md` was read only. It has not been modified.

## Implementation and evidence

- `scripts/campaign/campaign_navigation_controller.gd`: result CanvasLayer now starts hidden; its full-screen root is permanently `MOUSE_FILTER_IGNORE`; the layer is activated immediately before a ready result card is shown; result feedback, CanvasLayer and stale pending payload are hidden/cleared on World Map, Island Map, Retry, Next Level, dismissal, and CampaignNavigation hiding. `visibility_changed` synchronizes the layer and retries presentation only when navigation becomes visible.
- `tests/m21_owner_f5_remediation_v05_gui_probe.gd`: added a production-shell GUI smoke. It creates test-only onboarding/settings files and switches to in-memory campaign state after shell startup so the GUI smoke does not write the owner's campaign save. It dispatches mouse press/release events using `Viewport.push_input(event, true)` at visible production Controls' viewport centers. No Main Menu or result transition is invoked through the prohibited direct helper methods.
- Six required 720×1280 screenshots and a JSON report are under `evidence/runtime/v05/`. The probe executed 15 real GUI clicks across Main Menu, World Map, Settings, Sunny Cove, Level 1, Next Level, result Island Map, and re-entry after the result.
- Added `OWNER_F5_ACCEPTANCE_CHECKLIST_V05.md`; owner fields remain blank and owner-native review remains pending.

## Commands and exact results

- Required sync: `git status --short --branch`; `git remote -v`; `git fetch origin main`; `git rev-list --left-right --count HEAD...origin/main`. Safe fast-forward to the seven fetched commits; no reset, rebase, force-push or stash was used for synchronization.
- V05 production GUI run: `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m21_owner_f5_remediation_v05_gui_probe.gd` — exit 0; `M21_OWNER_F5_REMEDIATION_V05_GUI_RESULT=PASS clicks=15 captures=6`; zero `ERROR:` / `SCRIPT ERROR:` lines. The first harness iteration used the wrong coordinate-space flag and failed; after setting `in_local_coords=true`, the final recorded run passed.
- An intermediate harness iteration passed the required result Next Level transition but did not reliably open the gameplay pause overlay for the extra return-to-menu route. The final probe uses a second production WIN followed by a real GUI click on the result card's Island Map action, then real Island Map and World Map Back clicks. All those transitions and the required post-result menu clicks pass in the final run.
- V04 regression: `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m21_owner_f5_remediation_v04_probe.gd` — exit 0; `M21_OWNER_F5_REMEDIATION_V04_RESULT=PASS mouse=10/10 touch=10/10 drinks=0 effects=0 captures=10`; zero `ERROR:` / `SCRIPT ERROR:` lines. Confirms map/layout, +150 table geometry, untimed one-hour survival, real mouse/touch input, and WIN → Next → WIN → Island Map → LOSE → Retry behavior.
- Settings persistence: `godot_console.exe --headless --path . --script res://tests/m20_settings_probe.gd` — exit 0; `M20_CHILD_03_RESULT=PASS`. Its deliberately malformed JSON fixture logs the expected parser diagnostic while confirming safe-default recovery; this is separate from the V05/V04 runtime streams.
- Save/restart persistence: `godot_console.exe --headless --path . --script res://tests/m21_release_persistence_probe.gd` — exit 0; `M21_RELEASE_PERSISTENCE_RESULT=PASS`.
- Godot parse/import: `godot_console.exe --headless --editor --path . --quit` — exit 0.
- `git diff --check` — exit 0 (Git may report line-ending advisory warnings).
- Save-preservation procedure: exact copies of existing `campaign_save.json`, `campaign_save.json.bak`, and `save.cfg` were stored outside Desktop before the V04 and M21 persistence runs and copied back afterward. V04 generated evidence files were also copied aside and restored byte-for-byte after its regression run. Backup copies remain outside the repository under `%TEMP%`.

## Manual checks and limitations

- Inspected the required V05 Main Menu, World Map, and WIN captures. The GUI log records the remaining capture checks and exact click targets.
- Zero red runtime errors were observed in the combined V05 menu/result flow and V04 runtime regression.
- Physical-device behavior, owner-native F5 acceptance, and owner visual acceptance have not been performed. They remain pending; no release-ready or acceptance verdict is claimed.
- The in-memory V05 objective deliveries exercise the production campaign bridge's terminal result path; owner gameplay feel and mouse/touch launch behavior are covered by the V04 regression, not inferred from those delivery fixtures.

## Files changed

- `scripts/campaign/campaign_navigation_controller.gd`
- `tests/m21_owner_f5_remediation_v05_gui_probe.gd`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_ACCEPTANCE_CHECKLIST_V05.md`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CODEX_LOG_OWNER_F5_REMEDIATION_V05.md`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v05/` (six screenshots, JSON report, and runtime/parse/regression logs)
- `docs/codex-logs/BCM-M21-OWNER-F5-REMEDIATION-V05.md`

## Final repository state

- Start HEAD: `a9c45764883340d3a977c42d23f238b862656c4e`.
- End HEAD: pending V05 commit.
- V05 commit SHA: pending publication.
- Required final equality: local `HEAD` = `origin/main` = `git ls-remote origin refs/heads/main`; pending push and verification.
- `TASKS.md` was not modified. The 14 `.translation` sidecars remain untracked and untouched. The existing preservation stash remains retained.
- Verified `git hash-object TASKS.md` equals `git rev-parse HEAD:TASKS.md` (`18fbdddd6fcd8d1b9b13069cbe6c1e54a079ea5e`) before V05 commit preparation.

Technical handoff marker: `AWAITING_OWNER_F5_ACCEPTANCE_V05`
