# BCM-M07-R05 Codex Execution Log V01

Status: `IMPLEMENTATION_COMPLETE / AWAITING_AUDIT`

Builder evidence only. No independent audit verdict or `TASKS.md` transition is assigned here.

## Authority and preflight

- Work item: BCM-M07-R05.
- Master prompt: `coordination/sessions/BCM-M07-R04-THEN-M06-R05-M07-R05/CHATGPT_EXECUTION_PROMPT_V01.md`.
- Locked criteria: `coordination/sessions/BCM-M07-R05/CHATGPT_AUDIT_CRITERIA_V01.md`.
- M07-R04 prerequisite completed and pushed before this phase; its log was not rewritten in this phase.
- Start HEAD: `e476cb7e6cc3757d979524fccc5802ed7dfb86b0`.
- Branch: `main`.
- Remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

Governed sync preflight:

```text
git status --short --branch
## main...origin/main
git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
git fetch origin main
M06_R05_PREFLIGHT_FETCH_EXIT_CODE=0
git rev-list --left-right --count HEAD...origin/main
0 0
```

## Bounded implementation

Only the post-geometry HUD layout was adapted in `scripts/game_manager.gd`:

- Logo display footprint is `x=12, y=6, w=190, h=126.667` at 720 px width.
- BEST SCORE remains left and below the logo at `x=16, y=140, w=205, h=115.443`.
- SCORE remains left and below BEST SCORE at `x=16, y=256, w=205, h=115.443`.
- BEST/SCORE are above the tabletop top at the canonical viewport (`table_top_y=393.333`) and do not participate in physics bounds.
- The 1 px inter-panel gap avoids rectangle intersection while moving SCORE upward from the prior y=265 position.
- The M07-R04 fixed 20 px font constants and seven-digit display behavior are unchanged.
- To-Go remains target cocktail + reward digits only, with no Lx/name text or leading plus.
- To-Go ropes remain connected to viewport y=0.
- NEXT, progression, held-body anchors, M06-R05 geometry, physics, economy and gameplay were not retuned.
- No canonical PNGs, `TASKS.md`, ChatGPT-owned files, historical logs, or `guide_line` were modified.

## M07-R05 adaptation probe

Command:

```text
godot_v4.7.2-stable_win64_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/m07_r05_hud_adaptation_probe.gd
```

Exact result markers:

```text
M07_R05_PROBE PASS: M07-R05 main scene loads
M07_R05_PROBE PASS: canonical_720x1280 BEST/SCORE moved upward
M07_R05_PROBE PASS: canonical_720x1280 logo -> BEST -> SCORE stack is fully visible and non-overlapping
M07_R05_PROBE PASS: canonical_720x1280 upper tabletop remains open below HUD
M07_R05_PROBE PASS: canonical_720x1280 preserves fixed seven-digit score behavior
M07_R05_PROBE PASS: canonical_720x1280 preserves target+reward-only To-Go and top ropes
M07_R05_PROBE PASS: canonical_720x1280 preserves true NEXT and baked 2x6 progression
M07_R05_PROBE PASS: canonical_720x1280 M06-R05 full tabletop bounds remain HUD-independent
M07_R05_PROBE PASS: taller_720x1440 BEST/SCORE moved upward
M07_R05_PROBE PASS: taller_720x1440 logo -> BEST -> SCORE stack is fully visible and non-overlapping
M07_R05_PROBE PASS: taller_720x1440 upper tabletop remains open below HUD
M07_R05_PROBE PASS: taller_720x1440 preserves fixed seven-digit score behavior
M07_R05_PROBE PASS: taller_720x1440 preserves target+reward-only To-Go and top ropes
M07_R05_PROBE PASS: taller_720x1440 preserves true NEXT and baked 2x6 progression
M07_R05_PROBE PASS: taller_720x1440 M06-R05 full tabletop bounds remain HUD-independent
M07_R05_PROBE PASS: shorter_wider_800x1280 BEST/SCORE moved upward
M07_R05_PROBE PASS: shorter_wider_800x1280 logo -> BEST -> SCORE stack is fully visible and non-overlapping
M07_R05_PROBE PASS: shorter_wider_800x1280 upper tabletop remains open below HUD
M07_R05_PROBE PASS: shorter_wider_800x1280 preserves fixed seven-digit score behavior
M07_R05_PROBE PASS: shorter_wider_800x1280 preserves target+reward-only To-Go and top ropes
M07_R05_PROBE PASS: shorter_wider_800x1280 preserves true NEXT and baked 2x6 progression
M07_R05_PROBE PASS: shorter_wider_800x1280 M06-R05 full tabletop bounds remain HUD-independent
M07_R05_PROBE_RESULT=PASS
M07_R05_PROBE_EXIT_CODE=0
```

State measurements from the same run:

```text
M07_R05_STATE label=canonical_720x1280 viewport=(720.0, 1280.0) logo=(12.0, 6.0) best=(16.0, 140.0) score=(16.0, 256.0) to_go=(255.0, 18.0) next=(563.0, 10.0) table_top_y=393.333
M07_R05_STATE label=taller_720x1440 viewport=(720.0, 1440.0) logo=(12.0, 6.0) best=(16.0, 140.0) score=(16.0, 256.0) to_go=(255.0, 18.0) next=(563.0, 10.0) table_top_y=442.500
M07_R05_STATE label=shorter_wider_800x1280 viewport=(800.0, 1280.0) logo=(12.0, 6.0) best=(16.0, 140.0) score=(16.0, 256.0) to_go=(295.0, 18.0) next=(643.0, 10.0) table_top_y=393.333
```

## Retained screenshots

Clean production screenshots were retained for all required viewports:

- `docs/evidence/m07_r05/canonical_720x1280.png` (`720x1280`)
- `docs/evidence/m07_r05/taller_720x1440.png` (`720x1440`)
- `docs/evidence/m07_r05/shorter_wider_800x1280.png` (`800x1280`)

The screenshots show the compact logo/BEST/SCORE stack, clear upper tabletop below the HUD, full M06-R05 playfield independence, and unchanged To-Go/NEXT/progression direction. The focused probe also verified the M07-R04 target/reward/rope/NEXT/progression/fixed-score contracts and M06-R05 radius-only bounds after this layout change.

## Checks and scope

```text
git diff --check
M07_R05_DIFF_CHECK_EXIT_CODE=0
```

Files changed in this bounded phase:

- `scripts/game_manager.gd`
- `tests/m07_r05_hud_adaptation_probe.gd`
- `docs/evidence/m07_r05/` three clean runtime screenshots
- `coordination/sessions/BCM-M07-R05/CODEX_LOG_V01.md`

The complete M01-M07 candidate regression, Godot import/startup, M07-R04 focused probe, M06-R05 full-tabletop probe, and final equality proof run after this commit as required by the master prompt.

## Publication

The separate M07-R05 commit SHA and final local/origin/remote equality are recorded after push in the final section below.

This phase does not self-audit and stops at the master prompt's independent-audit boundary.
