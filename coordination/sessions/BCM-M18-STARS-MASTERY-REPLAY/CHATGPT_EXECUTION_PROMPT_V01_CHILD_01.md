# BCM-M18-001 - Star Award Contract

Read the M18 master prompt/criteria and this child’s locked criteria first. Execute only Child 01.

Define and implement the explicit star contract using the existing `GameplaySessionBridge` result and campaign data: normal completion earns the base star; VIP completion and configured score mastery may raise the result according to the technical design; the result is clamped to 0-3 and is never an island/level unlock gate. Preserve optional VIP semantics and existing scoring/timer/physics.

Inspect `scripts/campaign/gameplay_session_bridge.gd`, `scripts/campaign/campaign_manager.gd`, the level schema, and existing probes before editing. Add focused tests for normal completion, VIP completion, score mastery, no-VIP levels, and the fact that progression does not require three stars. Do not start Child 02 until the child log and clean remote equality are complete.

Handoff log: `CODEX_LOG_V01_CHILD_01.md`.
