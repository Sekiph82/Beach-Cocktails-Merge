# M33 R04 bounded qualification notes

## Godot content and navigation

- Godot 4.7.2 stable, official build.
- `tests/m33_campaign_content_probe.gd`: PASS. The strict campaign manifest and FULL database loaded; all 1,000 records, all 888 generated records, nine explicit capstones, 4T/no-timer rules, unique within-island recipes, Sunny Cove bytes, and the 12 preserved Tiki seed rows were checked. It reported 361 full-recipe repeats across island boundaries.
- `tests/m33_campaign_navigation_probe.gd`: PASS. All ten island maps exposed first/middle/final level buttons. Synthetic progression unlocked all 1,000 levels in order, final level mapped to global 1000, and the schema-two save round trip preserved the unknown optional field. This is builder probe evidence, not owner acceptance or a real-input/device test.
- Both probes that write `user://` ran with a temporary unique `application/config/name`; the project file was restored byte-identically afterward (SHA-256 `16AEFDC52E70FFEC68CF7BA5726806A607A7BE0B1D0884906CF0E224419EE66A`). Their user data remained in isolated AppData profiles. Temporary profile values and output logs are not project data.
- Navigation scene loading emitted two existing invalid-resource-UID warnings for `WorldMapScene.tscn` and `main.tscn`; Godot fell back to the referenced script paths, and the probe passed.

## Production physics sample (bounded, inconclusive)

- Runner: `tools/campaign/m33_r01_physics_qualification.gd`, version `BCM-M33-R01-QUALIFICATION-1.1.0`, policy `MERGE_AWARE_V01`, content `BCM-M33.3`.
- Requested fixed sample: generated local L90 and marked L100 for all nine generated islands, one seed each (18 level-seed trials); max 200 shots/trial; five-second per-trial wall budget; 90-second global wall budget; physics scale 1.0.
- The runner stopped on its global budget after 12 trials and 96.57 seconds elapsed, a 6.57-second boundary overshoot while finishing the last trial. It sampled L90/L100 for Tiki, Azure, Coconut, Sunset, Party, and Frozen Paradise. Volcano Bay, Billionaire Island, and Final Island were not reached.
- All 12 trials stopped at the five-second per-trial wall limit after six shots and are `NOT_COMPLETED_WITHIN_BUDGET`. This sample does not establish reachability, impossibility, campaign fairness, or human completion time. Raw JSONL results, traces, and run identity are retained alongside this note.
- A second corrected generated-entry sample requested one seed each for Tiki L13 and L1 of the other eight generated islands, with 200 max shots, 25 seconds per trial, and 300 seconds globally. All nine trials reached the per-trial wall limit after 26 shots (`NOT_COMPLETED_WITHIN_BUDGET`); the batch completed in 252.66 seconds. These short trials confirm execution and telemetry across all nine generated islands but do not show objective completion or establish reachability.
- An earlier invocation used a PowerShell argument-array form that the runner did not interpret as `--level-list`; its seven inherited Tiki rows were discarded and are not part of the R04 evidence. The corrected invocation used a single quoted argument string and its metadata records the intended 18 IDs.

## Human evidence

No human playtest was performed. See `README.md` for the bounded 81-attempt ordinary sample and separate optional-capstone proposal. The 2–5 minute typical target and ≤8 minute p90 target remain unmeasured.
