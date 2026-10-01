# BCM-M21-004 Full Accepted Regression

Status: `PASS`; total checks: `33`; passed: `33`; failed: `0`.
Godot: `4.7.2.stable.official.ed1daf0bf` at `C:\Users\sekip\AppData\Local\Microsoft\WinGet\Links\godot_console.exe`.

## Regression matrix

| ID | Mode | Exit | Marker | Status |
|---|---|---:|---|---|
| `M01-contract` | `headless` | `0` | `True` | **PASS** |
| `M02-physics` | `headless` | `0` | `True` | **PASS** |
| `M03-economy` | `headless` | `0` | `True` | **PASS** |
| `M07-R06-owner-layout` | `headless` | `0` | `True` | **PASS** |
| `M08-to-go` | `headless` | `0` | `True` | **PASS** |
| `M09-audio-haptics` | `headless` | `0` | `True` | **PASS** |
| `M10-campaign-architecture` | `headless` | `0` | `True` | **PASS** |
| `M11-save-migration-progression` | `headless` | `0` | `True` | **PASS** |
| `M12-world-map` | `headless` | `0` | `True` | **PASS** |
| `M13-island-map` | `headless` | `0` | `True` | **PASS** |
| `M14-gameplay-session-bridge` | `headless` | `0` | `True` | **PASS** |
| `M15-vip-boosters-economy` | `headless` | `0` | `True` | **PASS** |
| `M16-sunny-cove-content` | `headless` | `0` | `True` | **PASS** |
| `M17-vip-optionality` | `headless` | `0` | `True` | **PASS** |
| `M17-V06-analytical` | `headless` | `0` | `True` | **PASS** |
| `M17-difficulty-validation` | `headless` | `0` | `True` | **PASS** |
| `M18-star-contract` | `headless` | `0` | `True` | **PASS** |
| `M18-completion-progression` | `headless` | `0` | `True` | **PASS** |
| `M18-cumulative-star-rewards` | `headless` | `0` | `True` | **PASS** |
| `M18-reward-claim-remediation` | `headless` | `0` | `True` | **PASS** |
| `M18-replay-persistence` | `headless` | `0` | `True` | **PASS** |
| `M18-integration` | `headless` | `0` | `True` | **PASS** |
| `M18-island-map-replay` | `headless` | `0` | `True` | **PASS** |
| `M19-scalability` | `headless` | `0` | `True` | **PASS** |
| `M19-R01-child-01` | `headless` | `0` | `True` | **PASS** |
| `M19-R01-child-02` | `headless` | `0` | `True` | **PASS** |
| `M19-R01-child-03` | `headless` | `0` | `True` | **PASS** |
| `M19-R01-child-04` | `headless` | `0` | `True` | **PASS** |
| `M19-R01-child-05` | `headless` | `0` | `True` | **PASS** |
| `M19-R01-child-06` | `headless` | `0` | `True` | **PASS** |
| `M18-V02-R01-replay-capture` | `real_renderer` | `0` | `True` | **PASS** |
| `M20-runtime-capture` | `real_renderer` | `0` | `True` | **PASS** |
| `M17-V07-R03-read-only-report-integrity` | `read_only` | `0` | `True` | **PASS** |

## Historical and non-rerun boundaries

- tests/m17_canonical_screening_probe.gd was not run: explicitly historical pre-V05 VIP-second assertions are superseded by post-V05 acceptance.
- M07-R04 historical limitation remains excluded; M07-R06 owner-layout probe was run and required to pass.
- tools/campaign/m17_canonical_confirmation_v07_r03.gd was not invoked because it writes historical V07-R03 JSON/Markdown reports; the accepted V07-R03 report was validated read-only.

## Exact output

### `M01-contract`

Command: `godot_console.exe --headless --path . --script res://tests/m01_contract_probe.gd`
Exit code: `0`; required marker: `M01_PROBE_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M01_PROBE user_save_path=C:/Users/sekip/AppData/Roaming/Godot/app_userdata/CocktailMerge/save.cfg
M01_PROBE PASS: main scene loads as PackedScene
M01_PROBE PASS: runtime world is created
M01_PROBE PASS: runtime ShotController is created
M01_PROBE PASS: runtime MergeQueue is created
M01_PROBE PASS: initial held drink exists
M01_PROBE PASS: initial drink is HELD
M01_PROBE PASS: held drink is frozen
M01_PROBE PASS: held drink has no collision layer/mask
M01_PROBE PASS: mouse release launches current drink
M01_PROBE PASS: launched drink uses 700 px/s initial velocity
M01_PROBE PASS: launched drink is collidable
M01_PROBE PASS: next held drink appears immediately after mouse launch
M01_PROBE PASS: next drink is HELD
M01_PROBE PASS: touch release launches current drink
M01_PROBE PASS: touch route provides another immediate held drink
M01_PROBE PASS: multiple drinks can move simultaneously
M01_PROBE PASS: sliding deceleration is 180 px/s^2
M01_PROBE PASS: forward-only motion removes +Y rebound
M01_PROBE PASS: settled drink wakes and is physically movable on impact
MERGE L2 +20  COMBO x1 +0  (toplam: 20)
M01_PROBE PASS: merge creates capped next level
M01_PROBE PASS: merge result preserves forward/lateral momentum
M01_PROBE PASS: L12 is the cap and L13 is unavailable
OYUN BITTI - Skor: 123
M01_PROBE PASS: Game Over freezes the run and shows overlay
M01_PROBE PASS: best score is persisted through user://
M01_PROBE PASS: restart reloads a playable scene
M01_PROBE PASS: best score survives restart
M01_PROBE_RESULT=PASS
```

### `M02-physics`

Command: `godot_console.exe --headless --path . --script res://tests/m02_physics_regression.gd`
Exit code: `0`; required marker: `M02_PROBE_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M02_PROBE user_save_path=C:/Users/sekip/AppData/Roaming/Godot/app_userdata/CocktailMerge/save.cfg
M02_PROBE PASS: main scene loads as PackedScene
M02_PROBE PASS: runtime GameManager/World is ready
M02_PROBE PASS: runtime world has four named rails
M02_BODY_CONFIG level=6 mass=2.5 radius=42.0 freeze_mode=0 ccd=2 linear_damp=0.0 angular_damp=3.0 friction=0.07999999821186 bounce=0.0
M02_PROBE PASS: RigidBody2D body and zero-bounce physics configuration
M02_PROBE PASS: settled body starts dynamic, sleeping, and collidable
M02_MASS_RADIUS_TABLE L1 radius=20.0 mass=1.0 json_mass=1.0; L2 radius=23.0 mass=1.29999995231628 json_mass=2.0; L3 radius=27.0 mass=1.60000002384186 json_mass=4.0; L4 radius=31.0 mass=1.89999997615814 json_mass=8.0; L5 radius=36.0 mass=2.20000004768372 json_mass=16.0; L6 radius=42.0 mass=2.5 json_mass=32.0; L7 radius=49.0 mass=2.79999995231628 json_mass=64.0; L8 radius=56.0 mass=3.09999990463257 json_mass=128.0; L9 radius=64.0 mass=3.40000009536743 json_mass=256.0; L10 radius=72.0 mass=3.70000004768372 json_mass=512.0; L11 radius=80.0 mass=4.0 json_mass=1024.0; L12 radius=90.0 mass=4.30000019073486 json_mass=2048.0
M02_PROBE PASS: all 12 collider radii are positive and runtime mass is monotonic
M02_PROBE PASS: held state is frozen and non-physical before release
M02_PROBE PASS: held-to-sliding transition enables dynamic collision
M02_TOP_CONTACT final_position=(360.0, 391.7339) motion_state=2 velocity=(0.0, 0.0)
M02_PROBE PASS: top boundary contact settles without +Y rebound
M02_DIRECT_HIT contacts=1 target_position=(150.0, 632.3226) target_state=1
M02_PROBE PASS: 700 px/s direct-hit has contact without tunneling
M02_GLANCING_HIT contacts=1 target_position=(572.5089, 654.0648) target_state=1
M02_PROBE PASS: 700 px/s glancing-hit has contact without tunneling
M02_PROBE PASS: collision response remains forward-only
MERGE L2 +20  COMBO x1 +0  (toplam: 20)
M02_SINGLE_MERGE score_delta=20 level2_bodies=1 pending=0
M02_PROBE PASS: one pair resolves once with one score and one result body
MERGE L2 +20  COMBO x2 +5  (toplam: 45)
MERGE L3 +50  COMBO x3 +25  (toplam: 120)
M02_CHAIN_STRESS l3_bodies=2 moving_stress=true pending=0
M02_PROBE PASS: moving multi-body chain merge produces stable L3
M02_PROBE PASS: chain merge consumes only the intended chain inputs
M02_PROBE PASS: L12 plus L12 remains two L12 bodies with no L13
M02_PROBE PASS: L12 remains a hard cap
M02_RAPID_STEP index=1 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=2 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=3 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=4 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=5 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=6 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_LAUNCH launches=6 world_drinks=7 simulated_previous=6 current_valid=true current_state=0
M02_PROBE PASS: six rapid launches preserve current/next integrity
M02_PROBE PASS: earlier rapid-launch drinks continue physical simulation
M02_PROBE PASS: restart during multi-body motion produces clean playable scene
OYUN BITTI - Skor: 0
M02_PROBE PASS: Game Over with multiple moving drinks freezes all and stops shooting
M02_PROBE PASS: post-Game-Over restart has no stale moving-body references
M02_PROBE_RESULT=PASS
```

### `M03-economy`

Command: `godot_console.exe --headless --path . --script res://tests/m03_economy_regression.gd`
Exit code: `0`; required marker: `M03_PROBE_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M03_PROBE user_save_path=C:/Users/sekip/AppData/Roaming/Godot/app_userdata/CocktailMerge/save.cfg
M03_PROBE PASS: main scene loads as PackedScene
M03_PROBE PASS: runtime economy objects are ready
MERGE L2 +20  COMBO x1 +0  (toplam: 20)
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x1 +0  (toplam: 100)
MERGE L5 +200  COMBO x1 +0  (toplam: 200)
MERGE L6 +350  COMBO x1 +0  (toplam: 350)
MERGE L7 +600  COMBO x1 +0  (toplam: 600)
MERGE L8 +1000  COMBO x1 +0  (toplam: 1000)
MERGE L9 +1600  COMBO x1 +0  (toplam: 1600)
MERGE L10 +2500  COMBO x1 +0  (toplam: 2500)
MERGE L11 +4000  COMBO x1 +0  (toplam: 4000)
MERGE L12 +6500  COMBO x1 +0  (toplam: 6500)
M03_SCORE_TABLE L2 expected=20 observed=20; L3 expected=50 observed=50; L4 expected=100 observed=100; L5 expected=200 observed=200; L6 expected=350 observed=350; L7 expected=600 observed=600; L8 expected=1000 observed=1000; L9 expected=1600 observed=1600; L10 expected=2500 observed=2500; L11 expected=4000 observed=4000; L12 expected=6500 observed=6500
M03_PROBE PASS: every resulting merge level L2-L12 pays the exact score once
MERGE L2 +20  COMBO x1 +0  (toplam: 20)
MERGE L2 +20  COMBO x2 +5  (toplam: 45)
MERGE L2 +20  COMBO x3 +10  (toplam: 75)
MERGE L2 +20  COMBO x4 +15  (toplam: 110)
MERGE L2 +20  COMBO x5 +20  (toplam: 150)
MERGE L2 +20  COMBO x6 +25  (toplam: 195)
MERGE L2 +20  COMBO x6 +25  (toplam: 240)
M03_COMBO observed_deltas=[20, 25, 30, 35, 40, 45, 45] chain=6 timer=1.5
M03_PROBE PASS: combo x1 through x6+ uses 0/25/50/75/100/125 percent cap
M03_PROBE PASS: combo expiration resets deterministically
MERGE L2 +20  COMBO x1 +0  (toplam: 260)
M03_PROBE PASS: post-window merge restarts at x1
M03_PROBE PASS: initial active To-Go target starts at owner-directed L5
M03_PROBE PASS: To-Go target stays in L6-L12 and avoids immediate repeat
M03_REWARD_TABLE L6 expected=1000 observed=1000; L7 expected=1800 observed=1800; L8 expected=3000 observed=3000; L9 expected=5000 observed=5000; L10 expected=8000 observed=8000; L11 expected=12000 observed=12000; L12 expected=18000 observed=18000
M03_PROBE PASS: owner-approved To-Go reward table L6-L12 is exact
MERGE L6 +350  COMBO x1 +0  (toplam: 350)
TO-GO ORDER L6 +1000  (toplam: 1350)
M03_IMMEDIATE_ORDER L6 merge=350 reward=1000 expected_total=1350 observed_total=1350
M03_PROBE PASS: newly created L6 matching drink fulfills active order exactly once
MERGE L7 +600  COMBO x1 +0  (toplam: 600)
TO-GO ORDER L7 +1800  (toplam: 2400)
M03_IMMEDIATE_ORDER L7 merge=600 reward=1800 expected_total=2400 observed_total=2400
M03_PROBE PASS: newly created L7 matching drink fulfills active order exactly once
MERGE L8 +1000  COMBO x1 +0  (toplam: 1000)
TO-GO ORDER L8 +3000  (toplam: 4000)
M03_IMMEDIATE_ORDER L8 merge=1000 reward=3000 expected_total=4000 observed_total=4000
M03_PROBE PASS: newly created L8 matching drink fulfills active order exactly once
MERGE L9 +1600  COMBO x1 +0  (toplam: 1600)
TO-GO ORDER L9 +5000  (toplam: 6600)
M03_IMMEDIATE_ORDER L9 merge=1600 reward=5000 expected_total=6600 observed_total=6600
M03_PROBE PASS: newly created L9 matching drink fulfills active order exactly once
MERGE L10 +2500  COMBO x1 +0  (toplam: 2500)
TO-GO ORDER L10 +8000  (toplam: 10500)
M03_IMMEDIATE_ORDER L10 merge=2500 reward=8000 expected_total=10500 observed_total=10500
M03_PROBE PASS: newly created L10 matching drink fulfills active order exactly once
MERGE L11 +4000  COMBO x1 +0  (toplam: 4000)
TO-GO ORDER L11 +12000  (toplam: 16000)
M03_IMMEDIATE_ORDER L11 merge=4000 reward=12000 expected_total=16000 observed_total=16000
M03_PROBE PASS: newly created L11 matching drink fulfills active order exactly once
MERGE L12 +6500  COMBO x1 +0  (toplam: 6500)
TO-GO ORDER L12 +18000  (toplam: 24500)
M03_IMMEDIATE_ORDER L12 merge=6500 reward=18000 expected_total=24500 observed_total=24500
M03_PROBE PASS: newly created L12 matching drink fulfills active order exactly once
TO-GO ORDER L6 +1000  (toplam: 1000)
M03_STORED_ORDER L6 reward=1000 expected_total=1000 observed_total=1000
M03_PROBE PASS: stored L6 matching drink receives only the current To-Go reward exactly once
TO-GO ORDER L7 +1800  (toplam: 1800)
M03_STORED_ORDER L7 reward=1800 expected_total=1800 observed_total=1800
M03_PROBE PASS: stored L7 matching drink receives only the current To-Go reward exactly once
TO-GO ORDER L8 +3000  (toplam: 3000)
M03_STORED_ORDER L8 reward=3000 expected_total=3000 observed_total=3000
M03_PROBE PASS: stored L8 matching drink receives only the current To-Go reward exactly once
TO-GO ORDER L9 +5000  (toplam: 5000)
M03_STORED_ORDER L9 reward=5000 expected_total=5000 observed_total=5000
M03_PROBE PASS: stored L9 matching drink receives only the current To-Go reward exactly once
TO-GO ORDER L10 +8000  (toplam: 8000)
M03_STORED_ORDER L10 reward=8000 expected_total=8000 observed_total=8000
M03_PROBE PASS: stored L10 matching drink receives only the current To-Go reward exactly once
TO-GO ORDER L11 +12000  (toplam: 12000)
M03_STORED_ORDER L11 reward=12000 expected_total=12000 observed_total=12000
M03_PROBE PASS: stored L11 matching drink receives only the current To-Go reward exactly once
TO-GO ORDER L12 +18000  (toplam: 18000)
M03_STORED_ORDER L12 reward=18000 expected_total=18000 observed_total=18000
M03_PROBE PASS: stored L12 matching drink receives only the current To-Go reward exactly once
TO-GO ORDER L10 +8000  (toplam: 8000)
M03_PROBE PASS: only one of multiple matching stored drinks is consumed
TO-GO ORDER L12 +18000  (toplam: 18000)
M03_PROBE PASS: L12 remains stored when not ordered and fulfills a later L12 order
MERGE L2 +20  COMBO x1 +0  (toplam: 20)
M03_PROBE PASS: duplicate merge request cannot double-pay
M03_PROBE PASS: missing save loads safe best-score default
M03_PROBE PASS: corrupt save loads safe best-score default without crash
OYUN BITTI - Skor: 20
M03_PROBE PASS: danger line waits below one-second tolerance
M03_PROBE PASS: danger line triggers deterministic Game Over at one second
M03_PROBE PASS: restart clears session score/state and restores playable scene
OYUN BITTI - Skor: 321
M03_PROBE PASS: Game Over with moving drinks freezes run, stops shooting, clears pending work, and shows overlay
M03_PROBE PASS: Game Over persists best score without corrupting save
M03_PROBE PASS: restart after moving Game Over preserves best and clears session
M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
OWNER-APPROVED REWARD TABLE APPLIED: L6=1000 L7=1800; L8-L12 unchanged
M03_PROBE_RESULT=PASS
```

### `M07-R06-owner-layout`

