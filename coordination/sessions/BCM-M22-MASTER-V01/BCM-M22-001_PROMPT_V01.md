# BCM-M22-001 — Installed Plugin Contract + Graceful Fallback

Execute only after the M22 master sync/preflight.

Read:
- AGENTS.md
- root TASKS.md
- this prompt
- matching locked criteria
- exact installed addon source under `addons/game_feel_flow` and `addons/saltmire_spark`
- current project.godot

## Job
Lock the exact installed API/packaging contract before any effect coding.

Do not trust README/public docs over installed source.

### Inspect exact bytes
Record versions, hashes, autoload/editor-plugin state, callable APIs, GFF effect names/combos, Spark methods/presets and default particle properties.

Expected current source baseline, to verify rather than assume:
- GameFeelFlow 1.0.0
- Spark 1.0.0
- GFF: play/play_combo/play_global/stop/stop_all/get_effect/get_combo/resolve_combo/get_effect_names/get_combo_names
- Spark: burst/at/clear

### Optional-consumer contract
Create the smallest reusable contract/capability component needed by M22-002.

It may resolve `/root/GameFeelFlow` and `/root/Spark` and capability-check methods.

It must NOT:
- preload plugin scripts as a hard dependency;
- emit effects;
- poll every frame;
- change gameplay/campaign state.

Do not delete addon folders or rewrite third-party addon source.

Do not remove current canonical autoloads just to simulate absence.

Test consumer-level absence with controlled fixtures/singleton omission and prove no-op state parity.

Document packaging truth clearly: current release source tracks both plugins; resilience is at the consumer boundary.

Run matching criteria, publish evidence/log, commit/push, verify ref parity, then continue automatically to M22-002.

Do not edit TASKS.md.

End child with:
`M22_001_READY_FOR_MASTER_CONTINUATION`
