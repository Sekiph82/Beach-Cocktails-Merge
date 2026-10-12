# BCM-M32-004 — Interactive Gameplay Tutorial V01

Status: `INTERACTIVE_TUTORIAL_IMPLEMENTED; BUILDER_EVIDENCE_ONLY`.

## Authority and repository state

- Work item: `BCM-M32-004 — Implement the interactive touch-first gameplay tutorial`.
- Prompt and criteria: `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/`.
- Start HEAD: `4c5743f454acc095298f8cb9fe1770ec380da77f` on `main`.
- Product commit: `11fcbb7efdb0888cb77b3d0caa5a51bd68720d9d` (`BCM-M32-004: add interactive gameplay tutorial`).
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Root `TASKS.md` was not modified. M21/M22 owner-local tracked edits and all owner-local untracked files were left unstaged and preserved.

## Changes

- Added a six-step touch-first lesson for launch, merge, To-Go delivery, optional VIP, moves/stars, and Retry. Launch, merge, and accepted delivery steps advance from production gameplay events.
- Added Skip, Settings replay, one-time saved completion, and resumable step state. A first-run tutorial starts only when no level completion exists, so established profiles are not forced through it.
- Added Reduced Motion and High Contrast presentation handling. No timer, scripted gameplay win, score shortcut, or physics change was introduced.
- Added Retry to the Win Results action set and wired the production Retry action to finish the lesson.
- Adjusted the tutorial prompt panel and launch/merge highlight bounds after phone-size renders showed clipping.
- Updated stale M25 and M27 regression fixtures to load the full currently authored staged campaign file set. Updated the M20 UX expectations for Win Retry and active-level loss copy.
- Added a phone viewport capture probe and committed Windows-rendered 390x844 and 432x960 gameplay/tutorial frames with a bounds report under `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/evidence/M32-004-tutorial/`.

## Validation performed

- Godot `4.7.2.stable.official.ed1daf0bf` in isolated project `C:\Users\sekip\.codex\sandboxes\BCM-M32-CAMPAIGN-FOUNDATION-V01-20261012-01a12fc6`, with verified custom `user://` location. The owner profile was not used.
- Clean editor import: exit 0; no import parse failure; PID runner verified zero matching Godot processes after cleanup.
- `tests/m32_economy_tutorial_probe.gd`: exit 0, `M32_ECONOMY_TUTORIAL_RESULT=PASS`. It sent a real `InputEventScreenTouch` through production `ShotController._unhandled_input`, exercised GameManager merge and delivery hooks, and triggered the production Results Retry action.
- `tests/m32_tutorial_mobile_capture_probe.gd`: windowed GL run exit 0, `M32_TUTORIAL_MOBILE_RESULT=PASS`. The tutorial prompt bounds fit 390x844 and 432x960 viewports with Reduced Motion and High Contrast enabled. Captures are desktop-rendered viewport evidence, not physical iPhone/Android captures.
- `tests/m20_campaign_ux_probe.gd`: exit 0, `M20_CHILD_05_RESULT=PASS`.
- `tests/m25_move_limit_probe.gd`: exit 0, `M25_PERCENT400_RESULT PASS` for 100 Sunny Cove levels, 25 VIP levels, and expected overlap set.
- `tests/m27_002_campaign_unlock_probe.gd`: exit 0, `M26_002_CAMPAIGN_MAP_RESULT=PASS`.
- Earlier closure runs also passed M32 economy/shop, Focus booster, and Tiki vertical-slice probes. The legacy M17 canonical-screening probe remains red on four assertions; this child did not diagnose their cause. The M32 master log records the exact failure labels.
- `git diff --check` passed before commit. Product commit was pushed to `origin/main`; at publication `HEAD`, `origin/main`, and remote `main` all equaled `11fcbb7efdb0888cb77b3d0caa5a51bd68720d9d` with `0/0` divergence.

## Limits and handoff

- Rendered portrait viewports are layout evidence only. Physical iPhone/Android touch and visual acceptance remain unverified.
- The level content, shop pricing, and booster baseline remain provisional or incomplete as described in the prior M32 child logs. No claim of 1,000 playable levels is made.
- Independent ChatGPT audit and owner gameplay/design review remain pending.
