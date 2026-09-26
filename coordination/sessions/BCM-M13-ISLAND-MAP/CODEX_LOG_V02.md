# BCM-M13 Island Map — Codex Remediation Log V02

- Work item: `BCM-M13-ISLAND-MAP`
- Prompt: `CHATGPT_EXECUTION_PROMPT_V02.md`
- Locked criteria: `CHATGPT_AUDIT_CRITERIA_V02.md`
- Prior audit: `CHATGPT_AUDIT_V01.md` (`CHANGES_REQUIRED`)
- Start HEAD: `6e5fa54` (`tasks: record M13 V01 audit blockers and V02 remediation`)
- Branch: `codex/m13-v02-navigation`
- Remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`)
- Status: implementation published; awaiting independent audit

## Sync-first preflight

- Owner checkout: preserved unchanged; detached, dirty, and 63 commits behind fetched `origin/main`.
- Isolated worktree: created from `origin/main` at `6e5fa54`.
- Root `TASKS.md`: read from synchronized checkout and protected from edits.
- `git fetch origin main`: completed before implementation; source was `6e5fa54`.
- `git rev-list --left-right --count HEAD...origin/main`: `0 63` in the owner checkout before isolation.

## Scope

Remediate only M13 V01 blockers: real M12→M13→M12 navigation, exact scroll restoration, and first-entry focus test hardening. M14 gameplay launch/session behavior, M16 production level data, R11 physics, HUD, accepted assets, and `TASKS.md` remain out of scope.

## Changed files

- `scripts/campaign/campaign_navigation_controller.gd` — reusable production M12/M13 router owning one World Map and one Island Map instance.
- `scenes/campaign/CampaignNavigationScene.tscn` — reusable navigation host scene.
- `scripts/campaign/island_map_controller.gd` — exact scroll restoration and independent first-entry focus behavior.
- `tests/m13_island_map_probe.gd` — V02 navigation, restoration, and deliberately-lower-selection focus coverage.
- `coordination/sessions/BCM-M13-ISLAND-MAP/CODEX_LOG_V02.md` — this immutable builder evidence log.

## Implementation summary

- `CampaignNavigationController` consumes the real `WorldMapController.island_map_requested(island_id)` signal, passes the exact island ID into the single reusable `IslandMapScene`, and keeps the same `LevelDatabase` and `CampaignManager` authority.
- Island back navigation returns to the existing World Map instance and captures per-island selected level, focus level, and actual vertical scroll; repeated transitions do not instantiate duplicate map scenes.
- First entry without restoration computes the highest unlocked unfinished level after layout, independent of the campaign manager's lower selected level.
- Re-entry applies the stored, clamped `scroll_vertical` after layout without recentering, while level selection remains a signal boundary only; no gameplay launch was added.

## Builder verification

- `godot_console.exe --headless --editor --path . --import` — exit `0`; normal Godot 4.7.2 import completed.
- `godot_console.exe --headless --path . --script res://tests/m13_island_map_probe.gd` — run 1 exit `0`; `M13_ISLAND_MAP_RESULT=PASS`.
- Same M13 command — run 2 exit `0`; `M13_ISLAND_MAP_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m10_campaign_architecture_probe.gd` — exit `0`; `M10_CAMPAIGN_ARCHITECTURE_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m11_save_migration_progression_probe.gd` — exit `0`; `M11_SAVE_MIGRATION_PROGRESSION_RESULT=PASS`. Expected malformed-save parser diagnostics were emitted by the recovery cases.
- `godot_console.exe --headless --path . --script res://tests/m12_world_map_probe.gd` — exit `0`; `M12_WORLD_MAP_RESULT=PASS`.
- `git diff --check` — passed for the implementation changes.
- `git diff --cached --exit-code -- TASKS.md` — passed before the implementation commit; no tracker diff.

## Evidence against V01 blockers

- Real M12 signal path: PASS in the probe through `WorldMapController.select_island()` and the connected navigation host.
- Exact ID and no duplicate scenes: PASS; one World Map and one Island Map instance across repeated M12↔M13 transitions.
- Exact restoration: PASS for selected level, focus level, and manually changed non-default actual scroll position.
- Focus hardening: PASS with CampaignManager deliberately selected to lower level 2 before first entry while focus resolves to highest unfinished level 6.

## Publication

- Implementation commit: `50f0513b6f3b574b849aed01688b0270e2c77ede` (`fix: wire M13 campaign navigation and scroll restoration`).
- Implementation commit was pushed fast-forward with `git push origin HEAD:main`.
- Final synchronization verification was performed after the evidence-log publication; the exact final SHA equality is reported in the handoff response.

## Limitations and governance

- Godot emitted the existing ignored nested `original_reference/project.godot` warning during import; it did not affect the exit status or probe results.
- No owner/native visual acceptance was performed; these are builder checks only.
- Owner checkout changes were preserved and not copied, reset, stashed, or overwritten.
- `TASKS.md` was not modified. No M14, M16, R11, HUD, or approved asset files were modified.

## Audit boundary

This is builder evidence only. Codex does not update `TASKS.md`, issue the milestone verdict, or perform the independent audit.

## Handoff

`AWAITING_M13_AUDIT_V02`