Command: `godot_console.exe --headless --path . --script res://tests/m07_r06_owner_layout_probe.gd`
Exit code: `0`; required marker: `M07_R06_PROBE_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M07_R06_PROBE PASS: M07-R06 main scene loads
M07_R06_PROBE PASS: canonical_720x1280 HUD panels exist
M07_R06_PROBE PASS: canonical_720x1280 BEST remains left and SCORE is right below NEXT
M07_R06_PROBE PASS: canonical_720x1280 score panel remains above tabletop and on-screen
M07_R06_SCORE label=canonical_720x1280 value=0 best_bounds=[96.00,60.50,14.00,30.00] score_bounds=[96.00,58.00,14.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=canonical_720x1280 value=321 best_bounds=[84.50,60.50,37.00,30.00] score_bounds=[84.50,58.00,37.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=canonical_720x1280 value=24380 best_bounds=[73.00,60.50,60.00,30.00] score_bounds=[73.00,58.00,60.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=canonical_720x1280 value=999999 best_bounds=[67.50,60.50,71.00,30.00] score_bounds=[67.50,58.00,71.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=canonical_720x1280 value=9999999 best_bounds=[61.50,60.50,83.00,30.00] score_bounds=[61.50,58.00,83.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_PROBE PASS: canonical_720x1280 fixed-size score glyphs center inside both recessed windows
M07_R06_PROBE PASS: canonical_720x1280 To-Go L6 target+reward fit inside cream board
M07_R06_TO_GO label=canonical_720x1280 level=L6 target=[39.52,94.90,54.21,57.03] reward=1000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: canonical_720x1280 To-Go L7 target+reward fit inside cream board
M07_R06_TO_GO label=canonical_720x1280 level=L7 target=[36.41,94.37,58.85,57.85] reward=1800 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: canonical_720x1280 To-Go L8 target+reward fit inside cream board
M07_R06_TO_GO label=canonical_720x1280 level=L8 target=[38.38,94.47,57.08,58.90] reward=3000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: canonical_720x1280 To-Go L9 target+reward fit inside cream board
M07_R06_TO_GO label=canonical_720x1280 level=L9 target=[38.47,93.51,56.79,59.86] reward=5000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: canonical_720x1280 To-Go L10 target+reward fit inside cream board
M07_R06_TO_GO label=canonical_720x1280 level=L10 target=[41.05,94.27,53.88,56.89] reward=8000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: canonical_720x1280 To-Go L11 target+reward fit inside cream board
M07_R06_TO_GO label=canonical_720x1280 level=L11 target=[36.41,94.27,59.14,59.09] reward=12000 reward_bounds=[122.44,129.86,53.00,27.00]
M07_R06_PROBE PASS: canonical_720x1280 To-Go L12 target+reward fit inside cream board
M07_R06_TO_GO label=canonical_720x1280 level=L12 target=[39.43,95.61,55.07,54.40] reward=18000 reward_bounds=[122.44,129.86,53.00,27.00]
M07_R06_PROBE PASS: canonical_720x1280 combined To-Go/VIP asset touches viewport top without runtime rope
M07_R08_TO_GO_TOP label=canonical_720x1280 panel_y=0.000 asset_top_y=0.000 no_runtime_rope=true
M07_R06_PROBE PASS: canonical_720x1280 NEXT L01-L12 remains contained
M07_R06_PROBE PASS: canonical_720x1280 baked 2x6 progression remains frame-free
M07_R06_PROBE PASS: canonical_720x1280 M06 danger/launch coordinates and no guide line remain
M07_R06_HELD label=canonical_720x1280 level=L1 body_center_x=360.000 halo_x=360.000 x_delta=-0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=canonical_720x1280 level=L2 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=canonical_720x1280 level=L3 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=canonical_720x1280 level=L4 body_center_x=360.000 halo_x=360.000 x_delta=-0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=canonical_720x1280 level=L5 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=canonical_720x1280 level=L6 body_center_x=360.000 halo_x=360.000 x_delta=-0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=canonical_720x1280 level=L7 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=canonical_720x1280 level=L8 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=canonical_720x1280 level=L9 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=canonical_720x1280 level=L10 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=canonical_720x1280 level=L11 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=canonical_720x1280 level=L12 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_PROBE PASS: canonical_720x1280 held glass bodies center on halo X and share launch baseline Y
M07_R06_HELD_SUMMARY label=canonical_720x1280 max_x_delta=0.000 max_y_delta=0.000
ERROR: Parameter "t" is null.
   at: texture_2d_get (./servers/rendering/dummy/storage/texture_storage.h:110)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m07_r06_owner_layout_probe.gd:151)
       [1] _run (res://tests/m07_r06_owner_layout_probe.gd:52)
       [2] _check_held_body_alignment (res://tests/m07_r06_owner_layout_probe.gd:147)
SCRIPT ERROR: Cannot call method 'save_png' on a null value.
   at: _save_capture (res://tests/m07_r06_owner_layout_probe.gd:153)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m07_r06_owner_layout_probe.gd:153)
       [1] _run (res://tests/m07_r06_owner_layout_probe.gd:52)
       [2] _check_held_body_alignment (res://tests/m07_r06_owner_layout_probe.gd:147)
M07_R06_PROBE PASS: taller_720x1440 HUD panels exist
M07_R06_PROBE PASS: taller_720x1440 BEST remains left and SCORE is right below NEXT
M07_R06_PROBE PASS: taller_720x1440 score panel remains above tabletop and on-screen
M07_R06_SCORE label=taller_720x1440 value=0 best_bounds=[96.00,60.50,14.00,30.00] score_bounds=[96.00,58.00,14.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=taller_720x1440 value=321 best_bounds=[84.50,60.50,37.00,30.00] score_bounds=[84.50,58.00,37.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=taller_720x1440 value=24380 best_bounds=[73.00,60.50,60.00,30.00] score_bounds=[73.00,58.00,60.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=taller_720x1440 value=999999 best_bounds=[67.50,60.50,71.00,30.00] score_bounds=[67.50,58.00,71.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=taller_720x1440 value=9999999 best_bounds=[61.50,60.50,83.00,30.00] score_bounds=[61.50,58.00,83.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_PROBE PASS: taller_720x1440 fixed-size score glyphs center inside both recessed windows
M07_R06_PROBE PASS: taller_720x1440 To-Go L6 target+reward fit inside cream board
M07_R06_TO_GO label=taller_720x1440 level=L6 target=[39.52,94.90,54.21,57.03] reward=1000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: taller_720x1440 To-Go L7 target+reward fit inside cream board
M07_R06_TO_GO label=taller_720x1440 level=L7 target=[36.41,94.37,58.85,57.85] reward=1800 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: taller_720x1440 To-Go L8 target+reward fit inside cream board
M07_R06_TO_GO label=taller_720x1440 level=L8 target=[38.38,94.47,57.08,58.90] reward=3000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: taller_720x1440 To-Go L9 target+reward fit inside cream board
M07_R06_TO_GO label=taller_720x1440 level=L9 target=[38.47,93.51,56.79,59.86] reward=5000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: taller_720x1440 To-Go L10 target+reward fit inside cream board
M07_R06_TO_GO label=taller_720x1440 level=L10 target=[41.05,94.27,53.88,56.89] reward=8000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: taller_720x1440 To-Go L11 target+reward fit inside cream board
M07_R06_TO_GO label=taller_720x1440 level=L11 target=[36.41,94.27,59.14,59.09] reward=12000 reward_bounds=[122.44,129.86,53.00,27.00]
M07_R06_PROBE PASS: taller_720x1440 To-Go L12 target+reward fit inside cream board
M07_R06_TO_GO label=taller_720x1440 level=L12 target=[39.43,95.61,55.07,54.40] reward=18000 reward_bounds=[122.44,129.86,53.00,27.00]
M07_R06_PROBE PASS: taller_720x1440 combined To-Go/VIP asset touches viewport top without runtime rope
M07_R08_TO_GO_TOP label=taller_720x1440 panel_y=0.000 asset_top_y=0.000 no_runtime_rope=true
M07_R06_PROBE PASS: taller_720x1440 NEXT L01-L12 remains contained
M07_R06_PROBE PASS: taller_720x1440 baked 2x6 progression remains frame-free
M07_R06_PROBE PASS: taller_720x1440 M06 danger/launch coordinates and no guide line remain
M07_R06_HELD label=taller_720x1440 level=L1 body_center_x=360.000 halo_x=360.000 x_delta=-0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=0.000
M07_R06_HELD label=taller_720x1440 level=L2 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=-0.000
M07_R06_HELD label=taller_720x1440 level=L3 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=0.000
M07_R06_HELD label=taller_720x1440 level=L4 body_center_x=360.000 halo_x=360.000 x_delta=-0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=-0.000
M07_R06_HELD label=taller_720x1440 level=L5 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=-0.000
M07_R06_HELD label=taller_720x1440 level=L6 body_center_x=360.000 halo_x=360.000 x_delta=-0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=-0.000
M07_R06_HELD label=taller_720x1440 level=L7 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=0.000
M07_R06_HELD label=taller_720x1440 level=L8 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=0.000
M07_R06_HELD label=taller_720x1440 level=L9 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=0.000
M07_R06_HELD label=taller_720x1440 level=L10 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=-0.000
M07_R06_HELD label=taller_720x1440 level=L11 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=-0.000
M07_R06_HELD label=taller_720x1440 level=L12 body_center_x=360.000 halo_x=360.000 x_delta=0.000 body_bottom_y=1068.000 target_y=1068.000 y_delta=-0.000
M07_R06_PROBE PASS: taller_720x1440 held glass bodies center on halo X and share launch baseline Y
M07_R06_HELD_SUMMARY label=taller_720x1440 max_x_delta=0.000 max_y_delta=0.000
ERROR: Parameter "t" is null.
   at: texture_2d_get (./servers/rendering/dummy/storage/texture_storage.h:110)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m07_r06_owner_layout_probe.gd:151)
       [1] _run (res://tests/m07_r06_owner_layout_probe.gd:52)
       [2] _check_held_body_alignment (res://tests/m07_r06_owner_layout_probe.gd:147)
SCRIPT ERROR: Cannot call method 'save_png' on a null value.
   at: _save_capture (res://tests/m07_r06_owner_layout_probe.gd:153)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m07_r06_owner_layout_probe.gd:153)
       [1] _run (res://tests/m07_r06_owner_layout_probe.gd:52)
       [2] _check_held_body_alignment (res://tests/m07_r06_owner_layout_probe.gd:147)
M07_R06_PROBE PASS: shorter_wider_800x1280 HUD panels exist
M07_R06_PROBE PASS: shorter_wider_800x1280 BEST remains left and SCORE is right below NEXT
M07_R06_PROBE PASS: shorter_wider_800x1280 score panel remains above tabletop and on-screen
M07_R06_SCORE label=shorter_wider_800x1280 value=0 best_bounds=[96.00,60.50,14.00,30.00] score_bounds=[96.00,58.00,14.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=shorter_wider_800x1280 value=321 best_bounds=[84.50,60.50,37.00,30.00] score_bounds=[84.50,58.00,37.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=shorter_wider_800x1280 value=24380 best_bounds=[73.00,60.50,60.00,30.00] score_bounds=[73.00,58.00,60.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=shorter_wider_800x1280 value=999999 best_bounds=[67.50,60.50,71.00,30.00] score_bounds=[67.50,58.00,71.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=shorter_wider_800x1280 value=9999999 best_bounds=[61.50,60.50,83.00,30.00] score_bounds=[61.50,58.00,83.00,30.00] best_center_delta=0.005 score_center_delta=0.005
M07_R06_PROBE PASS: shorter_wider_800x1280 fixed-size score glyphs center inside both recessed windows
M07_R06_PROBE PASS: shorter_wider_800x1280 To-Go L6 target+reward fit inside cream board
M07_R06_TO_GO label=shorter_wider_800x1280 level=L6 target=[39.52,94.90,54.21,57.03] reward=1000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: shorter_wider_800x1280 To-Go L7 target+reward fit inside cream board
M07_R06_TO_GO label=shorter_wider_800x1280 level=L7 target=[36.41,94.37,58.85,57.85] reward=1800 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: shorter_wider_800x1280 To-Go L8 target+reward fit inside cream board
M07_R06_TO_GO label=shorter_wider_800x1280 level=L8 target=[38.38,94.47,57.08,58.90] reward=3000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: shorter_wider_800x1280 To-Go L9 target+reward fit inside cream board
M07_R06_TO_GO label=shorter_wider_800x1280 level=L9 target=[38.47,93.51,56.79,59.86] reward=5000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: shorter_wider_800x1280 To-Go L10 target+reward fit inside cream board
M07_R06_TO_GO label=shorter_wider_800x1280 level=L10 target=[41.05,94.27,53.88,56.89] reward=8000 reward_bounds=[122.44,129.86,43.00,27.00]
M07_R06_PROBE PASS: shorter_wider_800x1280 To-Go L11 target+reward fit inside cream board
M07_R06_TO_GO label=shorter_wider_800x1280 level=L11 target=[36.41,94.27,59.14,59.09] reward=12000 reward_bounds=[122.44,129.86,53.00,27.00]
M07_R06_PROBE PASS: shorter_wider_800x1280 To-Go L12 target+reward fit inside cream board
M07_R06_TO_GO label=shorter_wider_800x1280 level=L12 target=[39.43,95.61,55.07,54.40] reward=18000 reward_bounds=[122.44,129.86,53.00,27.00]
M07_R06_PROBE PASS: shorter_wider_800x1280 combined To-Go/VIP asset touches viewport top without runtime rope
M07_R08_TO_GO_TOP label=shorter_wider_800x1280 panel_y=0.000 asset_top_y=0.000 no_runtime_rope=true
M07_R06_PROBE PASS: shorter_wider_800x1280 NEXT L01-L12 remains contained
M07_R06_PROBE PASS: shorter_wider_800x1280 baked 2x6 progression remains frame-free
M07_R06_PROBE PASS: shorter_wider_800x1280 M06 danger/launch coordinates and no guide line remain
M07_R06_HELD label=shorter_wider_800x1280 level=L1 body_center_x=400.000 halo_x=400.000 x_delta=-0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L2 body_center_x=400.000 halo_x=400.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L3 body_center_x=400.000 halo_x=400.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L4 body_center_x=400.000 halo_x=400.000 x_delta=-0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L5 body_center_x=400.000 halo_x=400.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L6 body_center_x=400.000 halo_x=400.000 x_delta=-0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L7 body_center_x=400.000 halo_x=400.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L8 body_center_x=400.000 halo_x=400.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L9 body_center_x=400.000 halo_x=400.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L10 body_center_x=400.000 halo_x=400.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L11 body_center_x=400.000 halo_x=400.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_HELD label=shorter_wider_800x1280 level=L12 body_center_x=400.000 halo_x=400.000 x_delta=0.000 body_bottom_y=949.667 target_y=949.667 y_delta=-0.000
M07_R06_PROBE PASS: shorter_wider_800x1280 held glass bodies center on halo X and share launch baseline Y
M07_R06_HELD_SUMMARY label=shorter_wider_800x1280 max_x_delta=0.000 max_y_delta=0.000
ERROR: Parameter "t" is null.
   at: texture_2d_get (./servers/rendering/dummy/storage/texture_storage.h:110)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m07_r06_owner_layout_probe.gd:151)
       [1] _run (res://tests/m07_r06_owner_layout_probe.gd:52)
       [2] _check_held_body_alignment (res://tests/m07_r06_owner_layout_probe.gd:147)
SCRIPT ERROR: Cannot call method 'save_png' on a null value.
   at: _save_capture (res://tests/m07_r06_owner_layout_probe.gd:153)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m07_r06_owner_layout_probe.gd:153)
       [1] _run (res://tests/m07_r06_owner_layout_probe.gd:52)
       [2] _check_held_body_alignment (res://tests/m07_r06_owner_layout_probe.gd:147)
M07_R06_PROBE_RESULT=PASS
```

### `M08-to-go`

Command: `godot_console.exe --headless --path . --script res://tests/m08_to_go_delivery_probe.gd`
Exit code: `0`; required marker: `M08_TO_GO_DELIVERY_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M08_PROBE PASS: main scene loads
M08_PROBE PASS: runtime manager and To-Go target are ready
M08_PROBE PASS: merge feedback node is created
ERROR: Parameter "t" is null.
   at: texture_2d_get (./servers/rendering/dummy/storage/texture_storage.h:110)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m08_to_go_delivery_probe.gd:115)
       [1] _run (res://tests/m08_to_go_delivery_probe.gd:35)
SCRIPT ERROR: Cannot call method 'save_png' on a null value.
   at: _save_capture (res://tests/m08_to_go_delivery_probe.gd:117)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m08_to_go_delivery_probe.gd:117)
       [1] _run (res://tests/m08_to_go_delivery_probe.gd:35)
M08_PROBE PASS: merge feedback self-cleans
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
M08_PROBE PASS: merge feedback preserves merge level and raw position
M08_PROBE PASS: merge feedback preserves inherited momentum
M08_PROBE PASS: matching To-Go drink enters target capture once
M08_PROBE PASS: delivery trail is created
ERROR: Parameter "t" is null.
   at: texture_2d_get (./servers/rendering/dummy/storage/texture_storage.h:110)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m08_to_go_delivery_probe.gd:115)
       [1] _run (res://tests/m08_to_go_delivery_probe.gd:73)
       [2] _wait_seconds (res://tests/m08_to_go_delivery_probe.gd:124)
SCRIPT ERROR: Cannot call method 'save_png' on a null value.
   at: _save_capture (res://tests/m08_to_go_delivery_probe.gd:117)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m08_to_go_delivery_probe.gd:117)
       [1] _run (res://tests/m08_to_go_delivery_probe.gd:73)
       [2] _wait_seconds (res://tests/m08_to_go_delivery_probe.gd:124)
TO-GO ORDER L6 +1000  (toplam: 1000)
M08_PROBE PASS: matching drink is removed exactly once
M08_PROBE PASS: To-Go reward is added exactly once
M08_PROBE PASS: target transition returns to idle and chooses next target
M08_PROBE PASS: stored delivery does not add merge/combo score
M08_PROBE PASS: completion feedback is created
M08_STATE completion panels best_visible=true score_visible=true hud_visible=true best_modulate=(1.0, 1.0, 1.0, 1.0) score_modulate=(1.0, 1.0, 1.0, 1.0)
ERROR: Parameter "t" is null.
   at: texture_2d_get (./servers/rendering/dummy/storage/texture_storage.h:110)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m08_to_go_delivery_probe.gd:115)
       [1] _run (res://tests/m08_to_go_delivery_probe.gd:81)
       [2] _wait_seconds (res://tests/m08_to_go_delivery_probe.gd:124)
SCRIPT ERROR: Cannot call method 'save_png' on a null value.
   at: _save_capture (res://tests/m08_to_go_delivery_probe.gd:117)
   GDScript backtrace (most recent call first):
       [0] _save_capture (res://tests/m08_to_go_delivery_probe.gd:117)
       [1] _run (res://tests/m08_to_go_delivery_probe.gd:81)
       [2] _wait_seconds (res://tests/m08_to_go_delivery_probe.gd:124)
M08_PROBE PASS: delivery trail self-cleans
M08_PROBE PASS: completion feedback self-cleans
TO-GO ORDER L6 +1000  (toplam: 1000)
M08_PROBE PASS: duplicate collection request pays one reward
M08_TO_GO_DELIVERY_RESULT=PASS
```

### `M09-audio-haptics`

