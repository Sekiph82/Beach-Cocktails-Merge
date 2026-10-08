# BCM-M24-R01 Validation Evidence

Status: builder evidence prepared; independent ChatGPT re-audit required.

## Runtime validation

All headless probes ran from redirected runner copies under `runners/`; `APPDATA` pointed to `%TEMP%\BCM-M24-R01-appdata`. This isolates `user://` saves. Fixed evidence paths were redirected to this R01 evidence directory. The copied runners are included for review.

| Suite | Result | Checks |
|---|---:|---:|
| M02 physics | PASS | 22 |
| M09 audio/haptics | PASS | 21 |
| M15 VIP/economy | PASS | 63 |
| M21 full progression | PASS | 1–100, 5 persistence checkpoints; 1,352 assertions |
| M21 release persistence | PASS | 9 |
| M22-001 plugin contract/fallback | PASS | 21 |
| M22-002 semantic bridge | PASS | 27 |
| M22-003 effect policy | PASS | 97 |
| M23-001 micro feedback | PASS | 28 |
| M23-002 merge feedback | PASS | 30 |
| M23-003 combo/milestone | PASS | 30 |
| M23-R03 color lifecycle/restoration | PASS | 13 checks, 7 scenarios |
| M24-001 order progress | PASS | 7 |
| M24-002 order completion | PASS | 8 |
| M24-003 VIP feedback | PASS | 8 |
| Godot GL Compatibility 120-frame boot | PASS | exit 0 |
| M21 real-renderer mobile QA | PASS | 16 captures; 720×1280 and 720×1440 |

The suite logs and generated JSON reports are in `regression/`. Mobile screenshots and report are in `mobile_qa/`.

## Gameplay acceptance captures

`gameplay_acceptance/FULL_FPS/` and `gameplay_acceptance/REDUCED_FPS/` contain production gameplay screenshots. The capture runner uses the M15 campaign fixture through production `CampaignNavigationScene`, `GameplaySessionBridge`, `GameManager` collection callbacks, `FeedbackService`, and `PresentationFeedbackBridge`; it does not call M24 semantic dispatch directly to fabricate acceptance.

- To-Go progress: 0/2 prior, accepted 1/2 with source token `gameplay-order-1`, settled 1/2; then accepted 2/2 with token `gameplay-order-2`, settled 2/2. The final completion takes the normal WIN route; no second completion flourish was layered over WIN.
- Nonterminal order completion: level 3 L6 order completes while L8 remains; state is `normal_completed={6:1,8:0}`, `normal_remaining={6:0,8:1}`. The normal target advances to L8.
- VIP delivery: 0/2 prior, accepted 1/2 with source token `sunny_cove:1`, settled 1/2; then accepted 2/2 with token `sunny_cove:2`, settled 2/2. VIP fields remain unchanged through the To-Go deliveries in the other scenario.
- The To-Go / VIP HUD geometry is unchanged in the captures. FULL shows brief local gold/cyan spark accents near objective visuals. REDUCED has no order-progress particles and keeps the immediate progress state. No duplicate WIN presentation was observed.
- Instantaneous `Engine.get_frames_per_second()` samples are included in the GL gameplay logs. Capture samples ranged 2–37 FPS in FULL and 2–36 FPS in REDUCED; these include startup and screenshot work and are not a steady-state device benchmark.

The two authoritative capture logs are `gameplay_acceptance/m24_full_acceptance_order_complete_final_gl.log` and `gameplay_acceptance/m24_reduced_acceptance_order_complete_final_gl.log`. They record mode, dimensions, FPS, source tokens, accepted objective state, probe result, and exit code.

## Test setup notes and limits

- M22-003 had two initial isolated-run setup failures: the redirected folder was not created, then its copied matrix was marked read-only even though that probe verifies a writable isolated matrix. The corrected writable R01 copy passed 97 checks; canonical M22 evidence was restored from the pre-run owner snapshot and its hashes match.
- An early M15 GL capture attempt hit an overwrite/save error for an existing R01 image. The final captures use unique `FULL_FPS` / `REDUCED_FPS` output directories and both runs pass.
- One preliminary M02 invocation ran before `APPDATA` isolation was set. It reported the user save path and game-over score 0; the authoritative rerun used the isolated temp path and passed. The existing `CocktailMerge/save.cfg` currently reads `best=321`; no pre-run byte snapshot exists, so this preliminary read/write exposure cannot be proven byte-identical. No manual restore was attempted.
- Owner F5 physical-device acceptance remains separate and unclaimed.
