# M18 V02-R01 Child 05 Replay Captures

These are actual runtime viewport captures from the production `CampaignNavigationScene` and `IslandMapController` path. They were generated with Godot 4.7.2 using the non-headless console binary and the GL Compatibility renderer; no mockup or synthetic image was used.

Source probe: [`tests/m18_v02_r01_replay_capture_probe.gd`](../../../../../tests/m18_v02_r01_replay_capture_probe.gd)

Exact capture command from the canonical checkout:

```powershell
& 'C:\Users\sekip\AppData\Local\Microsoft\WinGet\Links\godot_console.exe' --path . --script res://tests/m18_v02_r01_replay_capture_probe.gd --rendering-method gl_compatibility
```

Runtime result: `M18_REPLAY_CAPTURE_RESULT=PASS` with OpenGL 3.3 / Intel Iris Xe / GL Compatibility, and all captures were saved at 720×1280 with `error=0`.

| Required state | Capture | Source state and assertion |
| --- | --- | --- |
| 1. Completed level with prior stars + best score | [`child05_completed_prior_record.png`](child05_completed_prior_record.png) | Canonical Sunny Cove data is loaded in FULL mode; the progression state starts with Child 05 completed at 2 stars and `BEST 505`; production map assertion checks `COMPLETE`, stars `2`, and best score `505`. |
| 2. Worse replay preserves visible record | [`child05_worse_replay_preserved.png`](child05_worse_replay_preserved.png) | Production `CampaignManager.mark_level_completed()` receives `{stars: 1, score: 1}`; map refresh assertion checks unchanged 2 stars and `BEST 505`. |
| 3. Improved replay updates stars + best score | [`child05_improved_replay_updated.png`](child05_improved_replay_updated.png) | Production completion receives `{stars: 3, score: 900}`; map refresh assertion checks 3 stars and `BEST 900`. |
| 4. Return to same Island Map context | [`child05_return_context_restored.png`](child05_return_context_restored.png) | Production level-selection/gameplay-return boundary is exercised after scroll `913`; assertion checks Island Map view, selected/focus level `5`, restored scroll `913`, and no gameplay instance. |

The capture probe is evidence only; independent ChatGPT audit remains required.