Command: `godot_console.exe --headless --path . --script res://tests/m09_audio_haptics_probe.gd`
Exit code: `0`; required marker: `M09_AUDIO_HAPTICS_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M09_PROBE PASS: main scene loads
M09_PROBE PASS: feedback service is attached
M09_PROBE PASS: first live To-Go target is L5
M09_CAPTURE name=startup_l5_720x1280.png unavailable=headless_renderer
M09_PROBE PASS: existing reward table remains unchanged including L5=0
M09_PROBE PASS: live target is expected L5
M09_CAPTURE name=l5_delivery_in_progress_720x1280.png unavailable=headless_renderer
TO-GO ORDER L5 +0  (toplam: 0)
M09_PROBE PASS: L5 delivery returns to idle
M09_PROBE PASS: first order completes as L5 with unchanged zero reward
M09_PROBE PASS: live target is expected L6
TO-GO ORDER L6 +1000  (toplam: 1000)
M09_PROBE PASS: L6 delivery returns to idle
M09_PROBE PASS: second order completes as L6 with existing reward
M09_PROBE PASS: live target is expected L7
TO-GO ORDER L7 +1800  (toplam: 2800)
M09_PROBE PASS: L7 delivery returns to idle
M09_PROBE PASS: third order completes as L7 with existing reward
M09_PROBE PASS: fourth target resumes normal L6-L12 selection
M09_PROBE PASS: order-complete feedback fires once per completed order
MERGE L2 +20  COMBO x1 +0  (toplam: 2820)
M09_PROBE PASS: merge feedback hook fires at most once per merge
M09_PROBE PASS: audio hook remains safe without audio assets
M09_PROBE PASS: disabling haptics prevents haptic calls
M09_PROBE PASS: unsupported haptics path is a safe no-op
M09_PROBE PASS: M08 merge feedback cleanup remains intact
M09_PROBE PASS: M08 delivery trail cleanup remains intact
M09_AUDIO_HAPTICS_RESULT=PASS
```

### `M10-campaign-architecture`

Command: `godot_console.exe --headless --path . --script res://tests/m10_campaign_architecture_probe.gd`
Exit code: `0`; required marker: `M10_CAMPAIGN_ARCHITECTURE_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M10_PROBE PASS: canonical seed loads deterministically
M10_PROBE PASS: Sunny Cove is default-open
M10_PROBE PASS: get_island works
M10_PROBE PASS: get_level works
M10_PROBE PASS: get_levels_for_island works
M10_PROBE PASS: canonical Sunny Cove contains the full 100-level dataset
M10_PROBE PASS: duplicate island id is rejected
M10_PROBE PASS: duplicate level id is rejected
M10_PROBE PASS: malformed level is rejected
M10_PROBE PASS: unresolved island reference is rejected
M10_PROBE PASS: non-positive time limit is rejected
M10_PROBE PASS: invalid order quantity is rejected
M10_PROBE PASS: out-of-range cocktail target is rejected
M10_PROBE PASS: unresolved unlock_rule island reference is rejected
M10_PROBE PASS: unsupported unlock_rule type is rejected
M10_PROBE PASS: invalid required completion level is rejected
M10_PROBE PASS: required completion level beyond source range is rejected
M10_PROBE PASS: FULL validation rejects positive-count island with zero loaded rows
M10_PROBE PASS: full validation accepts the canonical declared level count
M10_PROBE PASS: valid islands and levels load
M10_PROBE PASS: CampaignManager configures without gameplay scene
M10_PROBE PASS: CampaignManager exposes selection
M10_PROBE PASS: CampaignManager completion update is idempotent and preserves best result
M10_PROBE PASS: GameplaySessionBridge resolves immutable level definition
M10_PROBE PASS: bridge configuration is a detached snapshot
M10_PROBE PASS: session nested arrays and dictionaries are deeply immutable
M10_PROBE PASS: consumer access leaves canonical level data unchanged
M10_PROBE PASS: GameEconomy grants a reward
M10_PROBE PASS: GameEconomy duplicate reward is idempotent
M10_PROBE PASS: SaveManager schema version API exists
M10_PROBE PASS: SaveManager isolated write API succeeds
M10_PROBE PASS: SaveManager encode/decode round trip works
M10_PROBE PASS: SaveManager read API is isolated and structured
M10_CAMPAIGN_ARCHITECTURE_RESULT=PASS
```

### `M11-save-migration-progression`

Command: `godot_console.exe --headless --path . --script res://tests/m11_save_migration_progression_probe.gd`
Exit code: `0`; required marker: `M11_SAVE_MIGRATION_PROGRESSION_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M11_PROBE PASS: first boot returns a fresh default
M11_PROBE PASS: valid write/read round trip
M11_PROBE PASS: first persistence write succeeds
M11_PROBE PASS: second persistence write succeeds
M11_PROBE PASS: backup contains the last known good primary
ERROR: Parse JSON failed. Error at line 0: Expected '}'
   at: parse_string (core/io/json.cpp:629)
   GDScript backtrace (most recent call first):
       [0] _read_candidate (res://scripts/campaign/save_manager.gd:277)
       [1] load_state (res://scripts/campaign/save_manager.gd:118)
       [2] read_state (res://scripts/campaign/save_manager.gd:109)
       [3] _run (res://tests/m11_save_migration_progression_probe.gd:111)
ERROR: Parse JSON failed. Error at line 0: Expected '}'
   at: parse_string (core/io/json.cpp:629)
   GDScript backtrace (most recent call first):
       [0] _raw_file_is_recoverable (res://scripts/campaign/save_manager.gd:304)
       [1] write_state (res://scripts/campaign/save_manager.gd:198)
       [2] load_state (res://scripts/campaign/save_manager.gd:165)
       [3] read_state (res://scripts/campaign/save_manager.gd:109)
       [4] _run (res://tests/m11_save_migration_progression_probe.gd:111)
M11_PROBE PASS: malformed primary recovers valid backup
ERROR: Parse JSON failed. Error at line 0: Expected 'true', 'false', or 'null', got 'partial'
   at: parse_string (core/io/json.cpp:629)
   GDScript backtrace (most recent call first):
       [0] _read_candidate (res://scripts/campaign/save_manager.gd:277)
       [1] load_state (res://scripts/campaign/save_manager.gd:118)
       [2] read_state (res://scripts/campaign/save_manager.gd:109)
       [3] _run (res://tests/m11_save_migration_progression_probe.gd:119)
ERROR: Parse JSON failed. Error at line 0: Expected 'true', 'false', or 'null', got 'also'
   at: parse_string (core/io/json.cpp:629)
   GDScript backtrace (most recent call first):
       [0] _read_candidate (res://scripts/campaign/save_manager.gd:277)
       [1] load_state (res://scripts/campaign/save_manager.gd:132)
       [2] read_state (res://scripts/campaign/save_manager.gd:109)
       [3] _run (res://tests/m11_save_migration_progression_probe.gd:119)
M11_PROBE PASS: malformed primary and backup use safe fallback
M11_PROBE PASS: future schema is surfaced as unsupported
M11_PROBE PASS: older schema uses the migration entry point
M11_PROBE PASS: legacy best score migrates without rewriting legacy save
M11_PROBE PASS: higher campaign best is preserved over repeated legacy migration
M11_PROBE PASS: baseline for failed write is stored
M11_PROBE PASS: invalid write does not destroy previous valid state
M11_PROBE PASS: test campaign definitions load in FULL mode
M11_PROBE PASS: CampaignManager configures from loaded state
M11_PROBE PASS: completion unlocks next level
M11_PROBE PASS: worse replay preserves best stars and score without state change
M11_PROBE PASS: better replay upgrades stars and score
M11_PROBE PASS: final level unlocks next island by canonical rule
M11_PROBE PASS: milestone claim is one-time and idempotent
M11_PROBE PASS: progression state persists
M11_PROBE PASS: persisted progression reloads identically
M11_SAVE_MIGRATION_PROGRESSION_RESULT=PASS
```

### `M12-world-map`

Command: `godot_console.exe --headless --path . --script res://tests/m12_world_map_probe.gd`
Exit code: `0`; required marker: `M12_WORLD_MAP_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M12_PROBE PASS: normal startup uses application shell and excludes historical probe scripts
M12_PROBE PASS: fixture campaign definitions load
M12_PROBE PASS: fresh campaign configures
M12_PROBE PASS: WorldMapScene loads
M12_PROBE PASS: entries are generated from LevelDatabase
M12_PROBE PASS: Sunny Cove is selectable on fresh state
M12_PROBE PASS: Tiki Island is locked on fresh state
M12_PROBE PASS: locked Tiki selection is rejected
M12_PROBE PASS: locked feedback exposes reason and progress
M12_PROBE PASS: Sunny Cove selection emits id and navigation boundary
M12_PROBE PASS: 720x1280 layout has no horizontal clipping
M12_PROBE PASS: 720x1280 layout has no entry overlap
M12_PROBE PASS: visual map creates spatial markers
M12_PROBE PASS: canonical visual map definitions load
M12_PROBE PASS: fresh campaign configures
M12_PROBE PASS: canonical map displays ten planned destinations
M12_PROBE PASS: Sunny Cove is the only fresh selectable destination
M12_PROBE PASS: repeated Sunny Cove selection remains accepted
M12_PROBE PASS: repeated Sunny Cove selection remains accepted
M12_PROBE PASS: repeated Sunny Cove selection remains accepted
M12_PROBE PASS: repeated selection leaves no duplicate markers
M12_PROBE PASS: repeated selection emits one boundary per selection
M12_PROBE PASS: visual map 720x1280 geometry remains clean
M12_PROBE PASS: fixture campaign definitions load
M12_PROBE PASS: fresh campaign configures
M12_PROBE PASS: same entry/layout architecture handles ten islands
M12_PROBE PASS: fresh campaign configures
M12_PROBE PASS: COMPLETE state is derived from CampaignManager
M12_PROBE PASS: unlocked next island is rendered open
M12_PROBE PASS: CURRENT state follows campaign island selection
M12_PROBE PASS: World Map state survives isolated SaveManager round-trip
M12_WORLD_MAP_RESULT=PASS
```

### `M13-island-map`

Command: `godot_console.exe --headless --path . --script res://tests/m13_island_map_probe.gd`
Exit code: `0`; required marker: `M13_ISLAND_MAP_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M13_PROBE PASS: reusable IslandMapScene resource exists
M13_PROBE PASS: reusable LevelButton resource exists
M13_PROBE PASS: 100-level fixture loads in FULL validation
M13_PROBE PASS: fixture campaign configures from progression state
M13_PROBE PASS: generic IslandMapScene accepts island_id
M13_PROBE PASS: 100-level fixture renders 100 reusable nodes
M13_PROBE PASS: path is vertically scrollable at 720x1280
M13_PROBE PASS: path has no horizontal clipping at 720x1280
M13_PROBE PASS: path uses one reusable button scene
M13_PROBE PASS: state COMPLETE is rendered
M13_PROBE PASS: state OPEN is rendered
M13_PROBE PASS: state CURRENT is rendered
M13_PROBE PASS: state LOCKED is rendered
M13_PROBE PASS: 0 stars are preserved
M13_PROBE PASS: 1 star is preserved
M13_PROBE PASS: 2 stars are preserved
M13_PROBE PASS: 3 stars are preserved
M13_PROBE PASS: milestones are present at every tenth level
M13_PROBE PASS: focus chooses highest unlocked unfinished level
M13_PROBE PASS: locked level selection is rejected
M13_PROBE PASS: selectable level emits bounded selection event
M13_PROBE PASS: selection remains a boundary and does not launch gameplay
M13_PROBE PASS: repeated refresh has no duplicate level nodes
M13_PROBE PASS: summary exposes display name
M13_PROBE PASS: summary exposes completed/configured counts
M13_PROBE PASS: summary exposes earned stars
M13_PROBE PASS: summary exposes next milestone
M13_PROBE PASS: summary exposes incomplete state
M13_PROBE PASS: manual scroll position differs from automatic focus
M13_PROBE PASS: generic IslandMapScene accepts island_id
M13_PROBE PASS: selected level restores safely on re-entry
M13_PROBE PASS: scroll focus restores safely on re-entry
M13_PROBE PASS: actual scroll position restores exactly
M13_PROBE PASS: back navigation emits World Map boundary
M13_PROBE PASS: fixture campaign configures from progression state
M13_PROBE PASS: campaign selection is deliberately lower before first entry
M13_PROBE PASS: generic IslandMapScene accepts island_id
M13_PROBE PASS: first-entry focus ignores lower campaign selection
M13_PROBE PASS: fixture campaign configures from progression state
M13_PROBE PASS: navigation campaign selection is lower before first entry
M13_PROBE PASS: campaign navigation host accepts canonical campaign authority
M13_PROBE PASS: navigation host owns one World Map and one Island Map
M13_PROBE PASS: first host entry computes highest unfinished focus
M13_PROBE PASS: actual M12 signal opens M13
M13_PROBE PASS: M12 signal passes exact island id
M13_PROBE PASS: actual scroll survives M12 re-entry
M13_PROBE PASS: selected/focus restoration survives M12 re-entry
M13_PROBE PASS: M13 back returns to M12 World Map
M13_PROBE PASS: repeated M12-M13 transitions do not duplicate map instances
M13_PROBE PASS: fixture campaign configures from progression state
M13_PROBE PASS: generic IslandMapScene accepts island_id
M13_PROBE PASS: save/progression reload preserves completion
M13_PROBE PASS: save/progression reload preserves stars
M13_PROBE PASS: fixture campaign configures from progression state
M13_PROBE PASS: generic IslandMapScene accepts island_id
M13_PROBE PASS: all-complete map keeps 100 nodes
M13_PROBE PASS: all-complete map focuses final configured level
M13_PROBE PASS: all-complete summary reports completion
M13_ISLAND_MAP_RESULT=PASS
```

### `M14-gameplay-session-bridge`

Command: `godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd`
Exit code: `0`; required marker: `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M14_PROBE PASS: M14 fixture loads in FULL validation
M14_PROBE PASS: CampaignManager configures M14 fixture
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: M13 selection identity enters exact session
M14_PROBE PASS: session snapshot includes immutable level definition
M14_PROBE PASS: session snapshot carries timer, orders, VIP, rewards, thresholds, flags
M14_PROBE PASS: duplicate active session is rejected
M14_PROBE PASS: locked level selection is rejected
M14_PROBE PASS: canonical definition remains unchanged after snapshot
M14_PROBE PASS: timer starts only after gameplay ready
M14_PROBE PASS: active timer decrements from one authoritative value
M14_PROBE PASS: legitimate pause freezes timer
M14_PROBE PASS: paused timer does not drain
M14_PROBE PASS: resume restores active timer
M14_PROBE PASS: background pause freezes timer
M14_PROBE PASS: background-paused timer does not drain
M14_PROBE PASS: background resume restores timer
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: timeout resolves one deterministic LOSE
M14_PROBE PASS: terminal timeout does not repeat or go negative
M14_PROBE PASS: timeout does not advance progression
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: normal quantity ledger starts at 2xL6 then L7
M14_PROBE PASS: stored qualifying L6 can satisfy a later campaign order
M14_PROBE PASS: second quantity is required before advancing order
M14_PROBE PASS: incomplete VIP never blocks normal WIN
M14_PROBE PASS: score-only completion cannot earn three stars
M14_PROBE PASS: WIN progression is submitted exactly once
M14_PROBE PASS: WIN stops timer
M14_PROBE PASS: CampaignManager configures M14 fixture
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: VIP completion with insufficient three-star score earns two stars
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: VIP completion with three-star score earns three stars
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: plain normal completion earns one star
M14_PROBE PASS: Retry creates a fresh READY session from original definition
M14_PROBE PASS: worse replay cannot lower best score or stars
M14_PROBE PASS: Next Level resolves only an unlocked next level
M14_PROBE PASS: next-level session starts with clean objective/timer state
M14_PROBE PASS: Island Map return preserves exact island boundary
M14_PROBE PASS: configured app entry is the reusable application shell
M14_PROBE PASS: configured entry owns the real M13 navigation host
M14_PROBE PASS: M13 navigation host configures exact fixture campaign
M14_PROBE PASS: navigation owns one reusable map pair
M14_PROBE PASS: real M12 World Map selection enters the exact M13 Island Map
M14_PROBE PASS: M13 level selection launches existing gameplay scene through M14
M14_PROBE PASS: production selection enters GAMEPLAY with one instance
M14_PROBE PASS: production gameplay pause hook pauses the active bridge
M14_PROBE PASS: production gameplay pause hook freezes the timer
M14_PROBE PASS: production gameplay resume hook resumes the active bridge
M14_PROBE PASS: production gameplay resume hook allows timer progress
M14_PROBE PASS: production application pause notification freezes the bridge timer
M14_PROBE PASS: production application resume notification resumes background-paused gameplay
M14_PROBE PASS: pre-existing user pause survives application resume
M14_PROBE PASS: terminal gameplay is not resumed by application lifecycle
M14_PROBE PASS: Retry path is bounded and does not duplicate gameplay
M14_PROBE PASS: Retry remains the same exact level
M14_PROBE PASS: Island Map path returns through bridge boundary
M14_PROBE PASS: Island Map return has no duplicate gameplay instance
M14_PROBE PASS: final canonical definition remains unchanged
M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS
```

### `M15-vip-boosters-economy`

