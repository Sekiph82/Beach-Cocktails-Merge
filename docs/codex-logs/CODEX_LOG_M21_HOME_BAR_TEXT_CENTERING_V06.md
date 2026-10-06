# Codex Execution Log — BCM-M21 Home Bar Text Centering V06

## Start record

- Owner direction (2026-10-06): center the writing inside the intended inner surfaces of the Home bars.
- This later direct owner instruction authorizes changing only the four Home dynamic-text rectangles (Level, Energy, Coin, Diamond), which extends the older R05 freeze on those values. Bar art, widths, positions, add icons, navigation, gameplay, and assets remain untouched.
- Starting HEAD: `7a8647ba4ceba853f53ddc415e74f05fee465aeb`; branch `main`, remote `origin`.
- Sync preflight: canonical `origin` confirmed; after `git fetch origin main`, HEAD and origin/main matched (`0/0`). Owner-local `project.godot` and two untracked annotated screenshots were present and preserved. Root `TASKS.md` was read and left unchanged.
- Read synchronized `AGENTS.md`, `TASKS.md`, current R05 prompt/criteria/ruling, current layout, and Home probe.

## Execution record

- Centered Level `12` on the badge face, Energy `100` on the inner track between lightning and plus, Coin `4.250` in the open numeric region between coin medallion and plus, and Diamond `85` between gem and plus.
- Left-aligned text rectangles' centers are now Level `(47.5,47)`, Energy `(292,55.5)`, Coin `(510.75,54.5)`, Diamond `(738,54)` in 941x1672 reference space. Label nodes already use horizontal and vertical center alignment.
- Only `HOME_TARGET_LAYOUT_R04.json`, V06 captures/parity metadata, and this log are in scope. No source PNGs or Home art rectangles changed.
- Production capture hash: `9f1214104b3ed848890563142415d3b6aeb0cc979d9f2c001c38dfea4e5e0330`; evidence manifest: `evidence/owner-critique-v06/HOME_BAR_TEXT_CENTERING_V06.json`.
- Reviewed the 941x1672 render; all four readouts are visually centered in their intended inner faces, with the plus controls clear of the Coin and Diamond values.

## Verification

- Focused Home production probe was run with temporary V06 alignment assertions: `godot_console.exe --path . --script res://tests/m21_home_exact_target_r04_probe.gd` — exit 0; `M21_HOME_R04_RESULT=PASS`. This covered the four centers, current text values, and real Play/World Map/Settings navigation and generated the six listed captures. The temporary assertion edits were reverted; the R04 probe itself is not part of this change.
- `python -m json.tool` on `HOME_TARGET_LAYOUT_R04.json` and `HOME_BAR_TEXT_CENTERING_V06.json` — PASS. `git diff --check` — PASS; `git diff --exit-code HEAD -- TASKS.md` — PASS.
- Full pixel parity to the original TARGET remains unverified. No independent audit or owner approval is claimed.
- No owner approval or independent audit is claimed.
