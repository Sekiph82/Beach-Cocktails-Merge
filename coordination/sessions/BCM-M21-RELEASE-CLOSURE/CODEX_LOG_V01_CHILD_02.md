# CODEX Execution Log — BCM-M21 V01 Child 02

Status: `BUILDER_PASS / AWAITING_M21_CHILD_03`

Work item: `BCM-M21-002 — Performance and stability profile`

Authority:
- `CHATGPT_EXECUTION_PROMPT_V01_CHILD_02.md`
- `CHATGPT_AUDIT_CRITERIA_V01_CHILD_02.md`
- `CHATGPT_AUDIT_CRITERIA_V01.md`

## Ordered publication

- Start HEAD after Child 01 publication equality: `2db11aeee3fc661602eccc8721b52c46031e1033`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Start status: clean `main...origin/main`.
- Required sync fetch: completed; no divergence.
- Root `TASKS.md` was not edited; SHA-256 remains
  `10f8ebf6269a7323d8c8e89d596b777a4334fcdf1d836ac2b2220b8ab2bae9b3`.
- Implementation/evidence commit: `4effe66b58ea62261bea2f804a25da365804ea56`.
- Implementation push completed before this log publication.

## Scope and files

- Added `tests/m21_performance_profile_probe.gd`.
- Added `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/performance/M21-002_PERFORMANCE_STABILITY_PROFILE.json`.
- Added the accompanying Markdown measurement report.
- No product feature, campaign data, gameplay authority, physics, timer,
  reward, economy, table, or HUD change was made.

## Exact commands and results

- `godot_console.exe --headless --path . --check-only --script res://tests/m21_performance_profile_probe.gd` — exit `0`.
- `godot_console.exe --headless --path . --script res://tests/m21_performance_profile_probe.gd` — exit `0`.
- Probe marker: `M21_CHILD_02_RESULT=PASS samples=21 frame_samples=60`.
- `git diff --check` — clean before implementation commit.

The first development run exposed a probe-only invalid `void` return-value
comparison before the map-cycle loop. That harness defect was corrected before
the recorded run; the final run completed all 12 map cycles and emitted no
script error.

## Measured evidence

- 12 Island Map open/close/scroll cycles.
- 8 gameplay launch → LOSE → result-action → Island Map cycles.
- 20 campaign save writes and reads; every result valid; payload 301 bytes in
  every sample.
- 20 Settings writes and reads; all schema version 1.
- 20 onboarding writes and reads; all completed state.
- World Map remained 10 entries/10 nodes; Island Map remained 100 level buttons;
  map authority remained 2 instances.
- Gameplay authority was 1 while active and 0 after each return to map.
- Object count range: 2,867–2,934 across lifecycle samples; no progressive
  increase after warmup/cycle repetition.
- Orphan node count: 0 for all 21 samples.
- Host frame sample: 60 samples, min `0.018 ms`, median `7.856 ms`, average
  `7.662 ms`, max `16.230 ms`.

## Limitations

- Windows desktop host only; no physical mobile device performance result.
- Frame-time values are not an Android/iOS FPS benchmark.
- Memory/thermal/safe-area/touch latency remain owner-native gates.

## Publication equality

Publication commit: to be recorded after this log commit.

After publication, `git rev-parse HEAD`, `git rev-parse origin/main`, and
`git ls-remote origin refs/heads/main` must report the same SHA before Child 03.
