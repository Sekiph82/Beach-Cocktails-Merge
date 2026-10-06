# R06 runtime smoke report

- Godot version: 4.7.2.stable.official.ed1daf0bf.
- Production startup scene: `res://scenes/campaign/ApplicationShellScene.tscn` (confirmed in canonical `project.godot`).
- Actual GUI editor launched with `godot_console.exe --path . --editor` and left open (Godot PID 17092; GUI editor PID 19656; an additional editor process PID 1884 is also present from the launch attempt).
- Actual production game launched with `godot_console.exe --path .` and left running (Godot PID 32692; game PID 5852). This loads the configured main scene, not a test harness. This is a normal project launch; an F5 keypress was not automated.
- Home probe: PASS after correcting the stale test-only Energy text x expectation from 254.84375 to the accepted layout x=259. All current Home visual checks, dynamic level/economy checks, and actual PLAY/WORLD MAP/SETTINGS navigation input checks passed.
- M20 ApplicationShell, M21 World Map V05 mouse/touch, M13 Island Map, M14 Gameplay Session Bridge, R04 surface authority, asset catalog rebuild, asset validation, editor import/parse, normal headless main-scene boot, and `git diff --check`: PASS. Exact command output is in the sibling `.log` files and `automated_check_summary.txt`.
- The M21 mouse/touch probe exercises real viewport pointer input from the visible Home action to World Map and Sunny Cove. M14 verifies level entry, gameplay bridge, pause/resume, result/retry/return and no duplicate gameplay. The full combined route was not manually driven end-to-end in the visible game in this environment.
- Current production screenshot capture tooling was unavailable for the running GUI. Home, World Map, and Sunny Cove Island Map images are captured by current production probes. `gameplay_reference_prior_v06.png` is explicitly prior R04 evidence and is not claimed as a new R06 gameplay capture.
- Save/progression reset was not performed. Probe fixtures use named test-only `user://` storage paths. Owner `user://` state was left intact.
- M07 historical-regression reconciliation and M08 post-PASS process-crash findings remain deferred for the owner review; R06 did not claim them closed.
