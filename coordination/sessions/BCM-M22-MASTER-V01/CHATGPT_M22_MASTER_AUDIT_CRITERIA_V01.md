# BCM-M22 — Master Milestone Audit Criteria V01

Status: **LOCKED BEFORE MASTER EXECUTION**

M22 contains exactly:
1. BCM-M22-001 — exact installed plugin contract/fallback
2. BCM-M22-002 — FeedbackService semantic bus + sole plugin bridge
3. BCM-M22-003 — effect-tier/FULL-REDUCED/budget policy

Child criteria are authoritative and must all pass.

## Milestone-wide invariants
- Product truth remains with existing gameplay/campaign/save authorities.
- Exactly one production bridge may call GameFeelFlow/Spark.
- Plugin absence/failure is a presentation no-op.
- No visible production effects/particles are enabled by M22.
- No physics/time authority effects.
- No RigidBody2D/collider/root/camera authority transforms.
- No score/order/VIP/star/economy/progression/save/result changes.
- Existing M21 owner-accepted visuals remain unchanged.
- Economy Draft V01 remains inactive.
- Root TASKS.md is never edited by Codex.
- M23 is not started.

## Milestone evidence
Each child has its own evidence + log.
Master log:
`docs/codex-logs/CODEX_LOG_M22_MASTER_V01.md`

Required final checks:
- exact addon/API inventory matches installed bytes
- direct plugin-call source scan passes
- semantic catalog complete
- duplicate/listener lifecycle green
- FULL/REDUCED matrix complete
- forbidden API/budget validator green
- plugin present/absent/failure state hashes identical
- current M21 critical regression subset green
- Godot parse/boot green
- git diff --check green
- final tracked tree clean
- local HEAD = origin/main = remote main; ahead/behind 0/0

## Owner gate
Builder may not declare M22 complete.
After independent GPT audit, owner must approve `M22_EFFECT_LANGUAGE_MATRIX.md` before M23 visual implementation.

Final master marker:
`AWAITING_GPT_M22_MILESTONE_AUDIT_V01`
