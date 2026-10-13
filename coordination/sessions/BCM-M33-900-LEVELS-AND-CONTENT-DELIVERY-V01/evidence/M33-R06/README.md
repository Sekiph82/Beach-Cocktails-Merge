# BCM-M33-R06 Owner Playability Kit

Status: builder implementation evidence; awaiting owner real play and independent GPT audit.

## Start

1. Open the existing project folder `C:\Users\sekip\Desktop\Beach Cocktails - Merge` in File Explorer.
2. Double-click `tools\START-BCM-M33-R06-OWNER-PLAYTEST.cmd` inside that folder.
3. The launcher requires Godot `4.7.2`; it finds the executable on PATH or in the standard WinGet links. It opens the R06 sample selector directly. It does not create a Desktop shortcut or start without that explicit double-click.
4. Confirm the selector says `SAVE ISOLATION VERIFIED`. The production campaign save file is neither read nor written in this mode. The test profile is under `%LOCALAPPDATA%\BeachCocktailsMerge\M33-R06-OwnerPlaytest`.
5. Select a sample row to preview the actual campaign island, level, global ID, To-Go/VIP objectives, starter inventory, predicted T and move limit. Press **START SELECTED SAMPLE IN PRODUCTION GAMEPLAY** to enter the existing `ApplicationShellScene → CampaignNavigationController → CampaignGameplay` path.

The test mode applies temporary in-memory unlocks only so samples across the generated islands can open. It does not write those unlocks, stars, rewards, campaign progress, or economy to normal saves. The selector marks this boundary visibly.

## Controls and exit

- Tap or click the tabletop, drag horizontally to aim, then release to launch. This uses the same production `ShotController`, physics and live gameplay scene as normal play.
- Use production result controls for **Retry** and return-to-map behavior.
- The **SAMPLES** button leaves the current attempt and returns to the chooser; that attempt is recorded as `returned_to_samples`.
- Close the Godot window to stop. Closing during an attempt records `application_closed`.
- To return to normal play, close the test window, then open the same existing project path in Godot Project Manager and run the project normally. Do not use the R06 launcher for normal play. The normal campaign save remains in the usual Godot user-data location.

## Sample matrix

The first nine rows are the generated-island entry samples. The starter contrasts reuse genuine level definitions and global IDs. `T` is the candidate's theoretical committed-shot count; move limit is the content field's 4× T budget. VIP is optional.

| Sample | Island/local level | Immutable global ID | To-Go objectives | Starter stock | T | Move limit |
|---|---|---:|---|---|---:|---:|
| ENTRY_TIKI | tiki_island/1 | 101 | L5×1 | empty | 4 | 16 |
| ENTRY_AZURE | azure_bay/1 | 201 | L8×1, L6×1 | empty | 40 | 160 |
| ENTRY_COCONUT | coconut_beach/1 | 301 | L7×1, L8×1 | empty | 48 | 192 |
| ENTRY_SUNSET | sunset_island/1 | 401 | L6×1, L8×1 | empty | 40 | 160 |
| ENTRY_PARTY | party_beach/1 | 501 | L7×1, L8×1 | empty | 48 | 192 |
| ENTRY_FROZEN | frozen_paradise/1 | 601 | L7×1, L8×1 | empty | 176 | 704 |
| ENTRY_VOLCANO | volcano_bay/1 | 701 | L8×1, L6×1 | empty | 40 | 160 |
| ENTRY_BILLIONAIRE | billionaire_island/1 | 801 | L7×1, L6×2 | empty | 32 | 128 |
| ENTRY_FINAL | final_island/1 | 901 | L7×1, L6×1 | empty | 24 | 96 |
| CONTRAST_EMPTY | azure_bay/1 | 201 | L8×1, L6×1 | empty | 40 | 160 |
| CONTRAST_ONE | azure_bay/8 | 208 | L8×1, L7×1 | L6 | 48 | 192 |
| CONTRAST_TWO | tiki_island/27 | 127 | L6×2, L7×1 | L5; L5 | 32 | 128 |
| OPTIONAL_L9_CAPSTONE | final_island/100 | 1000 | L9×1, L6×1 | L5 | 72 | 288 |

Content revision shown in the console and telemetry: `BCM-M33.5`. Campaign definitions remain untimed; the prediction is not a timer.

## Telemetry and sharing

The isolated profile stores append-only `attempts.jsonl`, `attempts.csv` and the owner-readable `OWNER_PLAYTEST_REPORT.md` under its own `user://m33_r06` directory. `PROFILE_INFO.txt` at the profile root records the actual isolated path and the normal-path comparison. The report captures a privacy-safe run ID, sample and global ID, content revision, start/end monotonic ticks, elapsed seconds, shots, To-Go and VIP delivery counts, win/loss result, retries, stars, starter inventory and leave reason.

After playing, share `OWNER_PLAYTEST_REPORT.md` and `attempts.csv` from the path shown at the top of the report. Do not send campaign saves or the full profile folder. No manual source-log review is needed.

## Bounded builder checks

Run from the project root with Godot 4.7.2 and an isolated profile environment:

```powershell
$profileRoot = Join-Path $env:LOCALAPPDATA 'BeachCocktailsMerge\M33-R06-Probe'
$env:APPDATA = Join-Path $profileRoot 'appdata'
$env:BCM_M33_OWNER_PLAYTEST = '1'
$env:BCM_M33_TEST_PROFILE_ROOT = $profileRoot
$env:BCM_M33_NORMAL_USER_DATA = Join-Path (Join-Path (Join-Path $env:USERPROFILE 'AppData\Roaming') 'Godot\app_userdata') 'CocktailMerge'
godot_console.exe --headless --path . --script res://tests/m33_r06_owner_playtest_probe.gd
```

The probe checks the runtime `user://` path, disabled normal persistence, all 13 sample/global-ID mappings, starter distributions, production scene entry, real viewport mouse shot input, move count, the production merge queue through L5, To-Go target capture, untimed state, production Retry, leave-to-selector, and isolated telemetry/report creation. Headless mode cannot produce the required graphical captures. Graphical screenshot capture runs of the same probe save the selector and one-starter gameplay viewport to this evidence folder.

Prior focused production checks that complement this bounded R06 probe: `tests/m14_gameplay_session_bridge_probe.gd` exercises objective delivery, VIP, terminal state and retry; the R06 probe itself exercises the live game input and merge/delivery path.

## Screenshot evidence

- [R06 sample selector at 720×1280](R06_SAMPLE_SELECTOR_720x1280.png)
- [Production gameplay with one L6 starter at 720×1280](R06_GAMEPLAY_ONE_STARTER_INITIAL_720x1280.png)

## Acceptance boundary

Automated probes and screenshots are builder evidence only. Owner human play, timing and subjective playability review are pending. This kit does not qualify all 900 generated levels, change the protected 12-level Tiki seed or Sunny Cove, retune physics, or replace the independent audit.

Required stop marker: `AWAITING_OWNER_M33_R06_REAL_GAMEPLAY_TEST_AND_GPT_AUDIT`.
