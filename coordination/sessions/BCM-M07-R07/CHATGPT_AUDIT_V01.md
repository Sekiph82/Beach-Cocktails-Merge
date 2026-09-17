# BCM-M07-R07 — ChatGPT Strict Audit V01

Verdict: **CHANGES_REQUIRED**

## Scope audited
- `coordination/sessions/BCM-M07-R07/CODEX_LOG_V01.md`
- locked criteria `coordination/sessions/BCM-M07-R07/CHATGPT_AUDIT_CRITERIA_V03.md`
- implementation commit `3e3c125ce0b4b74b733af309b572b376e6714dce`
- current `scripts/game_manager.gd`
- current held-drink anchor code and focused M07 probes

## Accepted production changes
1. SCORE remains on the right beneath/near NEXT.
2. Fixed score font size and seven-digit maximum are preserved.
3. SCORE receives an explicit `SCORE_OPTICAL_Y_BIAS_PX = -2.0`; BEST SCORE does not.
4. To-Go ropes now run from viewport y=0 and overlap eight pixels into the baked panel art with greater width, while remaining behind the panel.
5. To-Go content remains target cocktail + reward digits only; no Lx/name and no leading plus.
6. Held-body baseline offset changed from 42 px to 3 px so the visual is intended to align with the rendered launch ring rather than the texture-square center.
7. NEXT/progression/canonical assets and gameplay contracts were not intentionally retuned.
8. Builder reports a full active M01-M07 regression PASS and Godot/import/diff checks exit 0.

## Blocking finding F-M07-R07-STRICT-001 — SCORE validation was changed together with the production bias
Production adds `SCORE_OPTICAL_Y_BIAS_PX = -2.0`. The focused tests simultaneously change the expected SCORE value box from `Rect2(45,55,116,52)` to `Rect2(45,53,116,52)`.

That means the test expectation moved by the same amount as the production implementation. This proves internal agreement, not that the number is visually centered in the baked dark recess from the owner screenshot. The locked V03 criterion requires the owner-visible result.

## Blocking finding F-M07-R07-STRICT-002 — held-drink alignment remains self-referential
The held-drink check calculates the expected visual body center/bottom using the same production constants it is meant to validate:
- `HELD_BODY_FOOT_SOURCE_PX`
- `VISIBLE_BODY_CENTER_OFFSET_PX`
- `HELD_BODY_BASELINE_OFFSET_PX`

The reported zero X/Y error is therefore expected if production and test share the same constants. It does not independently establish that the visible glass/container bottom-center lands on the actual rendered gold oval center for L01-L12.

The locked V03 criteria explicitly require the visible result, not merely internal anchor agreement.

## Blocking finding F-M07-R07-STRICT-003 — rope continuity is still coordinate-proven, not visually proven
The implementation is plausibly improved: y=0 start, +8 px overlap into panel art, width 12, z=-2. But the focused test still validates node endpoints/width rather than pixel continuity at the baked/runtime rope join. The owner previously rejected an earlier coordinate-correct version because a visible gap remained.

The retained R07 screenshots are present in GitHub, but this audit environment cannot decode those binary PNGs through the connector. Therefore the required independent visual proof of seamless rope continuity is not available here.

## Classification
- Production intent: **materially improved**.
- Automated regression: **green per builder evidence**.
- Independent visual acceptance: **not established**.
- Test independence for SCORE/held alignment: **insufficient**.

## Required closure
The next closure should not blindly change the production values again. Instead:
1. establish independent visual reference measurements for the SCORE dark recess and held launch oval/body-bottom-center that are not derived from the production constants under test;
2. validate rope continuity from rendered pixels or current owner runtime evidence;
3. keep the current production implementation if the independent evidence confirms it, and change it only if the independent evidence shows a mismatch.

Until then M07 remains `CHANGES_REQUIRED`.
