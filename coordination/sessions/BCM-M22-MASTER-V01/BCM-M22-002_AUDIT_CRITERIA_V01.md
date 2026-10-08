# BCM-M22-002 — Locked Audit Criteria V01
## FeedbackService semantic bus + sole presentation bridge

Status: **LOCKED BEFORE EXECUTION**

### Architecture invariants
1. `FeedbackService` remains the semantic presentation boundary and preserves existing audio/haptic behavior.
2. Exactly one production class, `PresentationFeedbackBridge` or equivalent, is allowed to invoke GameFeelFlow/Spark methods.
3. No gameplay/campaign authority moves into the bridge.
4. No visual production effect is enabled yet in M22.

### Semantic catalog
The bus must accept structured requests for:
- cocktail_launch
- table_contact
- merge
- order_progress
- order_complete
- vip_delivery
- vip_complete
- score_mastery
- game_success
- game_fail
- level_unlock
- island_milestone
- island_complete
- island_unlock
- reward_granted
- ui_primary

Each request has:
- kind
- deep-copied immutable-to-consumer payload
- source/session context where relevant
- stable event/token ID for non-MICRO one-shots
- monotonic sequence/telemetry ID allowed for diagnostics only

### Dedupe / one-shot
- existing merge-source dedupe remains;
- existing order completion token dedupe remains;
- game success/fail one-shot remains;
- non-MICRO semantic token duplicate emits exactly once;
- lifecycle/view/settings changes never replay consumed semantics.

### Bridge
- resolves plugin capabilities through the M22-001 contract;
- all calls guarded by node validity + has_method/capability;
- plugin error/missing method/unknown mapping = no-op + bounded diagnostic, never gameplay mutation;
- bridge must not mutate payload;
- no plugin calls from GameManager, ShotController, CampaignManager, GameplaySessionBridge, UI controllers, or other production classes.

### Existing seams
Wire only after authoritative facts are committed. Never emit before score/merge/order/result/progression truth exists.

### Regression
- exact-one semantic dispatch tests;
- duplicate suppression tests;
- plugin present/missing/failing matrix;
- physics/score/To-Go/VIP/stars/rewards/unlocks/save hashes identical with bridge enabled, disabled, plugins absent;
- listener count stable across retry/navigation/session replacement;
- no per-frame polling;
- M21 navigation/gameplay critical regressions green.

### Evidence
`coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-002/`
- semantic catalog JSON
- direct-plugin-call source scan
- exact-one/dedupe report
- state-hash parity report
- listener lifecycle report
- command outputs

### Child log
`docs/codex-logs/CODEX_LOG_M22_002_SEMANTIC_BRIDGE_V01.md`

Final child marker:
`M22_002_READY_FOR_MASTER_CONTINUATION`
