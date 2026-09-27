# BCM-M15 Combined To-Go + VIP HUD Integration — CODEX Log V05

Status: `IMPLEMENTATION_COMPLETE / AWAITING_M15_AUDIT_V05`

## Work item and authority

- Work item: `BCM-M15-VIP-BOOSTERS-ECONOMY V05`.
- Prompt: `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_EXECUTION_PROMPT_V05.md`.
- Locked criteria: `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V05.md`.
- Owner ruling: `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V05.md`.
- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

## Synchronization preflight

- `git status --short --branch`: clean `main...origin/main`.
- `git remote -v`: `origin` fetch/push `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- `git fetch origin main`: completed successfully.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
- Start HEAD: `a03f659695902f6b04f88238c38aeb4bdeac9cf8`.
- No fast-forward was required.
- No reset, clean, stash, rebase, destructive checkout, force-push, branch creation, or Desktop clone/worktree was used.

## Scope at start

Product scope was limited to the owner-approved combined `panel_to_go_vip_orders.png` HUD frame, dynamic normal/VIP recess content, shared cocktail sizing policy, non-VIP `0/0` presentation, the focused M15 probe, and required M07 layout-fixture compatibility. Root `TASKS.md`, the approved PNG, gameplay/economy semantics, M16 content, and R11 geometry remained protected.

## Implementation summary

- Replaced the active standalone To-Go frame plus procedural V04 VIP card with the single canonical combined HUD master.
- Kept the reference display width at `210 * ui_scale` and derived height from the approved `1132x755` source aspect ratio.
- Added dynamic normal cocktail, authoritative normal progress, and normal reward content in the upper recesses.
- Added dynamic VIP cocktail, progress/checkmark, and doubled reward content in the lower recesses; static VIP/coin/2X art remains supplied by the approved PNG.
- Kept the lower VIP board visible on non-VIP levels with hidden cocktail, exact `0/0`, and blank reward.
- Centralized both cocktail slots on the same `_to_go_cocktail_scale()` helper and max-footprint constant.
- Preserved M15 gameplay/economy/session behavior, normal reward authority, VIP 2x payout, quantity ledger, same-level precedence, terminal rewards, campaign progression, and R11 geometry.
- Updated the M15 focused probe and the existing M07 composition/layout fixtures to the new canonical panel geometry. No M16 work was started.

## Changed files

Product/test source and layout fixture changes:

- `scripts/game_manager.gd`
- `tests/m15_vip_boosters_economy_probe.gd`
- `tests/m07_hud_composition_probe.gd`
- `tests/m07_hud_inner_boxes.gd`
- `tests/m07_r06_owner_layout_probe.gd`
- `docs/evidence/m07/independent_inner_content_layout_v02.json`

Builder evidence:

- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v05/normal_vip_pending.png`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v05/normal_vip_partial.png`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v05/normal_vip_completed.png`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v05/non_vip_0_of_0.png`
- Updated M07 regression captures under `docs/evidence/m07/` and `docs/evidence/m07_r08/`.
- This immutable log.

No product asset was regenerated or modified. `assets/ui/panel_to_go_vip_orders.png` remains byte-for-byte owner-approved.

## Builder verification

- `godot_console.exe --headless --editor --path . --import` — exit `0`; Godot `4.7.2`; existing ignored `original_reference/project.godot` warning only.
- `godot_console.exe --headless --path . --script res://tests/m15_vip_boosters_economy_probe.gd` — final run 1 exit `0`; `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS`.
- Same M15 headless command — final run 2 exit `0`; `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS` with no intervening file changes.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m15_vip_boosters_economy_probe.gd` — exit `0`; OpenGL Compatibility on Intel Iris Xe; all four captures saved.
- `godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd` — exit `0`; `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m08_to_go_delivery_probe.gd` — exit `0`; `M08_TO_GO_DELIVERY_RESULT=PASS`. Existing headless null-viewport `save_png` diagnostics were emitted by the probe capture helper and were non-fatal.
- `godot_console.exe --headless --path . --script res://tests/m03_economy_regression.gd` — exit `0`; `M03_PROBE_RESULT=PASS`.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m07_hud_composition_probe.gd` — exit `0`; `M07_PROBE_RESULT=PASS` across 720x1280, 720x1440, and 800x1280.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m07_r06_owner_layout_probe.gd` — exit `0`; `M07_R06_PROBE_RESULT=PASS` across all three viewports.
- `git diff --check` — passed.
- Final V05 PNGs were independently inspected and verified as `720x1280`, `rgba`.

## V05 evidence hashes

- `normal_vip_pending.png` — SHA256 `83F270EE78CA802E0EE7B3895D4A9B3D8190A13717A59AF1F0C1E448300DCBB1`.
- `normal_vip_partial.png` — SHA256 `4174748175100E28CF869FF4D0B8A6CBEC3AD2534C3C5EA09B8A669917998F68`.
- `normal_vip_completed.png` — SHA256 `A99846E35F17151CC13AEB351576F8BD18622E5D73D449B03EF366BBD28561A0`.
- `non_vip_0_of_0.png` — SHA256 `4F53EE751E625C15A6566C166FC3D717576FD995ACE7BDA7494C76C92712FDF6`.

The captures show the centered combined frame, upper normal content, lower VIP pending/partial/completed content, equal target sizing policy, and the always-visible non-VIP lower board with `0/0`, no cocktail, and blank reward.

## Acceptance evidence status

- Combined asset active: PASS by source assertion and OpenGL capture.
- Existing To-Go display width parity: PASS by source assertion and M07 layout probes.
- Equal To-Go/VIP cocktail scaling policy: PASS by shared helper assertion and focused probe.
- Persistent non-VIP `0/0`: PASS by focused probe and OpenGL capture.
- Normal progress/reward: PASS by authoritative bridge-state assertion, dynamic capture, and unchanged `Drink.order_reward` authority.
- VIP progress/reward: PASS by production pending/partial/completed assertions and OpenGL captures.
- Independent audit: not performed by Codex.
- Owner runtime visual acceptance: not performed by Codex and remains required.
- Native mobile/device acceptance: not performed.

## Publication

- Implementation commit: `1a3a88a9c58fc7144d1bbd8ea54d780c026f3038` (`Implement M15 V05 combined To-Go VIP HUD`).
- Evidence/log publication commit: to be recorded in the final handoff after commit and push; the log is immutable after publication.
- Push target: `main` only; no GitHub branch was created.
- Required final equality proof is performed after publication with `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main`.

## Governance and limitations

- Root `TASKS.md` was read-only and was not modified or staged by Codex.
- No M16 implementation, gameplay/economy semantic change, R11 physics/table/collider change, or approved asset modification was made.
- Only exact Godot-generated `.translation` clutter created by import was removed; no owner files were discarded.
- Existing worktrees listed by preflight were not created or modified by this task.
- This log is builder evidence, not an acceptance verdict. ChatGPT remains the independent auditor and lifecycle owner.

## Handoff

`AWAITING_M15_AUDIT_V05`
