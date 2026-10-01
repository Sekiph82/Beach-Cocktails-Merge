# BCM-M21 Owner Runtime Ruling V01 — No Timers / Restore Playability / Restore Accepted Visuals

Date: 2026-10-01
Status: **OWNER-AUTHORITATIVE / SUPERSEDES CONFLICTING EARLIER TIMER ASSUMPTIONS**

## No time limits anywhere

The owner explicitly rules that Beach Cocktails Merge must not use a gameplay time limit.

Therefore:
- no campaign level may fail because elapsed time reached zero;
- no countdown timer is an active completion requirement;
- Sunny Cove L1-L100 must be untimed;
- future islands are untimed by default unless the owner later explicitly changes this rule;
- onboarding, pause copy, tests, schemas and UX must not describe normal gameplay as timed;
- `feature_flags.timed` must be false/absent in production level data;
- `time_limit_sec` must be zero/absent and must not drive session terminal state.

This ruling supersedes the timer assumptions introduced by earlier campaign planning.

## Historical provenance

Repository history shows the timed contract originated in the development/planning chain, not in an explicit owner timer ruling:

- `200a35a2f96199aadd6c05948afec7928bb0414f` (2026-09-19), “Add Sunny Cove 100-level progression spec”, created `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md` with “timer-based completion” and L1≈20s / L100=300s.
- M14 ChatGPT execution prompt later required one authoritative countdown timer.
- `a96d2d16bfd679d0dbd1b12905d9bc4f3ad742e1` (2026-09-28), ChatGPT M16 prompt, treated that table as approved.
- `05affb7aeeeebf0aed7eaa2893f030b3f42d5850` implemented the 100 timed Sunny Cove rows.
- `OWNER_RULING_V02.md` in M16 approved VIP placement/reward policy, not the original normal timer contract. References to preserving “any normal timer” are not an owner approval of introducing timers.

No timer mechanic may now be justified by those historical documents.

## +Time mechanic

Because gameplay has no timer:
- the `time` booster is no longer an active production mechanic;
- no new `time` booster may be granted or presented as useful;
- do not invent a replacement reward;
- replacement reward policy is OWNER_REQUIRED and must be handled separately after playability is restored;
- legacy saved `time` inventory must be tolerated non-destructively, but it must not alter gameplay.

## Real input is mandatory

Acceptance requires:
- mouse press/drag/release launches cocktails;
- touch press/drag/release launches cocktails;
- at least 10 consecutive launches in the production F5 campaign path;
- tests must inject events through the viewport/input dispatch boundary, not call ShotController launch methods directly;
- release acceptance still requires owner manual play.

## Sunny Cove accepted gameplay table/theme

Campaign Sunny Cove must render the canonical existing theme assets under:
`assets/ui_assets/campaign/islands/sunny_cove/`

At minimum:
- `gameplay_background.png`
- `gameplay_table_shadow.png`
- `gameplay_table.png`
- `table_edge_overlay.png`
- `launch_zone.png`

The old fixed combined background:
`assets/environment/game_board_background.png`
must not override Sunny Cove campaign theme.

Gameplay physics/table-contact geometry remains separately authoritative and must not be casually retuned while restoring the accepted visual table.

## World Map

The canonical World Map background already visually contains the ten islands.

Selection controls must:
- align with the actual baked island locations;
- not create a second displaced “island” that visually competes with the baked island;
- use the island location as the click/touch target;
- preserve OPEN/LOCKED/CURRENT/COMPLETE state;
- route lines, rings and lock feedback must align to the same actual island centers.

A final 720×1280 screenshot is mandatory for owner review.

## Godot manual-review size

Canonical production viewport remains 720×1280.

Desktop/Godot debug presentation must be enlarged from the current 405×720 override to a practical 9:16 manual-review size. Use at least 480×854 and prefer 540×960 when the editor/display can fit it. Do not change canonical UI coordinates merely to make the desktop debug window larger.

## Audit rule going forward

A technical probe cannot substitute for actual owner-facing runtime review.

For any milestone that changes or depends on input, gameplay, map placement, table/theme rendering, HUD/UI, results, or release UX, independent closure requires:
1. source/test audit;
2. production-path runtime screenshot(s);
3. real input-dispatch smoke where input is relevant;
4. owner-native/manual acceptance when the milestone is owner-facing.

The current owner runtime observation overrides prior automated PASS interpretations.