Command: `godot_console.exe --headless --path . --script res://tests/m15_vip_boosters_economy_probe.gd`
Exit code: `0`; required marker: `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M15_PROBE PASS: M15 fixture loads in FULL validation
M15_PROBE PASS: shared policy accepts normal/VIP L5
M15_PROBE PASS: shared policy accepts normal/VIP L8
M15_PROBE PASS: shared policy rejects normal/VIP L4
M15_PROBE PASS: shared policy rejects normal/VIP L9
M15_PROBE PASS: VIP zero quantity rejects
M15_PROBE PASS: VIP fractional quantity rejects
M15_PROBE PASS: disabled VIP metadata remains valid
M15_PROBE PASS: typed booster reward grants inventory
M15_PROBE PASS: reward ledger makes replay idempotent
M15_PROBE PASS: invalid reward fails closed without partial mutation
M15_PROBE PASS: insufficient booster consumption is non-mutating
M15_PROBE PASS: successful booster consumption is exact
M15_PROBE PASS: SaveManager persists economy balances and ledger
M15_PROBE PASS: pre-M15 valid save loads with empty ledger
M15_PROBE PASS: CampaignManager configures with shared economy
M15_PROBE PASS: GameplaySessionBridge configures with shared economy
M15_PROBE PASS: VIP session exposes exact target and pending 0/2 state
M15_PROBE PASS: +Time applies positive extension and consumes one item
M15_PROBE PASS: +Time with empty inventory does not consume or extend
M15_PROBE PASS: mismatched and nonpositive VIP deliveries pay zero
M15_PROBE PASS: paused VIP delivery pays zero
M15_PROBE PASS: GameplaySessionBridge configures with shared economy
M15_PROBE PASS: incomplete VIP still produces normal WIN
M15_PROBE PASS: incomplete VIP grants no VIP booster
M15_PROBE PASS: CampaignManager configures with shared economy
M15_PROBE PASS: GameplaySessionBridge configures with shared economy
M15_PROBE PASS: LOSE does not dispatch configured level or VIP rewards
M15_PROBE PASS: ineligible milestone is rejected without reward
M15_PROBE PASS: eligible milestone grants once and records claim
M15_PROBE PASS: milestone reward dispatch preserves progression independence
M15_PROBE PASS: production navigation exposes the same economy authority
M15_PROBE PASS: runtime selection reuses the shared bridge/economy
M15_PROBE PASS: production normal target is L6 and VIP target is L8
M15_PROBE PASS: combined owner-approved V06 HUD asset is active
M15_PROBE PASS: combined HUD keeps width and derives the tall V06 height
M15_PROBE PASS: obsolete procedural VIP card is absent
M15_PROBE PASS: normal target uses canonical cocktail and authoritative 0/1 progress
M15_PROBE PASS: normal reward remains Drink.order_reward
M15_PROBE PASS: VIP target reuses canonical cocktail texture
M15_PROBE PASS: normal and VIP cocktail slots share one scaling policy
M15_PROBE PASS: VIP pending presentation shows 0/N and doubled reward
M15_CAPTURE_UNAVAILABLE name=normal_vip_pending reason=HEADLESS_DISPLAY
MERGE L8 +1000  COMBO x1 +0  (toplam: 1000)
M15_PROBE PASS: newly merged VIP drink enters production capture
VIP DELIVERY L8 +1/2 BONUS 6000 (toplam: 7000)
M15_PROBE PASS: merged VIP receives exact 2x unit payout
M15_PROBE PASS: first actual VIP delivery accumulates 1/2
M15_PROBE PASS: VIP partial presentation shows 1/N without debug words
M15_CAPTURE_UNAVAILABLE name=normal_vip_partial reason=HEADLESS_DISPLAY
M15_PROBE PASS: stored VIP drink enters production capture
VIP DELIVERY L8 +2/2 BONUS 6000 (toplam: 13000)
M15_PROBE PASS: stored VIP receives exact 2x unit payout
M15_PROBE PASS: second actual VIP delivery completes cumulative 2/2
M15_PROBE PASS: VIP completed presentation replaces the fraction with a check mark
M15_CAPTURE_UNAVAILABLE name=normal_vip_completed reason=HEADLESS_DISPLAY
MERGE L8 +1000  COMBO x2 +250  (toplam: 14250)
M15_PROBE PASS: extra VIP delivery after completion is idempotent
M15_PROBE PASS: extra VIP delivery after completion pays zero
M15_PROBE PASS: normal L6 enters its separate production capture
TO-GO ORDER L6 +1000  (toplam: 15250)
M15_PROBE PASS: normal L6 delivery remains 1x payout
M15_PROBE PASS: normal progress reflects authoritative completed/required state
M15_PROBE PASS: terminal result score includes VIP bonuses
M15_PROBE PASS: normal WIN follows VIP completion and grants reward once
M15_PROBE PASS: repeated WIN resolution does not duplicate reward
MERGE L6 +350  COMBO x1 +0  (toplam: 350)
TO-GO ORDER L6 +1000  (toplam: 1350)
M15_PROBE PASS: same-level normal delivery claims first
M15_PROBE PASS: same-level later L6 remains protected while useful for mandatory L8
M15_CAPTURE_UNAVAILABLE name=non_vip_0_of_0 reason=HEADLESS_DISPLAY
M15_PROBE PASS: non-VIP keeps the combined panel visible
M15_PROBE PASS: non-VIP shows persistent 0/0 with no VIP reward
M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS
```

### `M16-sunny-cove-content`

