# BCM-M22-003 — Locked Audit Criteria V01
## Effect-tier policy, FULL/REDUCED matrix, restrictions, lifecycle, budgets

Status: **LOCKED BEFORE EXECUTION**

### Required policy
Create one canonical executable/readable presentation policy covering every M22 semantic kind.

BCM effect language:
- MICRO
- MERGE
- ORDER
- VIP
- WIN
- MASTERY
- ISLAND_UNLOCK
- game_fail must have an explicit non-celebratory FAIL/result policy and must not masquerade as WIN celebration.

MERGE combo presentation bands:
- BASE chain 1-2
- SURGE chain 3-4
- PEAK chain >=5 with visual intensity hard-capped at PEAK; no unbounded escalation.

### FULL
May allow only presentation-safe local effects:
- short local scale/punch on presentation child nodes;
- short local alpha/color emphasis;
- bounded Spark bursts;
- restrained reveal sequencing.

### REDUCED
Must remove:
- shake;
- camera/screen motion;
- squash/stretch;
- spring/position travel;
- large confetti;
- rapid sequential motion.

Reduced uses immediate state + brief low-contrast alpha/color emphasis.
- MICRO/table-contact particles = 0
- important tiers <=25% FULL particle count, lower speed/lifetime
- same semantic information/result/reward/action remains visible

### Forbidden
Always forbidden:
- GFF impulse
- GFF velocity
- GFF freeze_frame
- GFF time_scale
- full-screen camera_flash
- authoritative root transforms
- RigidBody2D/collider/table/rail/camera authority transforms
- arbitrary generic-button feedback
- any effect that changes game truth

Camera/screen shake is disabled by default and not enabled in M22.

Stock GFF combos are blocked unless recursively audited safe. For M22, safest default is no stock combo execution in production.

### Target allowlist
Only presentation nodes, e.g. Drink/Visual/CocktailSprite, HUD visual panels, result controls, map visual entries, LevelButton visual children. Never physics roots.

### Mobile ceilings
- MICRO <=5 particles / 0.16 s
- MERGE <=10 / 0.30 s
- MERGE PEAK <=18 / 0.35 s
- ORDER <=16 / 0.45 s
- VIP <=24 / 0.65 s
- WIN <=48 live / 1.20 s
- MASTERY <=64 / 1.50 s
- ISLAND_UNLOCK <=72 / 1.60 s
- gameplay live particles <=48
- result/meta <=96
- max one large celebration at once

These are ceilings, never targets. Evidence may tighten them, not expand them.

### Spark contract
Raw built-in preset defaults may exceed lower-tier limits. Policy must apply explicit bounded overrides for amount/lifetime/speed before later use.

### Lifecycle
- cancel/clear presentation on view/session destruction;
- settings toggle cannot replay events;
- one large celebration max;
- no terminal leftover particles/nodes/listeners;
- unknown kind safely no-ops.

### M22 visual gate
M22 defines policy only. It does not enable production particles/effects. Production visual work starts at M23 after independent M22 audit + owner matrix acceptance.

### Regression
- every semantic kind has FULL and REDUCED row;
- every row has tier, allowed target, GFF permission, Spark budget, overlap/cancel rule;
- forbidden API scan;
- budget validator;
- unknown event no-op;
- settings runtime toggle;
- state/output parity;
- clean boot and M21 critical regressions.

### Owner review artifact
Create:
`coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-003/M22_EFFECT_LANGUAGE_MATRIX.md`

### Child log
`docs/codex-logs/CODEX_LOG_M22_003_EFFECT_POLICY_V01.md`

Final child marker:
`M22_003_READY_FOR_MILESTONE_AUDIT`
