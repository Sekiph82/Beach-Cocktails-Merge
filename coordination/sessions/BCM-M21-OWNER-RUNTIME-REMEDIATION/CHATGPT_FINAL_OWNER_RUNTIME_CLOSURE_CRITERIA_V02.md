# BCM-M21 Final Owner Runtime Closure V02 — Locked Criteria

Status: **LOCKED BEFORE EXECUTION**

Active task IDs:
- BCM-M21-001
- BCM-M21-004
- BCM-M21-006

Frozen PASS task IDs:
- BCM-M21-002
- BCM-M21-003
- BCM-M21-005

Authority:
- `OWNER_RULING_V01.md`
- `OWNER_RUNTIME_AUDIT_V01.md`
- `CHATGPT_AUDIT_CRITERIA_V01.md`
- implementation handoff `814198440dc5c13792087b351a151241bd2664a5`.

## A — single-batch rule

This is the only active M21 closure batch.

1. Re-verify the owner-runtime recovery on current `main`.
2. If any locked technical criterion fails, remediate that failure in this same batch and rerun only the affected focused/regression checks.
3. If all technical criteria pass, do not invent more product work.
4. Prepare the exact owner F5 acceptance handoff and stop.
5. CODEX must not edit root `TASKS.md`.
6. No release PASS may be claimed without explicit owner manual acceptance.

## B — BCM-M21-001 final runtime gate

Production F5 path must prove:
- desktop debug window override = 486×864;
- canonical viewport remains 720×1280;
- World Map ten interactive markers align with the baked ten islands;
- no duplicate island thumbnail art;
- Sunny Cove Island Map remains navigable;
- real mouse input launches 10/10 cocktails through viewport dispatch;
- real touch input launches 10/10 cocktails through viewport dispatch;
- direct launcher-method calls = 0;
- pause/result overlays block gameplay input when visible;
- Sunny Cove gameplay renders its canonical five theme layers;
- no old fixed board overrides the campaign theme;
- no gameplay timer or TIME UP path exists;
- one simulated hour cannot timeout a canonical level.

## C — BCM-M21-004 regression gate

Run only the release-relevant regression set after any remediation:
- M02 collision/merge/rapid launch;
- R11 table/contact geometry;
- M03 scoring / To-Go / loss;
- M07-R06 HUD;
- M08 delivery;
- M09 audio/haptics;
- updated untimed M14;
- updated M15 VIP optionality with retired +Time;
- updated M16 Sunny Cove untimed content;
- M18 stars/replay/rewards with no +Time grant;
- M19 map/theme/multi-island;
- M20 menu/settings/pause/result/save;
- M21 full progression 100/100;
- M21 performance profile;
- `git diff --check`.

Historical timer-only expectations are superseded by `OWNER_RULING_V01.md`.

## D — no-timer / +Time freeze

Production truth must remain:
- all Sunny Cove `time_limit_sec = 0` or absent;
- all Sunny Cove `feature_flags.timed = false` or absent;
- `GameplaySessionBridge._is_timed_session() == false`;
- no production reward grants `id=time`;
- no UI advertises +Time;
- legacy saved time inventory remains readable/non-destructive;
- no replacement reward is invented.

## E — theme / World Map proof

Re-verify:
- Sunny Cove uses configured `gameplay_background`, `gameplay_table_shadow`, `gameplay_table`, `table_edge_overlay`, `launch_zone`;
- R11 physics coordinates remain unchanged;
- World Map centers come from deterministic calibrated baked-island centers;
- island entry art remains hidden so baked background is the sole island art;
- routes/rings/locks use the same calibrated centers.

If the current World Map capture cannot be independently inspected because of binary transport size, create a same-dimension audit-review JPEG/WebP derivative <=400 KiB without crop/resize/content edits and record provenance. Do the same for themed gameplay if needed. Do not replace original evidence.

## F — owner F5 acceptance package

Create:
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V02.md`
- `CODEX_LOG_FINAL_OWNER_RUNTIME_CLOSURE_V02.md`

Checklist must be short and executable by the owner in Godot F5, in this order:

1. Window is comfortably visible at 486×864.
2. Main Menu → PLAY → World Map.
3. Ten hotspots sit on the ten visible islands.
4. Open Sunny Cove → L1.
5. Correct Sunny Cove table/theme visible.
6. Mouse drag/release launches at least 10 cocktails.
7. No countdown / TIME UP.
8. Pause → Resume works.
9. Complete/win a level and verify result UI has no timer language.
10. Restart project and verify save/progress/settings persist.

Each line must provide OWNER PASS / FAIL space. CODEX must not prefill owner results.

## G — final marker

If technical re-verification passes, end exactly:

`AWAITING_OWNER_F5_ACCEPTANCE_V02`

If technical remediation cannot close a criterion, end:

`CHANGES_REQUIRED_OWNER_RUNTIME_V02`

Do not claim v1 release-ready before explicit owner acceptance.
