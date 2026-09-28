# BCM-M15 Tall To-Go + VIP HUD Integration — CODEX Log V06

Status: `IMPLEMENTATION_COMPLETE / AWAITING_M15_AUDIT_V06`

## Work item and authority

- Work item: `BCM-M15-VIP-BOOSTERS-ECONOMY V06`.
- Prompt: `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_EXECUTION_PROMPT_V06.md`.
- Locked criteria: `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V06.md`.
- Owner ruling: `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V06.md`.
- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

## Synchronization preflight

- `git status --short --branch`: clean `main...origin/main` before implementation.
- `git remote -v`: `origin` fetch/push `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- `git fetch origin main`: completed successfully.
- `git rev-list --left-right --count HEAD...origin/main`: `0 5` before safe fast-forward; `0 0` after.
- Start HEAD: `6f1e0a4`.
- The canonical checkout was clean and behind-only; it was fast-forwarded with `git merge --ff-only origin/main`.
- No reset, clean, stash, rebase, destructive checkout, force-push, branch creation, or Desktop clone/worktree was used.

## Implementation summary

- Replaced the active V05 combined HUD PNG with the exact owner-approved V06 `1132x1698` master.
- Preserved the existing external width contract at `210.0 * ui_scale` and derived the new height from the source aspect ratio.
- At the 720x1280 reference viewport, the old V05 runtime panel was `210.0x140.0618`; V06 is `210.0x315.0`.
- Re-mapped normal/VIP cocktail anchors and progress/reward recesses to V06 source geometry.
- Increased the shared normal/VIP cocktail max footprint from `44.0` to `60.0` display pixels; both slots still use the same helper and policy.
- Kept the long rope artwork attached at the viewport top through the unchanged `y=0` HUD anchor.
- Preserved dynamic normal progress/reward, VIP progress/checkmark/doubled reward, and persistent non-VIP `0/0` behavior.
- Preserved M15 gameplay/economy/session behavior, rewards, quantity ledgers, same-level precedence, progression, and R11 geometry.
- Updated only the bounded M07 layout fixtures and focused M15 assertions needed for V06 geometry.
- BEST SCORE, SCORE, NEXT, logo, table, launch, danger, rails, colliders, and physics coordinates were not changed.

## Canonical asset verification

- Download source URL: `https://d2ol7oe51mr4n9.cloudfront.net/user_3FxbKbb9noNuzsWT2Zc6dqfIuy6/a98d64bb-5bdd-438b-9346-665f8125530d.png`.
- Pre-replacement SHA-256: `acd600d05b316a01b5d39006cf845afa9674cfaaf0385c4f3aecda539d53539b`.
- Pre-replacement dimensions: `1132x1698`.
- Final repository asset SHA-256: `acd600d05b316a01b5d39006cf845afa9674cfaaf0385c4f3aecda539d53539b`.
- Final repository asset dimensions: `1132x1698`.
- V05 `1132x755` master is no longer the active repository asset.

## Changed files

Implementation commit `63f08c7bc55a51acd704785891633de7797a2644` contains:

- `assets/ui/panel_to_go_vip_orders.png`
- `scripts/game_manager.gd`
- `tests/m15_vip_boosters_economy_probe.gd`
- `tests/m07_r06_owner_layout_probe.gd`
- `docs/evidence/m07/independent_inner_content_layout_v02.json`

Evidence/log publication adds:

- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v06/normal_vip_pending.png`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v06/normal_vip_partial.png`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v06/normal_vip_completed.png`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v06/non_vip_0_of_0.png`
- This immutable log.

## Builder verification

- `godot_console.exe --headless --editor --path . --import` — exit `0`; Godot `4.7.2`; existing ignored `original_reference/project.godot` warning only.
- `godot_console.exe --headless --path . --script res://tests/m15_vip_boosters_economy_probe.gd` — exit `0`; `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS`.
- Same M15 headless command a second time — exit `0`; `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS`.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m15_vip_boosters_economy_probe.gd` — exit `0`; OpenGL Compatibility on Intel Iris Xe; all four V06 captures saved.
- `godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd` — exit `0`; `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m08_to_go_delivery_probe.gd` — exit `0`; `M08_TO_GO_DELIVERY_RESULT=PASS`. Existing headless null-viewport `save_png` diagnostics were non-fatal and pre-existing.
- `godot_console.exe --headless --path . --script res://tests/m03_economy_regression.gd` — exit `0`; `M03_PROBE_RESULT=PASS`.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m07_hud_composition_probe.gd` — exit `0`; `M07_PROBE_RESULT=PASS` across 720x1280, 720x1440, and 800x1280.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m07_r06_owner_layout_probe.gd` — exit `0`; `M07_R06_PROBE_RESULT=PASS` across all three viewports.
- `git diff --check` — exit `0`.

## V06 evidence

All four captures are `720x1280` PNGs from the Windows/OpenGL run:

- `normal_vip_pending.png` — SHA-256 `0C21C78C4446868F0D6902E3529F2D3C1C67992403E5A7991FFD409EBB33F957`.
- `normal_vip_partial.png` — SHA-256 `15529379E0086AA3C2AF6449494E2FF94FF3A93E148B46500DCAD4316D31662A`.
- `normal_vip_completed.png` — SHA-256 `7DC7B4FCA2813EC44E3AD384C4E4E8A6AD8C4155760775B86033233223651863`.
- `non_vip_0_of_0.png` — SHA-256 `709DDBFF1D20C9405B83738A08050FB9B963A4DF9CAFC72F4EA2F9B9EEDBD957`.

The captures show the centered tall master, long top ropes, unchanged surrounding HUD placement, fitted normal/VIP content, equal target sizing policy, and the always-visible non-VIP lower board with `0/0` and blank reward.

## Acceptance evidence status

- Exact V06 asset hash/dimensions: PASS.
- Same external width and aspect-derived taller height: PASS.
- Long-rope visibility: PASS by OpenGL capture and top-edge layout probe.
- Equal To-Go/VIP cocktail scaling policy: PASS by shared helper and focused probe.
- Persistent non-VIP `0/0`: PASS by focused probe and OpenGL capture.
- Normal progress/reward: PASS by authoritative bridge state and OpenGL capture.
- VIP progress/reward: PASS by pending/partial/completed assertions and OpenGL captures.
- Independent audit: not performed by Codex.
- Owner runtime visual acceptance: not performed by Codex and remains required.
- Native mobile/device acceptance: not performed.

## Publication

- Implementation commit: `63f08c7bc55a51acd704785891633de7797a2644`.
- Evidence/log publication commit: to be recorded in the final handoff after commit and push; the log is immutable after publication.
- Final main/canonical SHA at implementation publication: `63f08c7bc55a51acd704785891633de7797a2644`; final remote equality is verified after the evidence/log publication commit.
- Push target: `main` only; no GitHub branch was created.

## Governance and limitations

- Root `TASKS.md` was read-only and was not modified or staged by Codex.
- No M16 implementation, gameplay/economy semantic change, R11 physics/table/collider change, or approved asset redesign was made.
- Only exact Godot-generated `.translation` sidecars and probe-regenerated legacy M07 screenshots were cleaned/restored; no owner files were discarded.
- This log is builder evidence, not an acceptance verdict. ChatGPT remains the independent auditor and lifecycle owner.

## Handoff

`AWAITING_M15_AUDIT_V06`