Command: `godot_console.exe --headless --path . --script res://tests/m16_sunny_cove_content_probe.gd`
Exit code: `0`; required marker: `M16_SUNNY_COVE_CONTENT_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M16_PROBE PASS: approved expected table contains 100 timers
M16_PROBE PASS: approved expected table contains 100 costs
M16_PROBE PASS: approved expected table contains 100 order rows
M16_PROBE PASS: canonical Sunny Cove loads in FULL validation mode
M16_PROBE PASS: Sunny Cove declares 100 levels
M16_PROBE PASS: canonical Sunny Cove has exactly 100 loaded levels
M16_PROBE PASS: exactly 25 VIP levels are configured
M16_PROBE PASS: L1 id is sequential
M16_PROBE PASS: L1 island reference is Sunny Cove
M16_PROBE PASS: L1 matches the approved normal objective row
M16_PROBE PASS: L1 matches the approved timer row
M16_PROBE PASS: L1 matches the approved merge-cost row
M16_PROBE PASS: L1 normal targets stay within L5-L8
M16_PROBE PASS: L1 is non-VIP with neutral payload
M16_PROBE PASS: L1 normal objective cost follows the merge model
M16_PROBE PASS: L2 id is sequential
M16_PROBE PASS: L2 island reference is Sunny Cove
M16_PROBE PASS: L2 matches the approved normal objective row
M16_PROBE PASS: L2 matches the approved timer row
M16_PROBE PASS: L2 matches the approved merge-cost row
M16_PROBE PASS: L2 normal targets stay within L5-L8
M16_PROBE PASS: L2 is non-VIP with neutral payload
M16_PROBE PASS: L2 normal objective cost follows the merge model
M16_PROBE PASS: L3 id is sequential
M16_PROBE PASS: L3 island reference is Sunny Cove
M16_PROBE PASS: L3 matches the approved normal objective row
M16_PROBE PASS: L3 matches the approved timer row
M16_PROBE PASS: L3 matches the approved merge-cost row
M16_PROBE PASS: L3 normal targets stay within L5-L8
M16_PROBE PASS: L3 is non-VIP with neutral payload
M16_PROBE PASS: L3 normal objective cost follows the merge model
M16_PROBE PASS: L4 id is sequential
M16_PROBE PASS: L4 island reference is Sunny Cove
M16_PROBE PASS: L4 matches the approved normal objective row
M16_PROBE PASS: L4 matches the approved timer row
M16_PROBE PASS: L4 matches the approved merge-cost row
M16_PROBE PASS: L4 normal targets stay within L5-L8
M16_PROBE PASS: L4 exact VIP target and quantity
M16_PROBE PASS: L4 exact VIP reward
M16_PROBE PASS: L4 VIP workload ratio follows owner policy
M16_PROBE PASS: L4 VIP feature flag is enabled
M16_PROBE PASS: L4 normal objective cost follows the merge model
M16_PROBE PASS: L5 id is sequential
M16_PROBE PASS: L5 island reference is Sunny Cove
M16_PROBE PASS: L5 matches the approved normal objective row
M16_PROBE PASS: L5 matches the approved timer row
M16_PROBE PASS: L5 matches the approved merge-cost row
M16_PROBE PASS: L5 normal targets stay within L5-L8
M16_PROBE PASS: L5 is non-VIP with neutral payload
M16_PROBE PASS: L5 normal objective cost follows the merge model
M16_PROBE PASS: L6 id is sequential
M16_PROBE PASS: L6 island reference is Sunny Cove
M16_PROBE PASS: L6 matches the approved normal objective row
M16_PROBE PASS: L6 matches the approved timer row
M16_PROBE PASS: L6 matches the approved merge-cost row
M16_PROBE PASS: L6 normal targets stay within L5-L8
M16_PROBE PASS: L6 is non-VIP with neutral payload
M16_PROBE PASS: L6 normal objective cost follows the merge model
M16_PROBE PASS: L7 id is sequential
M16_PROBE PASS: L7 island reference is Sunny Cove
M16_PROBE PASS: L7 matches the approved normal objective row
M16_PROBE PASS: L7 matches the approved timer row
M16_PROBE PASS: L7 matches the approved merge-cost row
M16_PROBE PASS: L7 normal targets stay within L5-L8
M16_PROBE PASS: L7 is non-VIP with neutral payload
M16_PROBE PASS: L7 normal objective cost follows the merge model
M16_PROBE PASS: L8 id is sequential
M16_PROBE PASS: L8 island reference is Sunny Cove
M16_PROBE PASS: L8 matches the approved normal objective row
M16_PROBE PASS: L8 matches the approved timer row
M16_PROBE PASS: L8 matches the approved merge-cost row
M16_PROBE PASS: L8 normal targets stay within L5-L8
M16_PROBE PASS: L8 exact VIP target and quantity
M16_PROBE PASS: L8 exact VIP reward
M16_PROBE PASS: L8 VIP workload ratio follows owner policy
M16_PROBE PASS: L8 VIP feature flag is enabled
M16_PROBE PASS: L8 normal objective cost follows the merge model
M16_PROBE PASS: L9 id is sequential
M16_PROBE PASS: L9 island reference is Sunny Cove
M16_PROBE PASS: L9 matches the approved normal objective row
M16_PROBE PASS: L9 matches the approved timer row
M16_PROBE PASS: L9 matches the approved merge-cost row
M16_PROBE PASS: L9 normal targets stay within L5-L8
M16_PROBE PASS: L9 is non-VIP with neutral payload
M16_PROBE PASS: L9 normal objective cost follows the merge model
M16_PROBE PASS: L10 id is sequential
M16_PROBE PASS: L10 island reference is Sunny Cove
M16_PROBE PASS: L10 matches the approved normal objective row
M16_PROBE PASS: L10 matches the approved timer row
M16_PROBE PASS: L10 matches the approved merge-cost row
M16_PROBE PASS: L10 normal targets stay within L5-L8
M16_PROBE PASS: L10 is non-VIP with neutral payload
M16_PROBE PASS: L10 normal objective cost follows the merge model
M16_PROBE PASS: L11 id is sequential
M16_PROBE PASS: L11 island reference is Sunny Cove
M16_PROBE PASS: L11 matches the approved normal objective row
M16_PROBE PASS: L11 matches the approved timer row
M16_PROBE PASS: L11 matches the approved merge-cost row
M16_PROBE PASS: L11 normal targets stay within L5-L8
M16_PROBE PASS: L11 is non-VIP with neutral payload
M16_PROBE PASS: L11 normal objective cost follows the merge model
M16_PROBE PASS: L12 id is sequential
M16_PROBE PASS: L12 island reference is Sunny Cove
M16_PROBE PASS: L12 matches the approved normal objective row
M16_PROBE PASS: L12 matches the approved timer row
M16_PROBE PASS: L12 matches the approved merge-cost row
M16_PROBE PASS: L12 normal targets stay within L5-L8
M16_PROBE PASS: L12 exact VIP target and quantity
M16_PROBE PASS: L12 exact VIP reward
M16_PROBE PASS: L12 VIP workload ratio follows owner policy
M16_PROBE PASS: L12 VIP feature flag is enabled
M16_PROBE PASS: L12 normal objective cost follows the merge model
M16_PROBE PASS: L13 id is sequential
M16_PROBE PASS: L13 island reference is Sunny Cove
M16_PROBE PASS: L13 matches the approved normal objective row
M16_PROBE PASS: L13 matches the approved timer row
M16_PROBE PASS: L13 matches the approved merge-cost row
M16_PROBE PASS: L13 normal targets stay within L5-L8
M16_PROBE PASS: L13 is non-VIP with neutral payload
M16_PROBE PASS: L13 normal objective cost follows the merge model
M16_PROBE PASS: L14 id is sequential
M16_PROBE PASS: L14 island reference is Sunny Cove
M16_PROBE PASS: L14 matches the approved normal objective row
M16_PROBE PASS: L14 matches the approved timer row
M16_PROBE PASS: L14 matches the approved merge-cost row
M16_PROBE PASS: L14 normal targets stay within L5-L8
M16_PROBE PASS: L14 is non-VIP with neutral payload
M16_PROBE PASS: L14 normal objective cost follows the merge model
M16_PROBE PASS: L15 id is sequential
M16_PROBE PASS: L15 island reference is Sunny Cove
M16_PROBE PASS: L15 matches the approved normal objective row
M16_PROBE PASS: L15 matches the approved timer row
M16_PROBE PASS: L15 matches the approved merge-cost row
M16_PROBE PASS: L15 normal targets stay within L5-L8
M16_PROBE PASS: L15 is non-VIP with neutral payload
M16_PROBE PASS: L15 normal objective cost follows the merge model
M16_PROBE PASS: L16 id is sequential
M16_PROBE PASS: L16 island reference is Sunny Cove
M16_PROBE PASS: L16 matches the approved normal objective row
M16_PROBE PASS: L16 matches the approved timer row
M16_PROBE PASS: L16 matches the approved merge-cost row
M16_PROBE PASS: L16 normal targets stay within L5-L8
M16_PROBE PASS: L16 exact VIP target and quantity
M16_PROBE PASS: L16 exact VIP reward
M16_PROBE PASS: L16 VIP workload ratio follows owner policy
M16_PROBE PASS: L16 VIP feature flag is enabled
M16_PROBE PASS: L16 normal objective cost follows the merge model
M16_PROBE PASS: L17 id is sequential
M16_PROBE PASS: L17 island reference is Sunny Cove
M16_PROBE PASS: L17 matches the approved normal objective row
M16_PROBE PASS: L17 matches the approved timer row
M16_PROBE PASS: L17 matches the approved merge-cost row
M16_PROBE PASS: L17 normal targets stay within L5-L8
M16_PROBE PASS: L17 is non-VIP with neutral payload
M16_PROBE PASS: L17 normal objective cost follows the merge model
M16_PROBE PASS: L18 id is sequential
M16_PROBE PASS: L18 island reference is Sunny Cove
M16_PROBE PASS: L18 matches the approved normal objective row
M16_PROBE PASS: L18 matches the approved timer row
M16_PROBE PASS: L18 matches the approved merge-cost row
M16_PROBE PASS: L18 normal targets stay within L5-L8
M16_PROBE PASS: L18 is non-VIP with neutral payload
M16_PROBE PASS: L18 normal objective cost follows the merge model
M16_PROBE PASS: L19 id is sequential
M16_PROBE PASS: L19 island reference is Sunny Cove
M16_PROBE PASS: L19 matches the approved normal objective row
M16_PROBE PASS: L19 matches the approved timer row
M16_PROBE PASS: L19 matches the approved merge-cost row
M16_PROBE PASS: L19 normal targets stay within L5-L8
M16_PROBE PASS: L19 is non-VIP with neutral payload
M16_PROBE PASS: L19 normal objective cost follows the merge model
M16_PROBE PASS: L20 id is sequential
M16_PROBE PASS: L20 island reference is Sunny Cove
M16_PROBE PASS: L20 matches the approved normal objective row
M16_PROBE PASS: L20 matches the approved timer row
M16_PROBE PASS: L20 matches the approved merge-cost row
M16_PROBE PASS: L20 normal targets stay within L5-L8
M16_PROBE PASS: L20 exact VIP target and quantity
M16_PROBE PASS: L20 exact VIP reward
M16_PROBE PASS: L20 VIP workload ratio follows owner policy
M16_PROBE PASS: L20 VIP feature flag is enabled
M16_PROBE PASS: L20 normal objective cost follows the merge model
M16_PROBE PASS: L21 id is sequential
M16_PROBE PASS: L21 island reference is Sunny Cove
M16_PROBE PASS: L21 matches the approved normal objective row
M16_PROBE PASS: L21 matches the approved timer row
M16_PROBE PASS: L21 matches the approved merge-cost row
M16_PROBE PASS: L21 normal targets stay within L5-L8
M16_PROBE PASS: L21 is non-VIP with neutral payload
M16_PROBE PASS: L21 normal objective cost follows the merge model
M16_PROBE PASS: L22 id is sequential
M16_PROBE PASS: L22 island reference is Sunny Cove
M16_PROBE PASS: L22 matches the approved normal objective row
M16_PROBE PASS: L22 matches the approved timer row
M16_PROBE PASS: L22 matches the approved merge-cost row
M16_PROBE PASS: L22 normal targets stay within L5-L8
M16_PROBE PASS: L22 is non-VIP with neutral payload
M16_PROBE PASS: L22 normal objective cost follows the merge model
M16_PROBE PASS: L23 id is sequential
M16_PROBE PASS: L23 island reference is Sunny Cove
M16_PROBE PASS: L23 matches the approved normal objective row
M16_PROBE PASS: L23 matches the approved timer row
M16_PROBE PASS: L23 matches the approved merge-cost row
M16_PROBE PASS: L23 normal targets stay within L5-L8
M16_PROBE PASS: L23 is non-VIP with neutral payload
M16_PROBE PASS: L23 normal objective cost follows the merge model
M16_PROBE PASS: L24 id is sequential
M16_PROBE PASS: L24 island reference is Sunny Cove
M16_PROBE PASS: L24 matches the approved normal objective row
M16_PROBE PASS: L24 matches the approved timer row
M16_PROBE PASS: L24 matches the approved merge-cost row
M16_PROBE PASS: L24 normal targets stay within L5-L8
M16_PROBE PASS: L24 exact VIP target and quantity
M16_PROBE PASS: L24 exact VIP reward
M16_PROBE PASS: L24 VIP workload ratio follows owner policy
M16_PROBE PASS: L24 VIP feature flag is enabled
M16_PROBE PASS: L24 normal objective cost follows the merge model
M16_PROBE PASS: L25 id is sequential
M16_PROBE PASS: L25 island reference is Sunny Cove
M16_PROBE PASS: L25 matches the approved normal objective row
M16_PROBE PASS: L25 matches the approved timer row
M16_PROBE PASS: L25 matches the approved merge-cost row
M16_PROBE PASS: L25 normal targets stay within L5-L8
M16_PROBE PASS: L25 is non-VIP with neutral payload
M16_PROBE PASS: L25 normal objective cost follows the merge model
M16_PROBE PASS: L26 id is sequential
M16_PROBE PASS: L26 island reference is Sunny Cove
M16_PROBE PASS: L26 matches the approved normal objective row
M16_PROBE PASS: L26 matches the approved timer row
M16_PROBE PASS: L26 matches the approved merge-cost row
M16_PROBE PASS: L26 normal targets stay within L5-L8
M16_PROBE PASS: L26 is non-VIP with neutral payload
M16_PROBE PASS: L26 normal objective cost follows the merge model
M16_PROBE PASS: L27 id is sequential
M16_PROBE PASS: L27 island reference is Sunny Cove
M16_PROBE PASS: L27 matches the approved normal objective row
M16_PROBE PASS: L27 matches the approved timer row
M16_PROBE PASS: L27 matches the approved merge-cost row
M16_PROBE PASS: L27 normal targets stay within L5-L8
M16_PROBE PASS: L27 is non-VIP with neutral payload
M16_PROBE PASS: L27 normal objective cost follows the merge model
M16_PROBE PASS: L28 id is sequential
M16_PROBE PASS: L28 island reference is Sunny Cove
M16_PROBE PASS: L28 matches the approved normal objective row
M16_PROBE PASS: L28 matches the approved timer row
M16_PROBE PASS: L28 matches the approved merge-cost row
M16_PROBE PASS: L28 normal targets stay within L5-L8
M16_PROBE PASS: L28 exact VIP target and quantity
M16_PROBE PASS: L28 exact VIP reward
M16_PROBE PASS: L28 VIP workload ratio follows owner policy
M16_PROBE PASS: L28 VIP feature flag is enabled
M16_PROBE PASS: L28 normal objective cost follows the merge model
M16_PROBE PASS: L29 id is sequential
M16_PROBE PASS: L29 island reference is Sunny Cove
M16_PROBE PASS: L29 matches the approved normal objective row
M16_PROBE PASS: L29 matches the approved timer row
M16_PROBE PASS: L29 matches the approved merge-cost row
M16_PROBE PASS: L29 normal targets stay within L5-L8
M16_PROBE PASS: L29 is non-VIP with neutral payload
M16_PROBE PASS: L29 normal objective cost follows the merge model
M16_PROBE PASS: L30 id is sequential
M16_PROBE PASS: L30 island reference is Sunny Cove
M16_PROBE PASS: L30 matches the approved normal objective row
M16_PROBE PASS: L30 matches the approved timer row
M16_PROBE PASS: L30 matches the approved merge-cost row
M16_PROBE PASS: L30 normal targets stay within L5-L8
M16_PROBE PASS: L30 is non-VIP with neutral payload
M16_PROBE PASS: L30 normal objective cost follows the merge model
M16_PROBE PASS: L31 id is sequential
M16_PROBE PASS: L31 island reference is Sunny Cove
M16_PROBE PASS: L31 matches the approved normal objective row
M16_PROBE PASS: L31 matches the approved timer row
M16_PROBE PASS: L31 matches the approved merge-cost row
M16_PROBE PASS: L31 normal targets stay within L5-L8
M16_PROBE PASS: L31 is non-VIP with neutral payload
M16_PROBE PASS: L31 normal objective cost follows the merge model
M16_PROBE PASS: L32 id is sequential
M16_PROBE PASS: L32 island reference is Sunny Cove
M16_PROBE PASS: L32 matches the approved normal objective row
M16_PROBE PASS: L32 matches the approved timer row
M16_PROBE PASS: L32 matches the approved merge-cost row
M16_PROBE PASS: L32 normal targets stay within L5-L8
M16_PROBE PASS: L32 exact VIP target and quantity
M16_PROBE PASS: L32 exact VIP reward
M16_PROBE PASS: L32 VIP workload ratio follows owner policy
M16_PROBE PASS: L32 VIP feature flag is enabled
M16_PROBE PASS: L32 normal objective cost follows the merge model
M16_PROBE PASS: L33 id is sequential
M16_PROBE PASS: L33 island reference is Sunny Cove
M16_PROBE PASS: L33 matches the approved normal objective row
M16_PROBE PASS: L33 matches the approved timer row
M16_PROBE PASS: L33 matches the approved merge-cost row
M16_PROBE PASS: L33 normal targets stay within L5-L8
M16_PROBE PASS: L33 is non-VIP with neutral payload
M16_PROBE PASS: L33 normal objective cost follows the merge model
M16_PROBE PASS: L34 id is sequential
M16_PROBE PASS: L34 island reference is Sunny Cove
M16_PROBE PASS: L34 matches the approved normal objective row
M16_PROBE PASS: L34 matches the approved timer row
M16_PROBE PASS: L34 matches the approved merge-cost row
M16_PROBE PASS: L34 normal targets stay within L5-L8
M16_PROBE PASS: L34 is non-VIP with neutral payload
M16_PROBE PASS: L34 normal objective cost follows the merge model
M16_PROBE PASS: L35 id is sequential
M16_PROBE PASS: L35 island reference is Sunny Cove
M16_PROBE PASS: L35 matches the approved normal objective row
M16_PROBE PASS: L35 matches the approved timer row
M16_PROBE PASS: L35 matches the approved merge-cost row
M16_PROBE PASS: L35 normal targets stay within L5-L8
M16_PROBE PASS: L35 is non-VIP with neutral payload
M16_PROBE PASS: L35 normal objective cost follows the merge model
M16_PROBE PASS: L36 id is sequential
M16_PROBE PASS: L36 island reference is Sunny Cove
M16_PROBE PASS: L36 matches the approved normal objective row
M16_PROBE PASS: L36 matches the approved timer row
M16_PROBE PASS: L36 matches the approved merge-cost row
M16_PROBE PASS: L36 normal targets stay within L5-L8
M16_PROBE PASS: L36 exact VIP target and quantity
M16_PROBE PASS: L36 exact VIP reward
M16_PROBE PASS: L36 VIP workload ratio follows owner policy
M16_PROBE PASS: L36 VIP feature flag is enabled
M16_PROBE PASS: L36 normal objective cost follows the merge model
M16_PROBE PASS: L37 id is sequential
M16_PROBE PASS: L37 island reference is Sunny Cove
M16_PROBE PASS: L37 matches the approved normal objective row
M16_PROBE PASS: L37 matches the approved timer row
M16_PROBE PASS: L37 matches the approved merge-cost row
M16_PROBE PASS: L37 normal targets stay within L5-L8
M16_PROBE PASS: L37 is non-VIP with neutral payload
M16_PROBE PASS: L37 normal objective cost follows the merge model
M16_PROBE PASS: L38 id is sequential
M16_PROBE PASS: L38 island reference is Sunny Cove
M16_PROBE PASS: L38 matches the approved normal objective row
M16_PROBE PASS: L38 matches the approved timer row
M16_PROBE PASS: L38 matches the approved merge-cost row
M16_PROBE PASS: L38 normal targets stay within L5-L8
M16_PROBE PASS: L38 is non-VIP with neutral payload
M16_PROBE PASS: L38 normal objective cost follows the merge model
M16_PROBE PASS: L39 id is sequential
M16_PROBE PASS: L39 island reference is Sunny Cove
M16_PROBE PASS: L39 matches the approved normal objective row
M16_PROBE PASS: L39 matches the approved timer row
M16_PROBE PASS: L39 matches the approved merge-cost row
M16_PROBE PASS: L39 normal targets stay within L5-L8
M16_PROBE PASS: L39 is non-VIP with neutral payload
M16_PROBE PASS: L39 normal objective cost follows the merge model
M16_PROBE PASS: L40 id is sequential
M16_PROBE PASS: L40 island reference is Sunny Cove
M16_PROBE PASS: L40 matches the approved normal objective row
M16_PROBE PASS: L40 matches the approved timer row
M16_PROBE PASS: L40 matches the approved merge-cost row
M16_PROBE PASS: L40 normal targets stay within L5-L8
M16_PROBE PASS: L40 exact VIP target and quantity
M16_PROBE PASS: L40 exact VIP reward
M16_PROBE PASS: L40 VIP workload ratio follows owner policy
M16_PROBE PASS: L40 VIP feature flag is enabled
M16_PROBE PASS: L40 normal objective cost follows the merge model
M16_PROBE PASS: L41 id is sequential
M16_PROBE PASS: L41 island reference is Sunny Cove
M16_PROBE PASS: L41 matches the approved normal objective row
M16_PROBE PASS: L41 matches the approved timer row
M16_PROBE PASS: L41 matches the approved merge-cost row
M16_PROBE PASS: L41 normal targets stay within L5-L8
M16_PROBE PASS: L41 is non-VIP with neutral payload
M16_PROBE PASS: L41 normal objective cost follows the merge model
M16_PROBE PASS: L42 id is sequential
M16_PROBE PASS: L42 island reference is Sunny Cove
M16_PROBE PASS: L42 matches the approved normal objective row
M16_PROBE PASS: L42 matches the approved timer row
M16_PROBE PASS: L42 matches the approved merge-cost row
M16_PROBE PASS: L42 normal targets stay within L5-L8
M16_PROBE PASS: L42 is non-VIP with neutral payload
M16_PROBE PASS: L42 normal objective cost follows the merge model
M16_PROBE PASS: L43 id is sequential
M16_PROBE PASS: L43 island reference is Sunny Cove
M16_PROBE PASS: L43 matches the approved normal objective row
M16_PROBE PASS: L43 matches the approved timer row
M16_PROBE PASS: L43 matches the approved merge-cost row
M16_PROBE PASS: L43 normal targets stay within L5-L8
M16_PROBE PASS: L43 is non-VIP with neutral payload
M16_PROBE PASS: L43 normal objective cost follows the merge model
M16_PROBE PASS: L44 id is sequential
M16_PROBE PASS: L44 island reference is Sunny Cove
M16_PROBE PASS: L44 matches the approved normal objective row
M16_PROBE PASS: L44 matches the approved timer row
M16_PROBE PASS: L44 matches the approved merge-cost row
M16_PROBE PASS: L44 normal targets stay within L5-L8
M16_PROBE PASS: L44 exact VIP target and quantity
M16_PROBE PASS: L44 exact VIP reward
M16_PROBE PASS: L44 VIP workload ratio follows owner policy
M16_PROBE PASS: L44 VIP feature flag is enabled
M16_PROBE PASS: L44 normal objective cost follows the merge model
M16_PROBE PASS: L45 id is sequential
M16_PROBE PASS: L45 island reference is Sunny Cove
M16_PROBE PASS: L45 matches the approved normal objective row
M16_PROBE PASS: L45 matches the approved timer row
M16_PROBE PASS: L45 matches the approved merge-cost row
M16_PROBE PASS: L45 normal targets stay within L5-L8
M16_PROBE PASS: L45 is non-VIP with neutral payload
M16_PROBE PASS: L45 normal objective cost follows the merge model
M16_PROBE PASS: L46 id is sequential
M16_PROBE PASS: L46 island reference is Sunny Cove
M16_PROBE PASS: L46 matches the approved normal objective row
M16_PROBE PASS: L46 matches the approved timer row
M16_PROBE PASS: L46 matches the approved merge-cost row
M16_PROBE PASS: L46 normal targets stay within L5-L8
M16_PROBE PASS: L46 is non-VIP with neutral payload
M16_PROBE PASS: L46 normal objective cost follows the merge model
M16_PROBE PASS: L47 id is sequential
M16_PROBE PASS: L47 island reference is Sunny Cove
M16_PROBE PASS: L47 matches the approved normal objective row
M16_PROBE PASS: L47 matches the approved timer row
M16_PROBE PASS: L47 matches the approved merge-cost row
M16_PROBE PASS: L47 normal targets stay within L5-L8
M16_PROBE PASS: L47 is non-VIP with neutral payload
M16_PROBE PASS: L47 normal objective cost follows the merge model
M16_PROBE PASS: L48 id is sequential
M16_PROBE PASS: L48 island reference is Sunny Cove
M16_PROBE PASS: L48 matches the approved normal objective row
M16_PROBE PASS: L48 matches the approved timer row
M16_PROBE PASS: L48 matches the approved merge-cost row
M16_PROBE PASS: L48 normal targets stay within L5-L8
M16_PROBE PASS: L48 exact VIP target and quantity
M16_PROBE PASS: L48 exact VIP reward
M16_PROBE PASS: L48 VIP workload ratio follows owner policy
M16_PROBE PASS: L48 VIP feature flag is enabled
M16_PROBE PASS: L48 normal objective cost follows the merge model
M16_PROBE PASS: L49 id is sequential
M16_PROBE PASS: L49 island reference is Sunny Cove
M16_PROBE PASS: L49 matches the approved normal objective row
M16_PROBE PASS: L49 matches the approved timer row
M16_PROBE PASS: L49 matches the approved merge-cost row
M16_PROBE PASS: L49 normal targets stay within L5-L8
M16_PROBE PASS: L49 is non-VIP with neutral payload
M16_PROBE PASS: L49 normal objective cost follows the merge model
M16_PROBE PASS: L50 id is sequential
M16_PROBE PASS: L50 island reference is Sunny Cove
M16_PROBE PASS: L50 matches the approved normal objective row
M16_PROBE PASS: L50 matches the approved timer row
M16_PROBE PASS: L50 matches the approved merge-cost row
M16_PROBE PASS: L50 normal targets stay within L5-L8
M16_PROBE PASS: L50 is non-VIP with neutral payload
M16_PROBE PASS: L50 normal objective cost follows the merge model
M16_PROBE PASS: L51 id is sequential
M16_PROBE PASS: L51 island reference is Sunny Cove
M16_PROBE PASS: L51 matches the approved normal objective row
M16_PROBE PASS: L51 matches the approved timer row
M16_PROBE PASS: L51 matches the approved merge-cost row
M16_PROBE PASS: L51 normal targets stay within L5-L8
M16_PROBE PASS: L51 is non-VIP with neutral payload
M16_PROBE PASS: L51 normal objective cost follows the merge model
M16_PROBE PASS: L52 id is sequential
M16_PROBE PASS: L52 island reference is Sunny Cove
M16_PROBE PASS: L52 matches the approved normal objective row
M16_PROBE PASS: L52 matches the approved timer row
M16_PROBE PASS: L52 matches the approved merge-cost row
M16_PROBE PASS: L52 normal targets stay within L5-L8
M16_PROBE PASS: L52 exact VIP target and quantity
M16_PROBE PASS: L52 exact VIP reward
M16_PROBE PASS: L52 VIP workload ratio follows owner policy
M16_PROBE PASS: L52 VIP feature flag is enabled
M16_PROBE PASS: L52 normal objective cost follows the merge model
M16_PROBE PASS: L53 id is sequential
M16_PROBE PASS: L53 island reference is Sunny Cove
M16_PROBE PASS: L53 matches the approved normal objective row
M16_PROBE PASS: L53 matches the approved timer row
M16_PROBE PASS: L53 matches the approved merge-cost row
M16_PROBE PASS: L53 normal targets stay within L5-L8
M16_PROBE PASS: L53 is non-VIP with neutral payload
M16_PROBE PASS: L53 normal objective cost follows the merge model
M16_PROBE PASS: L54 id is sequential
M16_PROBE PASS: L54 island reference is Sunny Cove
M16_PROBE PASS: L54 matches the approved normal objective row
M16_PROBE PASS: L54 matches the approved timer row
M16_PROBE PASS: L54 matches the approved merge-cost row
M16_PROBE PASS: L54 normal targets stay within L5-L8
M16_PROBE PASS: L54 is non-VIP with neutral payload
M16_PROBE PASS: L54 normal objective cost follows the merge model
M16_PROBE PASS: L55 id is sequential
M16_PROBE PASS: L55 island reference is Sunny Cove
M16_PROBE PASS: L55 matches the approved normal objective row
M16_PROBE PASS: L55 matches the approved timer row
M16_PROBE PASS: L55 matches the approved merge-cost row
M16_PROBE PASS: L55 normal targets stay within L5-L8
M16_PROBE PASS: L55 is non-VIP with neutral payload
M16_PROBE PASS: L55 normal objective cost follows the merge model
M16_PROBE PASS: L56 id is sequential
M16_PROBE PASS: L56 island reference is Sunny Cove
M16_PROBE PASS: L56 matches the approved normal objective row
M16_PROBE PASS: L56 matches the approved timer row
M16_PROBE PASS: L56 matches the approved merge-cost row
M16_PROBE PASS: L56 normal targets stay within L5-L8
M16_PROBE PASS: L56 exact VIP target and quantity
M16_PROBE PASS: L56 exact VIP reward
M16_PROBE PASS: L56 VIP workload ratio follows owner policy
M16_PROBE PASS: L56 VIP feature flag is enabled
M16_PROBE PASS: L56 normal objective cost follows the merge model
M16_PROBE PASS: L57 id is sequential
M16_PROBE PASS: L57 island reference is Sunny Cove
M16_PROBE PASS: L57 matches the approved normal objective row
M16_PROBE PASS: L57 matches the approved timer row
M16_PROBE PASS: L57 matches the approved merge-cost row
M16_PROBE PASS: L57 normal targets stay within L5-L8
M16_PROBE PASS: L57 is non-VIP with neutral payload
M16_PROBE PASS: L57 normal objective cost follows the merge model
M16_PROBE PASS: L58 id is sequential
M16_PROBE PASS: L58 island reference is Sunny Cove
M16_PROBE PASS: L58 matches the approved normal objective row
M16_PROBE PASS: L58 matches the approved timer row
M16_PROBE PASS: L58 matches the approved merge-cost row
M16_PROBE PASS: L58 normal targets stay within L5-L8
M16_PROBE PASS: L58 is non-VIP with neutral payload
M16_PROBE PASS: L58 normal objective cost follows the merge model
M16_PROBE PASS: L59 id is sequential
M16_PROBE PASS: L59 island reference is Sunny Cove
M16_PROBE PASS: L59 matches the approved normal objective row
M16_PROBE PASS: L59 matches the approved timer row
M16_PROBE PASS: L59 matches the approved merge-cost row
M16_PROBE PASS: L59 normal targets stay within L5-L8
M16_PROBE PASS: L59 is non-VIP with neutral payload
M16_PROBE PASS: L59 normal objective cost follows the merge model
M16_PROBE PASS: L60 id is sequential
M16_PROBE PASS: L60 island reference is Sunny Cove
M16_PROBE PASS: L60 matches the approved normal objective row
M16_PROBE PASS: L60 matches the approved timer row
M16_PROBE PASS: L60 matches the approved merge-cost row
M16_PROBE PASS: L60 normal targets stay within L5-L8
M16_PROBE PASS: L60 exact VIP target and quantity
M16_PROBE PASS: L60 exact VIP reward
M16_PROBE PASS: L60 VIP workload ratio follows owner policy
M16_PROBE PASS: L60 VIP feature flag is enabled
M16_PROBE PASS: L60 normal objective cost follows the merge model
M16_PROBE PASS: L61 id is sequential
M16_PROBE PASS: L61 island reference is Sunny Cove
M16_PROBE PASS: L61 matches the approved normal objective row
M16_PROBE PASS: L61 matches the approved timer row
M16_PROBE PASS: L61 matches the approved merge-cost row
M16_PROBE PASS: L61 normal targets stay within L5-L8
M16_PROBE PASS: L61 is non-VIP with neutral payload
M16_PROBE PASS: L61 normal objective cost follows the merge model
M16_PROBE PASS: L62 id is sequential
M16_PROBE PASS: L62 island reference is Sunny Cove
M16_PROBE PASS: L62 matches the approved normal objective row
M16_PROBE PASS: L62 matches the approved timer row
M16_PROBE PASS: L62 matches the approved merge-cost row
M16_PROBE PASS: L62 normal targets stay within L5-L8
M16_PROBE PASS: L62 is non-VIP with neutral payload
M16_PROBE PASS: L62 normal objective cost follows the merge model
M16_PROBE PASS: L63 id is sequential
M16_PROBE PASS: L63 island reference is Sunny Cove
M16_PROBE PASS: L63 matches the approved normal objective row
M16_PROBE PASS: L63 matches the approved timer row
M16_PROBE PASS: L63 matches the approved merge-cost row
M16_PROBE PASS: L63 normal targets stay within L5-L8
M16_PROBE PASS: L63 is non-VIP with neutral payload
M16_PROBE PASS: L63 normal objective cost follows the merge model
M16_PROBE PASS: L64 id is sequential
M16_PROBE PASS: L64 island reference is Sunny Cove
M16_PROBE PASS: L64 matches the approved normal objective row
M16_PROBE PASS: L64 matches the approved timer row
M16_PROBE PASS: L64 matches the approved merge-cost row
M16_PROBE PASS: L64 normal targets stay within L5-L8
M16_PROBE PASS: L64 exact VIP target and quantity
M16_PROBE PASS: L64 exact VIP reward
M16_PROBE PASS: L64 VIP workload ratio follows owner policy
M16_PROBE PASS: L64 VIP feature flag is enabled
M16_PROBE PASS: L64 normal objective cost follows the merge model
M16_PROBE PASS: L65 id is sequential
M16_PROBE PASS: L65 island reference is Sunny Cove
M16_PROBE PASS: L65 matches the approved normal objective row
M16_PROBE PASS: L65 matches the approved timer row
M16_PROBE PASS: L65 matches the approved merge-cost row
M16_PROBE PASS: L65 normal targets stay within L5-L8
M16_PROBE PASS: L65 is non-VIP with neutral payload
M16_PROBE PASS: L65 normal objective cost follows the merge model
M16_PROBE PASS: L66 id is sequential
M16_PROBE PASS: L66 island reference is Sunny Cove
M16_PROBE PASS: L66 matches the approved normal objective row
M16_PROBE PASS: L66 matches the approved timer row
M16_PROBE PASS: L66 matches the approved merge-cost row
M16_PROBE PASS: L66 normal targets stay within L5-L8
M16_PROBE PASS: L66 is non-VIP with neutral payload
M16_PROBE PASS: L66 normal objective cost follows the merge model
M16_PROBE PASS: L67 id is sequential
M16_PROBE PASS: L67 island reference is Sunny Cove
M16_PROBE PASS: L67 matches the approved normal objective row
M16_PROBE PASS: L67 matches the approved timer row
M16_PROBE PASS: L67 matches the approved merge-cost row
M16_PROBE PASS: L67 normal targets stay within L5-L8
M16_PROBE PASS: L67 is non-VIP with neutral payload
M16_PROBE PASS: L67 normal objective cost follows the merge model
M16_PROBE PASS: L68 id is sequential
M16_PROBE PASS: L68 island reference is Sunny Cove
M16_PROBE PASS: L68 matches the approved normal objective row
M16_PROBE PASS: L68 matches the approved timer row
M16_PROBE PASS: L68 matches the approved merge-cost row
M16_PROBE PASS: L68 normal targets stay within L5-L8
M16_PROBE PASS: L68 exact VIP target and quantity
M16_PROBE PASS: L68 exact VIP reward
M16_PROBE PASS: L68 VIP workload ratio follows owner policy
M16_PROBE PASS: L68 VIP feature flag is enabled
M16_PROBE PASS: L68 normal objective cost follows the merge model
M16_PROBE PASS: L69 id is sequential
M16_PROBE PASS: L69 island reference is Sunny Cove
M16_PROBE PASS: L69 matches the approved normal objective row
M16_PROBE PASS: L69 matches the approved timer row
M16_PROBE PASS: L69 matches the approved merge-cost row
M16_PROBE PASS: L69 normal targets stay within L5-L8
M16_PROBE PASS: L69 is non-VIP with neutral payload
M16_PROBE PASS: L69 normal objective cost follows the merge model
M16_PROBE PASS: L70 id is sequential
M16_PROBE PASS: L70 island reference is Sunny Cove
M16_PROBE PASS: L70 matches the approved normal objective row
M16_PROBE PASS: L70 matches the approved timer row
M16_PROBE PASS: L70 matches the approved merge-cost row
M16_PROBE PASS: L70 normal targets stay within L5-L8
M16_PROBE PASS: L70 is non-VIP with neutral payload
M16_PROBE PASS: L70 normal objective cost follows the merge model
M16_PROBE PASS: L71 id is sequential
M16_PROBE PASS: L71 island reference is Sunny Cove
M16_PROBE PASS: L71 matches the approved normal objective row
M16_PROBE PASS: L71 matches the approved timer row
M16_PROBE PASS: L71 matches the approved merge-cost row
M16_PROBE PASS: L71 normal targets stay within L5-L8
M16_PROBE PASS: L71 is non-VIP with neutral payload
M16_PROBE PASS: L71 normal objective cost follows the merge model
M16_PROBE PASS: L72 id is sequential
M16_PROBE PASS: L72 island reference is Sunny Cove
M16_PROBE PASS: L72 matches the approved normal objective row
M16_PROBE PASS: L72 matches the approved timer row
M16_PROBE PASS: L72 matches the approved merge-cost row
M16_PROBE PASS: L72 normal targets stay within L5-L8
M16_PROBE PASS: L72 exact VIP target and quantity
M16_PROBE PASS: L72 exact VIP reward
M16_PROBE PASS: L72 VIP workload ratio follows owner policy
M16_PROBE PASS: L72 VIP feature flag is enabled
M16_PROBE PASS: L72 normal objective cost follows the merge model
M16_PROBE PASS: L73 id is sequential
M16_PROBE PASS: L73 island reference is Sunny Cove
M16_PROBE PASS: L73 matches the approved normal objective row
M16_PROBE PASS: L73 matches the approved timer row
M16_PROBE PASS: L73 matches the approved merge-cost row
M16_PROBE PASS: L73 normal targets stay within L5-L8
M16_PROBE PASS: L73 is non-VIP with neutral payload
M16_PROBE PASS: L73 normal objective cost follows the merge model
M16_PROBE PASS: L74 id is sequential
M16_PROBE PASS: L74 island reference is Sunny Cove
M16_PROBE PASS: L74 matches the approved normal objective row
M16_PROBE PASS: L74 matches the approved timer row
M16_PROBE PASS: L74 matches the approved merge-cost row
M16_PROBE PASS: L74 normal targets stay within L5-L8
M16_PROBE PASS: L74 is non-VIP with neutral payload
M16_PROBE PASS: L74 normal objective cost follows the merge model
M16_PROBE PASS: L75 id is sequential
M16_PROBE PASS: L75 island reference is Sunny Cove
M16_PROBE PASS: L75 matches the approved normal objective row
M16_PROBE PASS: L75 matches the approved timer row
M16_PROBE PASS: L75 matches the approved merge-cost row
M16_PROBE PASS: L75 normal targets stay within L5-L8
M16_PROBE PASS: L75 is non-VIP with neutral payload
M16_PROBE PASS: L75 normal objective cost follows the merge model
M16_PROBE PASS: L76 id is sequential
M16_PROBE PASS: L76 island reference is Sunny Cove
M16_PROBE PASS: L76 matches the approved normal objective row
M16_PROBE PASS: L76 matches the approved timer row
M16_PROBE PASS: L76 matches the approved merge-cost row
M16_PROBE PASS: L76 normal targets stay within L5-L8
M16_PROBE PASS: L76 exact VIP target and quantity
M16_PROBE PASS: L76 exact VIP reward
M16_PROBE PASS: L76 VIP workload ratio follows owner policy
M16_PROBE PASS: L76 VIP feature flag is enabled
M16_PROBE PASS: L76 normal objective cost follows the merge model
M16_PROBE PASS: L77 id is sequential
M16_PROBE PASS: L77 island reference is Sunny Cove
M16_PROBE PASS: L77 matches the approved normal objective row
M16_PROBE PASS: L77 matches the approved timer row
M16_PROBE PASS: L77 matches the approved merge-cost row
M16_PROBE PASS: L77 normal targets stay within L5-L8
M16_PROBE PASS: L77 is non-VIP with neutral payload
M16_PROBE PASS: L77 normal objective cost follows the merge model
M16_PROBE PASS: L78 id is sequential
M16_PROBE PASS: L78 island reference is Sunny Cove
M16_PROBE PASS: L78 matches the approved normal objective row
M16_PROBE PASS: L78 matches the approved timer row
M16_PROBE PASS: L78 matches the approved merge-cost row
M16_PROBE PASS: L78 normal targets stay within L5-L8
M16_PROBE PASS: L78 is non-VIP with neutral payload
M16_PROBE PASS: L78 normal objective cost follows the merge model
M16_PROBE PASS: L79 id is sequential
M16_PROBE PASS: L79 island reference is Sunny Cove
M16_PROBE PASS: L79 matches the approved normal objective row
M16_PROBE PASS: L79 matches the approved timer row
M16_PROBE PASS: L79 matches the approved merge-cost row
M16_PROBE PASS: L79 normal targets stay within L5-L8
M16_PROBE PASS: L79 is non-VIP with neutral payload
M16_PROBE PASS: L79 normal objective cost follows the merge model
M16_PROBE PASS: L80 id is sequential
M16_PROBE PASS: L80 island reference is Sunny Cove
M16_PROBE PASS: L80 matches the approved normal objective row
M16_PROBE PASS: L80 matches the approved timer row
M16_PROBE PASS: L80 matches the approved merge-cost row
M16_PROBE PASS: L80 normal targets stay within L5-L8
M16_PROBE PASS: L80 exact VIP target and quantity
M16_PROBE PASS: L80 exact VIP reward
M16_PROBE PASS: L80 VIP workload ratio follows owner policy
M16_PROBE PASS: L80 VIP feature flag is enabled
M16_PROBE PASS: L80 normal objective cost follows the merge model
M16_PROBE PASS: L81 id is sequential
M16_PROBE PASS: L81 island reference is Sunny Cove
M16_PROBE PASS: L81 matches the approved normal objective row
M16_PROBE PASS: L81 matches the approved timer row
M16_PROBE PASS: L81 matches the approved merge-cost row
M16_PROBE PASS: L81 normal targets stay within L5-L8
M16_PROBE PASS: L81 is non-VIP with neutral payload
M16_PROBE PASS: L81 normal objective cost follows the merge model
M16_PROBE PASS: L82 id is sequential
M16_PROBE PASS: L82 island reference is Sunny Cove
M16_PROBE PASS: L82 matches the approved normal objective row
M16_PROBE PASS: L82 matches the approved timer row
M16_PROBE PASS: L82 matches the approved merge-cost row
M16_PROBE PASS: L82 normal targets stay within L5-L8
M16_PROBE PASS: L82 is non-VIP with neutral payload
M16_PROBE PASS: L82 normal objective cost follows the merge model
M16_PROBE PASS: L83 id is sequential
M16_PROBE PASS: L83 island reference is Sunny Cove
M16_PROBE PASS: L83 matches the approved normal objective row
M16_PROBE PASS: L83 matches the approved timer row
M16_PROBE PASS: L83 matches the approved merge-cost row
M16_PROBE PASS: L83 normal targets stay within L5-L8
M16_PROBE PASS: L83 is non-VIP with neutral payload
M16_PROBE PASS: L83 normal objective cost follows the merge model
M16_PROBE PASS: L84 id is sequential
M16_PROBE PASS: L84 island reference is Sunny Cove
M16_PROBE PASS: L84 matches the approved normal objective row
M16_PROBE PASS: L84 matches the approved timer row
M16_PROBE PASS: L84 matches the approved merge-cost row
M16_PROBE PASS: L84 normal targets stay within L5-L8
M16_PROBE PASS: L84 exact VIP target and quantity
M16_PROBE PASS: L84 exact VIP reward
M16_PROBE PASS: L84 VIP workload ratio follows owner policy
M16_PROBE PASS: L84 VIP feature flag is enabled
M16_PROBE PASS: L84 normal objective cost follows the merge model
M16_PROBE PASS: L85 id is sequential
M16_PROBE PASS: L85 island reference is Sunny Cove
M16_PROBE PASS: L85 matches the approved normal objective row
M16_PROBE PASS: L85 matches the approved timer row
M16_PROBE PASS: L85 matches the approved merge-cost row
M16_PROBE PASS: L85 normal targets stay within L5-L8
M16_PROBE PASS: L85 is non-VIP with neutral payload
M16_PROBE PASS: L85 normal objective cost follows the merge model
M16_PROBE PASS: L86 id is sequential
M16_PROBE PASS: L86 island reference is Sunny Cove
M16_PROBE PASS: L86 matches the approved normal objective row
M16_PROBE PASS: L86 matches the approved timer row
M16_PROBE PASS: L86 matches the approved merge-cost row
M16_PROBE PASS: L86 normal targets stay within L5-L8
M16_PROBE PASS: L86 is non-VIP with neutral payload
M16_PROBE PASS: L86 normal objective cost follows the merge model
M16_PROBE PASS: L87 id is sequential
M16_PROBE PASS: L87 island reference is Sunny Cove
M16_PROBE PASS: L87 matches the approved normal objective row
M16_PROBE PASS: L87 matches the approved timer row
M16_PROBE PASS: L87 matches the approved merge-cost row
M16_PROBE PASS: L87 normal targets stay within L5-L8
M16_PROBE PASS: L87 is non-VIP with neutral payload
M16_PROBE PASS: L87 normal objective cost follows the merge model
M16_PROBE PASS: L88 id is sequential
M16_PROBE PASS: L88 island reference is Sunny Cove
M16_PROBE PASS: L88 matches the approved normal objective row
M16_PROBE PASS: L88 matches the approved timer row
M16_PROBE PASS: L88 matches the approved merge-cost row
M16_PROBE PASS: L88 normal targets stay within L5-L8
M16_PROBE PASS: L88 exact VIP target and quantity
M16_PROBE PASS: L88 exact VIP reward
M16_PROBE PASS: L88 VIP workload ratio follows owner policy
M16_PROBE PASS: L88 VIP feature flag is enabled
M16_PROBE PASS: L88 normal objective cost follows the merge model
M16_PROBE PASS: L89 id is sequential
M16_PROBE PASS: L89 island reference is Sunny Cove
M16_PROBE PASS: L89 matches the approved normal objective row
M16_PROBE PASS: L89 matches the approved timer row
M16_PROBE PASS: L89 matches the approved merge-cost row
M16_PROBE PASS: L89 normal targets stay within L5-L8
M16_PROBE PASS: L89 is non-VIP with neutral payload
M16_PROBE PASS: L89 normal objective cost follows the merge model
M16_PROBE PASS: L90 id is sequential
M16_PROBE PASS: L90 island reference is Sunny Cove
M16_PROBE PASS: L90 matches the approved normal objective row
M16_PROBE PASS: L90 matches the approved timer row
M16_PROBE PASS: L90 matches the approved merge-cost row
M16_PROBE PASS: L90 normal targets stay within L5-L8
M16_PROBE PASS: L90 is non-VIP with neutral payload
M16_PROBE PASS: L90 normal objective cost follows the merge model
M16_PROBE PASS: L91 id is sequential
M16_PROBE PASS: L91 island reference is Sunny Cove
M16_PROBE PASS: L91 matches the approved normal objective row
M16_PROBE PASS: L91 matches the approved timer row
M16_PROBE PASS: L91 matches the approved merge-cost row
M16_PROBE PASS: L91 normal targets stay within L5-L8
M16_PROBE PASS: L91 is non-VIP with neutral payload
M16_PROBE PASS: L91 normal objective cost follows the merge model
M16_PROBE PASS: L92 id is sequential
M16_PROBE PASS: L92 island reference is Sunny Cove
M16_PROBE PASS: L92 matches the approved normal objective row
M16_PROBE PASS: L92 matches the approved timer row
M16_PROBE PASS: L92 matches the approved merge-cost row
M16_PROBE PASS: L92 normal targets stay within L5-L8
M16_PROBE PASS: L92 exact VIP target and quantity
M16_PROBE PASS: L92 exact VIP reward
M16_PROBE PASS: L92 VIP workload ratio follows owner policy
M16_PROBE PASS: L92 VIP feature flag is enabled
M16_PROBE PASS: L92 normal objective cost follows the merge model
M16_PROBE PASS: L93 id is sequential
M16_PROBE PASS: L93 island reference is Sunny Cove
M16_PROBE PASS: L93 matches the approved normal objective row
M16_PROBE PASS: L93 matches the approved timer row
M16_PROBE PASS: L93 matches the approved merge-cost row
M16_PROBE PASS: L93 normal targets stay within L5-L8
M16_PROBE PASS: L93 is non-VIP with neutral payload
M16_PROBE PASS: L93 normal objective cost follows the merge model
M16_PROBE PASS: L94 id is sequential
M16_PROBE PASS: L94 island reference is Sunny Cove
M16_PROBE PASS: L94 matches the approved normal objective row
M16_PROBE PASS: L94 matches the approved timer row
M16_PROBE PASS: L94 matches the approved merge-cost row
M16_PROBE PASS: L94 normal targets stay within L5-L8
M16_PROBE PASS: L94 is non-VIP with neutral payload
M16_PROBE PASS: L94 normal objective cost follows the merge model
M16_PROBE PASS: L95 id is sequential
M16_PROBE PASS: L95 island reference is Sunny Cove
M16_PROBE PASS: L95 matches the approved normal objective row
M16_PROBE PASS: L95 matches the approved timer row
M16_PROBE PASS: L95 matches the approved merge-cost row
M16_PROBE PASS: L95 normal targets stay within L5-L8
M16_PROBE PASS: L95 is non-VIP with neutral payload
M16_PROBE PASS: L95 normal objective cost follows the merge model
M16_PROBE PASS: L96 id is sequential
M16_PROBE PASS: L96 island reference is Sunny Cove
M16_PROBE PASS: L96 matches the approved normal objective row
M16_PROBE PASS: L96 matches the approved timer row
M16_PROBE PASS: L96 matches the approved merge-cost row
M16_PROBE PASS: L96 normal targets stay within L5-L8
M16_PROBE PASS: L96 exact VIP target and quantity
M16_PROBE PASS: L96 exact VIP reward
M16_PROBE PASS: L96 VIP workload ratio follows owner policy
M16_PROBE PASS: L96 VIP feature flag is enabled
M16_PROBE PASS: L96 normal objective cost follows the merge model
M16_PROBE PASS: L97 id is sequential
M16_PROBE PASS: L97 island reference is Sunny Cove
M16_PROBE PASS: L97 matches the approved normal objective row
M16_PROBE PASS: L97 matches the approved timer row
M16_PROBE PASS: L97 matches the approved merge-cost row
M16_PROBE PASS: L97 normal targets stay within L5-L8
M16_PROBE PASS: L97 is non-VIP with neutral payload
M16_PROBE PASS: L97 normal objective cost follows the merge model
M16_PROBE PASS: L98 id is sequential
M16_PROBE PASS: L98 island reference is Sunny Cove
M16_PROBE PASS: L98 matches the approved normal objective row
M16_PROBE PASS: L98 matches the approved timer row
M16_PROBE PASS: L98 matches the approved merge-cost row
M16_PROBE PASS: L98 normal targets stay within L5-L8
M16_PROBE PASS: L98 is non-VIP with neutral payload
M16_PROBE PASS: L98 normal objective cost follows the merge model
M16_PROBE PASS: L99 id is sequential
M16_PROBE PASS: L99 island reference is Sunny Cove
M16_PROBE PASS: L99 matches the approved normal objective row
M16_PROBE PASS: L99 matches the approved timer row
M16_PROBE PASS: L99 matches the approved merge-cost row
M16_PROBE PASS: L99 normal targets stay within L5-L8
M16_PROBE PASS: L99 is non-VIP with neutral payload
M16_PROBE PASS: L99 normal objective cost follows the merge model
M16_PROBE PASS: L100 id is sequential
M16_PROBE PASS: L100 island reference is Sunny Cove
M16_PROBE PASS: L100 matches the approved normal objective row
M16_PROBE PASS: L100 matches the approved timer row
M16_PROBE PASS: L100 matches the approved merge-cost row
M16_PROBE PASS: L100 normal targets stay within L5-L8
M16_PROBE PASS: L100 exact VIP target and quantity
M16_PROBE PASS: L100 exact VIP reward
M16_PROBE PASS: L100 VIP workload ratio follows owner policy
M16_PROBE PASS: L100 VIP feature flag is enabled
M16_PROBE PASS: L100 normal objective cost follows the merge model
M16_PROBE PASS: merge cost L5 is 16
M16_PROBE PASS: merge cost L6 is 32
M16_PROBE PASS: merge cost L7 is 64
M16_PROBE PASS: merge cost L8 is 128
M16_PROBE PASS: Level 1 anchor is 1xL5 at 20 seconds
M16_PROBE PASS: Level 100 anchor is L8+L7+L6+L5 at 300 seconds
M16_PROBE PASS: VIP quantity mix is 15x qty1 and 10x qty2
M16_PROBE PASS: Upgrade cadence is exactly VIP levels 20/40/60/80/100
M16_PROBE PASS: all other VIP rewards are +Time
M16_PROBE PASS: 75 Sunny Cove levels remain non-VIP
M16_PROBE PASS: VIP cost is excluded from normal timer validation
M16_PROBE PASS: CampaignManager configures from the canonical FULL database
M16_PROBE PASS: Level 1 is initially selected and unlocked
M16_PROBE PASS: Level 2 starts locked before Level 1 completion
M16_PROBE PASS: all 100 levels follow the sequential unlock chain
M16_PROBE PASS: Level 100 closes Sunny Cove without a next level
M16_PROBE PASS: Level 100 preserves the next-island unlock boundary
M16_PROBE PASS: marker campaign configures
M16_PROBE PASS: Island Map configures from canonical VIP data
M16_PROBE PASS: VIP crown marker is visible for COMPLETE VIP level
M16_PROBE PASS: VIP crown marker is visible for OPEN VIP level
M16_PROBE PASS: VIP crown marker is visible for CURRENT VIP level
M16_PROBE PASS: VIP crown marker is visible for LOCKED VIP level
M16_PROBE PASS: non-VIP level has no crown marker
M16_PROBE PASS: crown marker uses the canonical gameplay VIP badge asset
M16_PROBE PASS: crown marker display size is exactly 36x36
M16_PROBE PASS: crown marker stays adjacent without covering the level node
M16_PROBE PASS: crown marker remains inside the map bounds on both path sides
M16_PROBE PASS: replay campaign configures with Level 4 unlocked
M16_PROBE PASS: replay bridge configures with economy
M16_PROBE PASS: first play can start canonical VIP Level 4
M16_PROBE PASS: normal WIN succeeds when VIP is missed
M16_PROBE PASS: missed VIP grants no booster and persists false
M16_PROBE PASS: completed VIP level remains replayable
M16_PROBE PASS: replay can complete the missed VIP
M16_PROBE PASS: replay persists VIP completion and grants +Time once
M16_PROBE PASS: replay again is allowed after VIP completion
M16_PROBE PASS: replay-after-replay keeps VIP completed
M16_PROBE PASS: VIP reward ledger prevents duplicate +Time reward
M16_PROBE PASS: normal content signature is unchanged after marker/replay flows
M16_SUNNY_COVE_CONTENT_RESULT=PASS
```

