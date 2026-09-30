# BCM-M19-001 — Multi-Island Loader / Shared Runtime

Execute only Child 01.

Generalize LevelDatabase so one instance can load level roots for multiple islands while preserving the existing single-root public API. Add the minimum new API/data-loader surface needed for multi-island use.

Use focused fixture data to prove two content-bearing islands can run through the same LevelDatabase, CampaignManager, SaveManager, reusable WorldMap/IslandMap, GameplaySessionBridge and gameplay scene. Do not create canonical Tiki level content.

Reject duplicate ids, wrong root island ids and declared-count mismatches. Preserve zero-level canonical placeholders.

Log to `CODEX_LOG_V01_CHILD_01.md`. Stop on failure before Child 02.
