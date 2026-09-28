# BCM-M15 V06 Reward Digits Follow-up — CODEX Log V06-R01

- Work item: BCM-M15 V06 owner-requested HUD follow-up.
- Parent publication: `8569df26325b1cbcee66b49befc36aabe9a52e78`.
- Start HEAD: `8569df26325b1cbcee66b49befc36aabe9a52e78`.
- Branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Scope: center the normal and VIP reward digits in the visible brown coin-adjacent areas and use white text. No gameplay, economy, physics, approved master asset, or `TASKS.md` changes.

## Sync preflight

- `git status --short --branch`: clean at start, `main...origin/main`.
- `git fetch origin main`: completed.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0`.

## Changed files

- `scripts/game_manager.gd` — moved both reward-label source rectangles to the right-hand brown coin recess and changed both colors to `Color.WHITE`.
- `tests/m07_r06_owner_layout_probe.gd` — updated the expected reward bounds for the centered slot.
- `docs/evidence/m07/independent_inner_content_layout_v02.json` — synchronized the documented reward bounds.
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v06/*.png` — regenerated the four V06 captures after the HUD follow-up.

## Verification

- M15 headless probe: `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS`; `M15_HEADLESS_EXIT=0`.
- M15 OpenGL probe: passed; all four V06 captures regenerated.
- M07 R06 OpenGL owner-layout probe: `M07_R06_PROBE_RESULT=PASS`; `M07_OWNER_LAYOUT_EXIT=0` across canonical, shorter/wider, and taller viewports.
- `git diff --check`: exit `0`.
- Visual inspection: the pending V06 capture shows both `1000` and `6000` in white, centered beside their coin icons.

## Boundaries and handoff

- Owner visual acceptance and independent ChatGPT audit were not performed by Codex.
- Existing M08 headless diagnostics remain unrelated and unchanged.
- Root `TASKS.md` was not modified.
- M16 was not started.
- Implementation commit: `7712e64` (`Center V06 HUD reward digits and use white text`).
- Final publication SHA: recorded after the log commit and push.
- Handoff status: `AWAITING_M15_AUDIT_V06`.