### `M17-vip-optionality`

Command: `godot_console.exe --headless --path . --script res://tests/m17_vip_optionality_probe.gd`
Exit code: `0`; required marker: `M17_VIP_OPTIONALITY_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M17_V05_PROBE PASS: F1 one L5 candidate is protected
M17_V05_PROBE PASS: F1 two L5 including candidate are protected
M17_V05_PROBE PASS: F1 third L5 becomes surplus
M17_V05_PROBE PASS: F2 higher L8 cannot satisfy lower L5
M17_V05_PROBE PASS: F2 exact L5 remains protected beside unsplittable L8
M17_V05_PROBE PASS: canonical data loads for L60/L100 planner fixtures
M17_V05_PROBE PASS: L60 mandatory reserve protects every normal piece
M17_V05_PROBE PASS: L60 extra VIP L7 is surplus
M17_V05_PROBE PASS: L100 mandatory reserve protects every normal piece
M17_V05_PROBE PASS: L100 extra VIP L7 is surplus
M17_V05_PROBE PASS: V05 fixture loads in FULL validation
M17_V05_PROBE PASS: V05 fixture campaign configures
M17_V05_PROBE PASS: real campaign navigation configures V05 fixture
M17_V05_PROBE PASS: real GameManager session opens
M17_V05_PROBE PASS: G stocked path protects first mandatory L5
TO-GO ORDER L6 +1000  (toplam: 1000)
M17_V05_PROBE PASS: protected normal L6 enters normal capture
M17_V05_PROBE PASS: G normal WIN succeeds with VIP intentionally missed
M17_V05_PROBE PASS: G missed VIP receives no booster reward
M17_V05_PROBE PASS: I first play persists vip_completed=false
M17_V05_PROBE PASS: return to Island Map succeeds after terminal session
M17_V05_PROBE PASS: replay creates a fresh real GameManager session
MERGE L5 +200  COMBO x1 +0  (toplam: 200)
M17_V05_PROBE PASS: H direct merged surplus L5 enters VIP capture
VIP DELIVERY L5 +1/1 BONUS 0 (toplam: 200)
M17_V05_PROBE PASS: H protected reserve remains after direct VIP capture
TO-GO ORDER L6 +1000  (toplam: 1200)
M17_V05_PROBE PASS: protected normal L6 enters normal capture
M17_V05_PROBE PASS: H normal WIN succeeds after surplus VIP delivery
M17_V05_PROBE PASS: H configured VIP reward grants exactly once
M17_V05_PROBE PASS: I replay persists vip_completed=true
M17_V05_PROBE PASS: return to Island Map succeeds after terminal session
M17_V05_PROBE PASS: replay creates a fresh real GameManager session
M17_V05_PROBE PASS: I stocked surplus L5 enters VIP capture
VIP DELIVERY L5 +1/1 BONUS 0 (toplam: 0)
M17_V05_PROBE PASS: I stocked VIP capture leaves mandatory reserve
TO-GO ORDER L6 +1000  (toplam: 1000)
M17_V05_PROBE PASS: protected normal L6 enters normal capture
M17_V05_PROBE PASS: I second replay still wins normally
M17_V05_PROBE PASS: I second replay does not duplicate VIP reward
M17_V05_PROBE PASS: I second replay keeps persisted vip_completed=true
M17_VIP_OPTIONALITY_RESULT=PASS
```

