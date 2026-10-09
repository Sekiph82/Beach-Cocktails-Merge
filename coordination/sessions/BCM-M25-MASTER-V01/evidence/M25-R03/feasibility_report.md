# BCM-M25-R03 pre-run causal and route feasibility report

Created before any M25-R03 gameplay attempt. Production code/data inspection only; no game run or gameplay attempt has occurred in this remediation yet.

## Terminal state and prior five WIN outcomes

- `scripts/campaign/gameplay_session_bridge.gd:130-140`: production campaign sessions are untimed (`tick()` returns unless `_is_timed_session()`), and the locked Sunny Cove levels have `time_limit_sec: 0` (`data/campaign/levels/sunny_cove.json`). There is no countdown-based campaign LOSE for these levels.
- `scripts/game_manager.gd:1036-1050`: the only physical natural-LOSE check requires a settled, non-deleting `Drink` whose `position.y + radius > death_line_y` continuously for `death_tolerance` (default 1.0 seconds; Sunny Cove's profile sets `death_line_y=846`).
- `scripts/game_manager.gd:1080-1110`: that condition calls `_game_over()`, which emits `resolve_lose("TABLE_DANGER", score)` for an active campaign session. `scripts/campaign/gameplay_session_bridge.gd:337-340` stores LOSE through the terminal resolver. This proves the state-machine branch exists, but does not establish that a production shot can reach its physical predicate.
- The five R02 attempts named `FULL_LOSE_LEVEL6`, `FULL_LOSE_RECT`, `FULL_LOSE_S19`, `FULL_LOSE_SETTLED`, and `REDUCED_LOSE_LEVEL7` each ended in actual `WIN` (levels/scores: 6/5083, 1/3244, 1/725, 1/1101, 7/2454). The R02 runner's `_choose_loss_lane()` (`evidence/M25-R02/runners/m25_r02_gameplay_input_probe.gd:89-111`) selects the least populated lane and heavily penalizes nearby same-level drinks. It disperses the pile instead of sustaining a drink above the danger line. The timed-out route never became a loss condition; genuine normal-order completion resolves WIN through `record_to_go_delivery()` -> `resolve_win()` at `gameplay_session_bridge.gd:255-283,329-335`. Thus those outcomes reflect the harness's opposite lane strategy plus objective completion, not an unreachable LOSE state.

## Star formula and feasible lower-star routes

- `scripts/campaign/gameplay_session_bridge.gd:236-252`: an incomplete objective is 0 stars; a completed objective starts at 1, reaches 2 at `score >= two_stars`, and reaches 3 at `score >= three_stars`; VIP only gates the third star when enabled.
- `scripts/game_manager.gd:979-1005` awards the configured `Drink.merge_score(new_level)` on real merges (plus combo points if merges are chained); `:1769-1791` adds `Drink.order_reward(level)` when a normal order is delivered. For deterministic floors, allow the combo timer to expire between score-producing merges.
- `data/drinks.json`: L3 spawn is possible (`scripts/shot_controller.gd:23,55-56`, `randi_range(1, 3)`). A fresh objective score starts at zero (`gameplay_session_bridge.gd:64-97`); spawned ingredients do not award score until merged.

| Level | Required order | Lower-bound physical merge path | To-Go points | Total route score | Locked thresholds | Result |
|---|---|---|---:|---:|---|---|
| 1 | L5 ×1 | Four spawned L3s -> two L4 merges (2×100), then L5 (200) = 400 | 0 | 400 | 2★ 450; 3★ 550 | Genuine 1★ route |
| 1 | L5 ×1 | Same L5 route plus one L2+L2 -> L3 merge (+50) before delivery | 0 | 450 | 2★ 450; 3★ 550 | Genuine 2★ route |

The level-1 1★/2★ routes are lower bounds before combo bonuses; a real-input runner must space merges so the combo window expires and must confirm terminal metadata. They need only ordinary spawns, production collisions/merges, objective delivery, and existing star calculation. No forged outcome or rules change is needed. Level 4 was not chosen for these routes: it has a level-5 VIP objective that can intercept the intermediate L5 and grant extra score.

## R02 lower-star misses explained

- `FULL_LEVEL4_ONE_STAR_PRODUCTION_SELECT_2`: level 4 finished at 3831 (3 stars), above 2950.
- `FULL_LEVEL4_TWO_STAR_DELAY240`: level 4 finished at 3540 (3 stars), above 2950.

Those tests exceeded the existing three-star threshold; they do not contradict the lower-bound routes above. No gameplay, score, objective, star-threshold, reward, or physics modification is authorized or indicated by this diagnosis.

## Bounded physical reachability trial and stop decision

- The R03 runner fired 71 shots through actual mouse `InputEvent`s (140 events counted) into `ShotController._unhandled_input` in a GL Compatibility window, using a fresh APPDATA and a valid isolated save fixture that unlocked level 100. It selected the same lane for every shot to build the densest plausible pile without completing level 100's four orders.
- `FULL_LOSE_LEVEL100_SAME_LANE_70/result_metadata.json` records `actual_outcome=NONE`, `game_over=false`, `death_line_y=846`, `death_tolerance=1.0`, `line_timer=0.0`, and 26 settled drinks. The largest settled `y + radius` was 742.43, still 103.57 px short of the danger predicate; the real-GL `after_attempts.png` shows the resulting crowded board. No settled drink was below the danger line.
- A 15-shot level-1 same-lane trial ended in genuine `WIN` at 615 points / 3 stars before any loss; it supports the R02 finding that low campaign orders can complete first. The 30-shot level-100 run was also nonterminal and yielded 636 score before the longer 71-shot run.
- `scripts/drink.gd:383-389,620-628,644-648` sends every launched drink upward and clamps positive-Y velocity to zero; contact enforcement applies the same clamp. The active campaign levels are untimed. Other than the timeout and `TABLE_DANGER` paths, `submit_result()` at `gameplay_session_bridge.gd:377-390` is a legacy compatibility API that can accept a caller-supplied outcome, not a natural gameplay trigger. The 71-shot real-input run failed to reach the only enabled campaign loss predicate, even with same-lane crowding.
- **Stop marker: `OWNER_DECISION_REQUIRED`.** Natural LOSE remains unverified/unreachable from the tested production input path, while the owner-locked criteria forbid changing gameplay/physics or synthesizing a terminal result. Do not continue into LOSE presentation, RETRY acceptance, owner-visual acceptance, or final regressions until the owner resolves the loss-condition authority. The source-level 1★/2★ routes above remain feasible candidates, but were not runtime-tested after this gate.
- Protected owner files had identical SHA-256 inventories before and after every executed Godot trial. Each trial used isolated `APPDATA`; no owner save or protected file changed.