### `M17-V06-analytical`

Command: `godot_console.exe --headless --path . --script res://tests/m17_canonical_screening_v06_analytical_probe.gd`
Exit code: `0`; required marker: `M17_V06_ANALYTICAL_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M17_V06_ANALYTICAL PASS: canonical Sunny Cove loads in FULL mode
M17_V06_ANALYTICAL PASS: canonical dataset has exactly 100 levels
M17_V06_ANALYTICAL PASS: canonical dataset has exactly 45 challenge classes
M17_V06_ANALYTICAL PASS: all levels map once and class representatives are lowest IDs
M17_V06_ANALYTICAL PASS: all normal objectives are reachable with positive quantities and timers
M17_V06_ANALYTICAL PASS: timer/cost scan covers all levels
M17_V06_ANALYTICAL PASS: timer scan does not invent strict impossibility
M17_V06_ANALYTICAL PASS: V04 historical report is present and distinct
M17_V06_ANALYTICAL PASS: V05 post-fix forced result is 0/25
M17_V06_ANALYTICAL PASS: V05 post-fix surplus result is 25/25
M17_V06_ANALYTICAL PASS: V05 reports no validation errors
M17_V06_ANALYTICAL PASS: canonical Sunny Cove JSON is byte-for-byte unchanged
M17_V06_ANALYTICAL_RESULT=PASS levels=100 classes=45
```

### `M17-difficulty-validation`

Command: `godot_console.exe --headless --path . --script res://tests/m17_difficulty_validation_probe.gd`
Exit code: `0`; required marker: `M17_DIFFICULTY_VALIDATION_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M17_PROBE PASS: canonical Sunny Cove loads in FULL validation mode
M17_PROBE PASS: canonical Sunny Cove has 100 levels
M17_PROBE PASS: L1 objective cost is 16
M17_PROBE PASS: L100 objective cost is 240
M17_PROBE PASS: VIP cost is separate
M17_PROBE PASS: expected L1-equivalent spawn value is 7/3
M17_PROBE PASS: timer exposes named calibration
M17_PROBE PASS: timer calibration override changes raw and target time
M17_PROBE PASS: percentile uses deterministic R7 interpolation
M17_PROBE PASS: telemetry schema is complete
M17_PROBE PASS: same-level left target shifts action left
M17_PROBE PASS: same-level right target shifts action right
M17_PROBE PASS: left-side congestion selects a safer non-left lane
M17_PROBE PASS: identical board state produces identical action
M17_PROBE PASS: policy has no future-RNG input
M17_PROBE PASS: policy returns a legal horizontal bucket
M17_PROBE PASS: fixture GameManager is ready
M17_PROBE PASS: fixture campaign bridge starts
OYUN BITTI - Skor: 0
M17_PROBE PASS: danger fixture uses production danger-line/game-over path
M17_PROBE PASS: TABLE_DANGER fixture terminal reason is preserved
M17_PROBE PASS: TABLE_DANGER fixture outcome is danger
M17_PROBE PASS: TABLE_DANGER fixture is not timeout
M17_PROBE PASS: fixture GameManager is ready
M17_PROBE PASS: fixture campaign bridge starts
M17_PROBE PASS: timeout fixture expires the production campaign timer
M17_PROBE PASS: TIMEOUT fixture outcome is timeout and not danger
M17_PROBE PASS: controlled near-rail footprint creates one proxy event
M17_PROBE PASS: continuous proximity does not inflate the same edge event
M17_PROBE PASS: centered footprint does not create a false rail event
M17_PROBE PASS: release beyond 3px then re-entry creates a second event
M17_PROBE PASS: qualification runner policy time scale is canonical
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x2 +25  (toplam: 175)
MERGE L2 +20  COMBO x3 +10  (toplam: 205)
MERGE L3 +50  COMBO x1 +0  (toplam: 255)
MERGE L4 +100  COMBO x2 +25  (toplam: 380)
MERGE L2 +20  COMBO x1 +0  (toplam: 400)
MERGE L4 +100  COMBO x2 +25  (toplam: 525)
MERGE L4 +100  COMBO x1 +0  (toplam: 625)
MERGE L5 +200  COMBO x2 +50  (toplam: 875)
TO-GO ORDER L5 +0  (toplam: 875)
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x2 +25  (toplam: 175)
MERGE L2 +20  COMBO x3 +10  (toplam: 205)
MERGE L3 +50  COMBO x1 +0  (toplam: 255)
MERGE L4 +100  COMBO x2 +25  (toplam: 380)
MERGE L2 +20  COMBO x1 +0  (toplam: 400)
MERGE L4 +100  COMBO x2 +25  (toplam: 525)
MERGE L4 +100  COMBO x1 +0  (toplam: 625)
MERGE L5 +200  COMBO x2 +50  (toplam: 875)
TO-GO ORDER L5 +0  (toplam: 875)
M17_PROBE PASS: same seed produces the same action log
M17_PROBE PASS: same seed preserves logical outcome
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x2 +25  (toplam: 175)
MERGE L2 +20  COMBO x3 +10  (toplam: 205)
MERGE L3 +50  COMBO x1 +0  (toplam: 255)
MERGE L4 +100  COMBO x2 +25  (toplam: 380)
MERGE L2 +20  COMBO x1 +0  (toplam: 400)
MERGE L4 +100  COMBO x2 +25  (toplam: 525)
MERGE L4 +100  COMBO x1 +0  (toplam: 625)
MERGE L5 +200  COMBO x2 +50  (toplam: 875)
TO-GO ORDER L5 +0  (toplam: 875)
M17_PROBE PASS: exact action-log replay preserves logical result
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x1 +0  (toplam: 150)
MERGE L3 +50  COMBO x2 +13  (toplam: 213)
MERGE L4 +100  COMBO x3 +50  (toplam: 363)
MERGE L3 +50  COMBO x1 +0  (toplam: 413)
MERGE L4 +100  COMBO x1 +0  (toplam: 513)
MERGE L4 +100  COMBO x2 +25  (toplam: 638)
MERGE L2 +20  COMBO x1 +0  (toplam: 658)
MERGE L4 +100  COMBO x1 +0  (toplam: 758)
MERGE L5 +200  COMBO x2 +50  (toplam: 1008)
TO-GO ORDER L5 +0  (toplam: 1008)
M17_PROBE PASS: different seed changes the seeded action sequence
M17_PROBE PASS: focused trial telemetry validates
M17_PROBE PASS: merge-aware actions carry decision evidence
M17_PROBE PASS: canonical Sunny Cove JSON is byte-for-byte unchanged
M17_DIFFICULTY_VALIDATION_RESULT=PASS
```

### `M18-star-contract`

Command: `godot_console.exe --headless --path . --script res://tests/m18_star_contract_probe.gd`
Exit code: `0`; required marker: `M18_STAR_CONTRACT_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M18_STAR_PROBE PASS: incomplete result earns zero stars
M18_STAR_PROBE PASS: normal completion earns the base star
M18_STAR_PROBE PASS: VIP completion raises mastery to two stars
M18_STAR_PROBE PASS: configured score mastery raises a completed result
M18_STAR_PROBE PASS: VIP plus configured score mastery earns three stars
M18_STAR_PROBE PASS: disabled VIP cannot create a false VIP star
M18_STAR_PROBE PASS: star result is clamped to three
M18_STAR_PROBE PASS: fixture database loads
M18_STAR_PROBE PASS: campaign configures
M18_STAR_PROBE PASS: runtime bridge configures
M18_STAR_PROBE PASS: normal bridge completion reports one star
M18_STAR_PROBE PASS: one-star completion unlocks the next level
M18_STAR_PROBE PASS: stars do not gate progression
M18_STAR_CONTRACT_RESULT=PASS
```

### `M18-completion-progression`

Command: `godot_console.exe --headless --path . --script res://tests/m18_completion_progression_probe.gd`
Exit code: `0`; required marker: `M18_COMPLETION_PROGRESSION_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M18_COMPLETION_PROGRESSION_PROBE PASS: 100-level completion fixture loads in FULL validation
M18_COMPLETION_PROGRESSION_PROBE PASS: completion campaign configures
M18_COMPLETION_PROGRESSION_PROBE PASS: lose bridge configures
M18_COMPLETION_PROGRESSION_PROBE PASS: level 1 session starts
M18_COMPLETION_PROGRESSION_PROBE PASS: lose/incomplete does not advance level 2
M18_COMPLETION_PROGRESSION_PROBE PASS: win bridge configures
M18_COMPLETION_PROGRESSION_PROBE PASS: one-star completion resolves WIN
M18_COMPLETION_PROGRESSION_PROBE PASS: one-star completion unlocks next level
M18_COMPLETION_PROGRESSION_PROBE PASS: next-level resolution is deterministic and idempotent
M18_COMPLETION_PROGRESSION_PROBE PASS: completion campaign configures
M18_COMPLETION_PROGRESSION_PROBE PASS: all 100 levels accept normal one-star completion
M18_COMPLETION_PROGRESSION_PROBE PASS: Sunny Cove level 100 completion unlocks Tiki without perfect stars
M18_COMPLETION_PROGRESSION_PROBE PASS: 100% completion is independent of perfect-star replay
M18_COMPLETION_PROGRESSION_RESULT=PASS
```

### `M18-cumulative-star-rewards`

Command: `godot_console.exe --headless --path . --script res://tests/m18_cumulative_star_rewards_probe.gd`
Exit code: `0`; required marker: `M18_CUMULATIVE_STAR_REWARDS_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M18_CUMULATIVE_REWARDS_PROBE PASS: canonical Sunny Cove loads in FULL validation
M18_CUMULATIVE_REWARDS_PROBE PASS: canonical reward track contains the exact ten thresholds
M18_CUMULATIVE_REWARDS_PROBE PASS: canonical reward track has the exact approved booster payload and no coins
M18_CUMULATIVE_REWARDS_PROBE PASS: economy configures from campaign state
M18_CUMULATIVE_REWARDS_PROBE PASS: CampaignManager configures with economy authority
M18_CUMULATIVE_REWARDS_PROBE PASS: partial cumulative progress is deterministic
M18_CUMULATIVE_REWARDS_PROBE PASS: economy configures from campaign state
M18_CUMULATIVE_REWARDS_PROBE PASS: CampaignManager configures with economy authority
M18_CUMULATIVE_REWARDS_PROBE PASS: 29 to 30 crosses the first threshold
M18_CUMULATIVE_REWARDS_PROBE PASS: 30-star reward grants one time booster
M18_CUMULATIVE_REWARDS_PROBE PASS: worse replay with no new best is idempotent
M18_CUMULATIVE_REWARDS_PROBE PASS: economy configures from campaign state
M18_CUMULATIVE_REWARDS_PROBE PASS: CampaignManager configures with economy authority
M18_CUMULATIVE_REWARDS_PROBE PASS: multiple unclaimed thresholds catch up in order
M18_CUMULATIVE_REWARDS_PROBE PASS: catch-up grants four time and one upgrade booster
M18_CUMULATIVE_REWARDS_PROBE PASS: economy configures from campaign state
M18_CUMULATIVE_REWARDS_PROBE PASS: CampaignManager configures with economy authority
M18_CUMULATIVE_REWARDS_PROBE PASS: 149 to 150 grants the approved upgrade reward
M18_CUMULATIVE_REWARDS_PROBE PASS: economy configures from campaign state
M18_CUMULATIVE_REWARDS_PROBE PASS: CampaignManager configures with economy authority
M18_CUMULATIVE_REWARDS_PROBE PASS: 299 to 300 grants the final approved upgrade
M18_CUMULATIVE_REWARDS_PROBE PASS: final threshold claim remains duplicate-safe
M18_CUMULATIVE_REWARDS_PROBE PASS: claimed threshold state saves
M18_CUMULATIVE_REWARDS_PROBE PASS: economy configures from campaign state
M18_CUMULATIVE_REWARDS_PROBE PASS: CampaignManager configures with economy authority
M18_CUMULATIVE_REWARDS_PROBE PASS: claimed threshold persists across save/reload
M18_CUMULATIVE_REWARDS_PROBE PASS: replay after reload does not duplicate the claimed reward
M18_CUMULATIVE_REWARDS_PROBE PASS: economy configures from campaign state
M18_CUMULATIVE_REWARDS_PROBE PASS: CampaignManager configures with economy authority
M18_CUMULATIVE_REWARDS_PROBE PASS: one-star completion advances progression without a reward gate
M18_CUMULATIVE_STAR_REWARDS_RESULT=PASS
```

### `M18-reward-claim-remediation`

Command: `godot_console.exe --headless --path . --script res://tests/m18_cumulative_reward_claim_remediation_probe.gd`
Exit code: `0`; required marker: `M18_CUMULATIVE_REWARD_REMEDIATION_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: canonical Sunny Cove loads in FULL validation
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: campaign configures without an economy
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: 29 to 30 completes without economy
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: economy-unavailable threshold remains unclaimed
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: level completion still advances progression without reward authority
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: late economy attaches from pending state
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: late economy retry claims threshold
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: late economy grants exactly one time booster
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: campaign configures without an economy
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: forced failed grant leaves threshold unclaimed
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: campaign configures without an economy
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: duplicate-ledger economy configures
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: duplicate ledger claims state without duplicate inventory
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: duplicate ledger leaves claim consistent
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: normal 29 to 30 reward state saves and reloads
M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: save/reload replay does not duplicate reward
M18_CUMULATIVE_REWARD_REMEDIATION_RESULT=PASS
```

### `M18-replay-persistence`

Command: `godot_console.exe --headless --path . --script res://tests/m18_replay_persistence_probe.gd`
Exit code: `0`; required marker: `M18_REPLAY_PERSISTENCE_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M18_REPLAY_PROBE PASS: fixture database loads
M18_REPLAY_PROBE PASS: campaign configures
M18_REPLAY_PROBE PASS: first completion creates a bounded record
M18_REPLAY_PROBE PASS: worse replay preserves score, stars, and VIP history
M18_REPLAY_PROBE PASS: equal replay is idempotent
M18_REPLAY_PROBE PASS: better replay upgrades both mastery fields
M18_REPLAY_PROBE PASS: progression remains idempotent after replay
M18_REPLAY_PROBE PASS: atomic save accepts monotonic campaign state
M18_REPLAY_PROBE PASS: save reload preserves better score/stars
M18_REPLAY_PROBE PASS: reloaded campaign preserves the same record
M18_REPLAY_PROBE PASS: current saves reject out-of-range stars
M18_REPLAY_PROBE PASS: older save migration preserves bounded replay records
M18_REPLAY_PERSISTENCE_RESULT=PASS
```

### `M18-integration`

Command: `godot_console.exe --headless --path . --script res://tests/m18_integration_probe.gd`
Exit code: `0`; required marker: `M18_INTEGRATION_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M18_INTEGRATION_PROBE PASS: canonical M18 database loads in FULL validation
M18_INTEGRATION_PROBE PASS: fresh economy configures
M18_INTEGRATION_PROBE PASS: fresh canonical campaign configures
M18_INTEGRATION_PROBE PASS: integration records the base one-star award
M18_INTEGRATION_PROBE PASS: integration preserves worse replay state
M18_INTEGRATION_PROBE PASS: integration upgrades better replay state
M18_INTEGRATION_PROBE PASS: integration crosses and claims cumulative rewards
M18_INTEGRATION_PROBE PASS: integration cumulative claims are idempotent
M18_INTEGRATION_PROBE PASS: integration completes Sunny Cove and unlocks Tiki
M18_INTEGRATION_PROBE PASS: integration persists campaign and reward-ledger state
M18_INTEGRATION_PROBE PASS: integration reload preserves star/reward state
M18_INTEGRATION_PROBE PASS: integration navigation configures from reloaded authority
M18_INTEGRATION_PROBE PASS: integration mounts exactly one reusable map pair
M18_INTEGRATION_PROBE PASS: integration map exposes replay-complete level state
M18_INTEGRATION_PROBE PASS: integration enters replay with one gameplay instance
M18_INTEGRATION_PROBE PASS: integration returns from replay through Island Map boundary
M18_INTEGRATION_PROBE PASS: integration restores replay context without duplicates
M18_INTEGRATION_RESULT=PASS
```

### `M18-island-map-replay`

Command: `godot_console.exe --headless --path . --script res://tests/m18_island_map_replay_probe.gd`
Exit code: `0`; required marker: `M18_ISLAND_MAP_REPLAY_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M18_ISLAND_MAP_REPLAY_PROBE PASS: replay fixture loads in FULL validation
M18_ISLAND_MAP_REPLAY_PROBE PASS: replay campaign configures
M18_ISLAND_MAP_REPLAY_PROBE PASS: navigation accepts replay campaign
M18_ISLAND_MAP_REPLAY_PROBE PASS: one reusable map pair is mounted
M18_ISLAND_MAP_REPLAY_PROBE PASS: Island Map opens for the replay fixture
M18_ISLAND_MAP_REPLAY_PROBE PASS: completed level remains selectable for replay
M18_ISLAND_MAP_REPLAY_PROBE PASS: authoritative prior stars and best score are visible
M18_ISLAND_MAP_REPLAY_PROBE PASS: worse replay preserves stored state
M18_ISLAND_MAP_REPLAY_PROBE PASS: better replay refreshes authoritative visible state
M18_ISLAND_MAP_REPLAY_PROBE PASS: better replay state is visible after refresh
M18_ISLAND_MAP_REPLAY_PROBE PASS: replay launch uses one gameplay instance
M18_ISLAND_MAP_REPLAY_PROBE PASS: terminal replay can return to the Island Map
M18_ISLAND_MAP_REPLAY_PROBE PASS: return restores selected level and scroll/focus context
M18_ISLAND_MAP_REPLAY_PROBE PASS: replay return disposes gameplay without duplicating maps
M18_ISLAND_MAP_REPLAY_RESULT=PASS
```

### `M19-scalability`

Command: `godot_console.exe --headless --path . --script res://tests/m19_multi_island_scalability_probe.gd`
Exit code: `0`; required marker: `M19_SCALABILITY_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M19_PROBE PASS: Child 01 loads two content roots into one database
M19_PROBE PASS: Child 01 exposes both island level sets
M19_PROBE PASS: Child 01 rejects duplicate island roots
M19_PROBE PASS: Child 01 rejects cross-island level roots
M19_PROBE PASS: Child 01 rejects positive declared-count mismatch
M19_PROBE PASS: Child 01 permits the zero-level placeholder
M19_PROBE PASS: Child 01 uses one campaign/save authority pair
M19_PROBE PASS: Child 01 shared session bridge runs alpha
M19_PROBE PASS: Child 01 shared session bridge runs beta
M19_PROBE PASS: Child 01 shared SaveManager is available without a duplicate service
M19_CHILD_01_RESULT=PASS
M19_PROBE PASS: canonical data loads in FULL mode
M19_PROBE PASS: Child 02 fresh save keeps Tiki locked
M19_PROBE PASS: Child 02 Sunny L99 keeps Tiki locked
M19_PROBE PASS: Child 02 Sunny L100 unlocks Tiki without perfect stars
M19_PROBE PASS: Child 02 zero-level Tiki cannot launch gameplay
M19_PROBE PASS: Child 02 reload preserves Tiki unlock
M19_PROBE PASS: Child 02 unlock is idempotent
M19_CHILD_02_RESULT=PASS
M19_PROBE PASS: Child 03 Sunny policy remains L5-L8
M19_PROBE PASS: Child 03 Sunny content contains no L9 targets
M19_PROBE PASS: Child 03 Tiki is the first declarative L9 island
M19_PROBE PASS: Child 03 does not invent Tiki level content
M19_PROBE PASS: Child 03 repository policy is data-first and L1-L12 bounded
M19_CHILD_03_RESULT=PASS
M19_PROBE PASS: Child 04 has exactly ten canonical islands
M19_PROBE PASS: Child 04 order indices are unique and contiguous
M19_PROBE PASS: Child 04 next-island chain is exact
M19_PROBE PASS: Child 04 final island remains a placeholder name
M19_CHILD_04_RESULT=PASS
M19_PROBE PASS: Child 05 all ten islands expose immutable approved theme hooks
M19_PROBE PASS: Child 05 session bridge exposes resolved island theme
M19_PROBE PASS: Child 05 legacy definitions retain empty theme fallback
M19_CHILD_05_RESULT=PASS
M19_PROBE PASS: Child 06 adds a third island through data only
M19_PROBE PASS: Child 06 reuses one campaign authority for the new island
M19_PROBE PASS: Child 06 reusable map pair accepts the fixture campaign
M19_PROBE PASS: Child 06 map navigation reaches the new island without a new scene
M19_PROBE PASS: Child 06 one session bridge runs old and new fixture islands
M19_PROBE PASS: Child 06 runtime has no hard-coded Tiki branch
M19_CHILD_06_RESULT=PASS
M19_SCALABILITY_RESULT=PASS
```

### `M19-R01-child-01`

Command: `godot_console.exe --headless --path . --script res://tests/m19_r01_ordered_verification_probe.gd -- --child=1`
Exit code: `0`; required marker: `M19_R01_CHILD_01_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M19_R01_CHILD_01 PASS: multi-root load succeeds
M19_R01_CHILD_01 PASS: both fixture islands are loaded
M19_R01_CHILD_01 PASS: single-root API remains backward compatible
M19_R01_CHILD_01 PASS: duplicate roots are rejected
M19_R01_CHILD_01 PASS: cross-island rows are rejected
M19_R01_CHILD_01 PASS: positive declared-count mismatch is rejected
M19_R01_CHILD_01 PASS: zero-level placeholder remains valid
M19_R01_CHILD_01 PASS: one campaign and save authority configure
M19_R01_CHILD_01 PASS: one reusable map pair configures
M19_R01_CHILD_01 PASS: one reusable map pair exists
M19_R01_CHILD_01 PASS: one session bridge runs both islands
M19_R01_CHILD_01_RESULT=PASS
```

### `M19-R01-child-02`

Command: `godot_console.exe --headless --path . --script res://tests/m19_r01_ordered_verification_probe.gd -- --child=2`
Exit code: `0`; required marker: `M19_R01_CHILD_02_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M19_R01_CHILD_02 PASS: canonical database loads in FULL mode
M19_R01_CHILD_02 PASS: fresh save keeps Tiki locked
M19_R01_CHILD_02 PASS: Sunny L99 keeps Tiki locked
M19_R01_CHILD_02 PASS: one-star Sunny L100 completion unlocks Tiki
M19_R01_CHILD_02 PASS: Tiki remains zero-level and unplayable
M19_R01_CHILD_02 PASS: Tiki cannot start a gameplay session
M19_R01_CHILD_02 PASS: reload preserves unlock
M19_R01_CHILD_02 PASS: unlock is idempotent
M19_R01_CHILD_02_RESULT=PASS
```

### `M19-R01-child-03`

Command: `godot_console.exe --headless --path . --script res://tests/m19_r01_ordered_verification_probe.gd -- --child=3`
Exit code: `0`; required marker: `M19_R01_CHILD_03_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M19_R01_CHILD_03 PASS: canonical database loads in FULL mode
M19_R01_CHILD_03 PASS: Sunny policy is L5-L8
M19_R01_CHILD_03 PASS: Sunny content has no L9
M19_R01_CHILD_03 PASS: Tiki is first declarative L9 island
M19_R01_CHILD_03 PASS: Tiki has no production levels or exact L9 level
M19_R01_CHILD_03 PASS: policy is data-first and L1-L12 bounded
M19_R01_CHILD_03 PASS: runtime has no Tiki-specific branch
M19_R01_CHILD_03_RESULT=PASS
```

### `M19-R01-child-04`

Command: `godot_console.exe --headless --path . --script res://tests/m19_r01_ordered_verification_probe.gd -- --child=4`
Exit code: `0`; required marker: `M19_R01_CHILD_04_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M19_R01_CHILD_04 PASS: canonical database loads in FULL mode
M19_R01_CHILD_04 PASS: canonical order has exactly ten ids
M19_R01_CHILD_04 PASS: order indices are unique and contiguous
M19_R01_CHILD_04 PASS: next-island chain and terminal slot are exact
M19_R01_CHILD_04 PASS: final public name remains TBD
M19_R01_CHILD_04_RESULT=PASS
```

### `M19-R01-child-05`

Command: `godot_console.exe --headless --path . --script res://tests/m19_r01_ordered_verification_probe.gd -- --child=5`
Exit code: `0`; required marker: `M19_R01_CHILD_05_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M19_R01_CHILD_05 PASS: canonical database loads in FULL mode
M19_R01_CHILD_05 PASS: all ten theme hooks are immutable and existing
M19_R01_CHILD_05 PASS: session bridge exposes immutable theme
M19_R01_CHILD_05 PASS: theme-less legacy fixture falls back safely
M19_R01_CHILD_05_RESULT=PASS
```

### `M19-R01-child-06`

Command: `godot_console.exe --headless --path . --script res://tests/m19_r01_ordered_verification_probe.gd -- --child=6`
Exit code: `0`; required marker: `M19_R01_CHILD_06_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M19_R01_CHILD_06 PASS: third fixture island loads from data only
M19_R01_CHILD_06 PASS: same reusable navigation pair configures
M19_R01_CHILD_06 PASS: same map pair reaches Gamma
M19_R01_CHILD_06 PASS: same bridge runs old and new fixture islands
M19_R01_CHILD_06_RESULT=PASS
```

### `M18-V02-R01-replay-capture`

Command: `godot_console.exe --path . --script res://tests/m18_v02_r01_replay_capture_probe.gd --rendering-method gl_compatibility --display-driver windows`
Exit code: `0`; required marker: `M18_REPLAY_CAPTURE_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
OpenGL API 3.3.0 - Build 31.0.101.3616 - Compatibility - Using Device: Intel - Intel(R) Iris(R) Xe Graphics

M18_REPLAY_CAPTURE_PROBE PASS: canonical Sunny Cove loads in FULL validation
M18_REPLAY_CAPTURE_PROBE PASS: navigation accepts capture campaign
M18_REPLAY_CAPTURE_PROBE PASS: production Island Map opens for Child 05
M18_REPLAY_CAPTURE_PROBE PASS: completed Child 05 exposes prior stars and best score
M18_REPLAY_CAPTURE name=child05_completed_prior_record path=res://coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/evidence/v02-r01/child05_completed_prior_record.png dimensions=720x1280 error=0 valid=true
M18_REPLAY_CAPTURE_PROBE PASS: capture 1 saved
M18_REPLAY_CAPTURE_PROBE PASS: worse replay preserves authoritative record
M18_REPLAY_CAPTURE name=child05_worse_replay_preserved path=res://coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/evidence/v02-r01/child05_worse_replay_preserved.png dimensions=720x1280 error=0 valid=true
M18_REPLAY_CAPTURE_PROBE PASS: capture 2 saved
M18_REPLAY_CAPTURE_PROBE PASS: improved replay updates authoritative visible record
M18_REPLAY_CAPTURE name=child05_improved_replay_updated path=res://coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/evidence/v02-r01/child05_improved_replay_updated.png dimensions=720x1280 error=0 valid=true
M18_REPLAY_CAPTURE_PROBE PASS: capture 3 saved
M18_REPLAY_CAPTURE_PROBE PASS: Child 05 is selected before replay return
M18_REPLAY_CAPTURE_PROBE PASS: production gameplay boundary returns to Island Map
M18_REPLAY_CAPTURE_RETURN_STATE saved_scroll=913 selected=5 focus=5 scroll=913 view=ISLAND_MAP gameplay=0
M18_REPLAY_CAPTURE_PROBE PASS: capture 4 restores selected focus and scroll context
M18_REPLAY_CAPTURE name=child05_return_context_restored path=res://coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/evidence/v02-r01/child05_return_context_restored.png dimensions=720x1280 error=0 valid=true
M18_REPLAY_CAPTURE_PROBE PASS: capture 4 saved
M18_REPLAY_CAPTURE_RESULT=PASS
```

### `M20-runtime-capture`

Command: `godot_console.exe --path . --script res://tests/m20_runtime_capture_probe.gd --rendering-method gl_compatibility --display-driver windows`
Exit code: `0`; required marker: `M20_RUNTIME_CAPTURE_RESULT=PASS`; marker found: `True`.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
OpenGL API 3.3.0 - Build 31.0.101.3616 - Compatibility - Using Device: Intel - Intel(R) Iris(R) Xe Graphics

M20_CAPTURE PASS: production first-run onboarding is visible
M20_CAPTURE name=onboarding path=res://coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/evidence/captures/01_onboarding.png dimensions=720x1280 error=0
M20_CAPTURE PASS: production Main Menu is visible
M20_CAPTURE name=main_menu path=res://coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/evidence/captures/02_main_menu.png dimensions=720x1280 error=0
M20_CAPTURE PASS: production Settings surface opens
M20_CAPTURE name=settings path=res://coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/evidence/captures/03_settings.png dimensions=720x1280 error=0
M20_CAPTURE PASS: production World Map rejects and presents locked island
M20_CAPTURE name=locked_feedback path=res://coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/evidence/captures/04_locked_feedback.png dimensions=720x1280 error=0
M20_CAPTURE PASS: production level selection enters gameplay
M20_CAPTURE PASS: production pause overlay opens
M20_CAPTURE name=pause path=res://coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/evidence/captures/05_pause.png dimensions=720x1280 error=0
M20_CAPTURE PASS: production LOSE result overlay opens
M20_CAPTURE name=lose_result path=res://coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/evidence/captures/06_lose_result.png dimensions=720x1280 error=0
M20_CAPTURE PASS: production WIN result overlay opens
M20_CAPTURE name=win_result path=res://coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/evidence/captures/07_win_result.png dimensions=720x1280 error=0
M20_RUNTIME_CAPTURE_RESULT=PASS captures=7
```

### `M17-V07-R03-read-only-report-integrity`

Command: `Get-Content M17_CANONICAL_CONFIRMATION_V07_R03.json | ConvertFrom-Json; Get-FileHash JSON/Markdown`
Exit code: `0`; required marker: `report_version=V07-R03 status=PASS validation_errors=0 levels=100 confirmation_candidate_count=42`; marker found: `True`.

```text
version=V07-R03; status=PASS; validation_errors=0; levels=100; confirmation_candidate_count=42; json_sha256=4B07CE2778F9CD001756BE26259B169288D002F385484F94A85A120BF7101C9A; markdown_sha256=82EA191C7333BEED7DAAFA4639EAE47EAF904B2C3ADE0A9A9390C6ECC1165276
```


