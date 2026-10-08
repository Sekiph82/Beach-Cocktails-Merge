# BCM-M23-R02 Visibility Diagnostic Report

Status: BUILDER EVIDENCE ONLY — `AWAITING_GPT_M23_R02_REAUDIT`.

## Scope and source findings

This report combines the active R01 remediation with the R02 visibility investigation. Changes are limited to the feedback bridge, the installed GFF color target, and M23 probes/evidence. No score, economy, save, campaign, physics, collision, or input authority was changed.

The installed Spark pool is a `Node2D` beneath the Spark autoload on the default world canvas (layer 0). Runtime samples show the cocktail target and Spark emitter at matching viewport coordinates, with no clipping ancestors, visible parents, and valid targets. Spark reached visible particle counts in the actual render trace. A temporary test-only A/B showed particles on both the default world canvas and a temporary above-HUD layer; it did not demonstrate a production visibility improvement from layer relocation. No production layer move was made.

The measured visibility problem was primarily particle size/contrast and very short display windows, rather than missing dispatch, coordinate drift, clipping, or confirmed occlusion. The installed GFF `Color` target accepted effect calls but did not consume per-call `color` parameters. `GFFColorTarget.apply_params()` now applies the configured target color. The direct plugin contract probe covers that behavior.

## Implemented presentation changes

- FULL launch: 4 particles, 0.14 s, bounded 6 px to 1.5 px size; restrained punch scale.
- FULL contact: 5 particles, 0.16 s, bounded 5.5 px size; explicit orange tint.
- FULL merge BASE/SURGE/PEAK: 10/10/18 particles and 0.28/0.30/0.35 s; bounded 55/70/105 speed, 5/6.5/8 px size, and rising 0.45/0.72/1.0 scale intensity. PEAK and hard-cap intensity remain capped at 1.0.
- FULL score: color effect on the dynamic Control label; no score particles.
- REDUCED contact/merge/score: color-only presentation, <=0.10 s on merge/contact effects, zero merge particles.
- Diagnostics retain at most 128 events and 32 render samples per event. Runtime collection is disabled by default and is explicitly enabled by the M23 probes; disabling it clears captured traces.

All changes remain within the M22 particle/time ceilings. The M22 policy evidence reports no budget failures; authority state hash parity is unchanged at 647494875 before/after.

## Runtime and image evidence

`M23-R02_production_event_render_trace.json` contains 14 bounded production bridge traces covering FULL launch/contact/merge BASE/SURGE/PEAK/score and REDUCED contact/merge bands/score. Each trace records semantic ID where supplied, policy, GFF call, Spark call, emitter creation, target/emitter canvas and screen coordinates, visibility/clipping state, active visible particle counts, and sampled frame data. Trace samples show active drawn particles for launch/contact/merge in FULL, and none for REDUCED; score categories do not emit Spark particles.

Real-renderer captures are in this folder, including `03_ab_default_world_canvas.png`, `04_ab_above_hud_layer.png`, `10_full_launch_updated.png`, `11_full_contact_color_fix.png`, `12_full_merge_base_updated.png`, `13_full_merge_surge_updated.png`, `14_full_merge_peak_updated.png`, `15_full_score_color_fix.png`, and the corresponding `21`–`25` REDUCED captures. The screenshot captures are genuine game viewport images. Some snapshots were taken after the event window and therefore show the settled scene; they are not evidence that the transient effect is visibly strong in every frame. The strongest pixel-level visibility evidence is the temporary high-contrast A/B capture, while production event render samples prove particles were drawn. Owner visual acceptance remains pending.

Controlled FPS observations recorded during this run: Engine-limited 15 FPS reported 15 FPS and 66.67 ms process delta; 30 FPS reported 30 FPS and 33.33 ms; 60 FPS reported 60 FPS and 16.67 ms. A separate 30 FPS launch capture is `16_fps30_launch.png`. The observed laptop/default cap reported roughly 58–61 FPS during ordinary capture, with dips during instrumented bursts. The final aggregate trace's end-of-run FPS field fell to 2 FPS while debugger/capture work was active; this is not a valid per-event controlled-rate result and is retained as a limitation, not interpreted as ordinary device performance. Maximum observed process delta in the aggregate trace was 150 ms.

The production event trace uses a running game launched through the Godot editor, followed by actual Home Play input and synthetic mouse launch input routed through `ShotController._unhandled_input`. Contact/merge/score events were seeded through the production `FeedbackService` semantic API; they do not claim a physical collision, real merge, or score-threshold crossing generated the observed event.

## Test and regression evidence

- Godot 4.7.2 headless M23-001: `M23_001_MICRO_FEEDBACK_RESULT=PASS checks=28 failures=0 dispatches=5 cooldown_ms=120 captures=0`.
- Godot 4.7.2 headless M23-002: `M23_002_MERGE_FEEDBACK_RESULT=PASS checks=30 failures=0 dispatches=13 active_particles=40 captures=0`.
- Godot 4.7.2 headless M23-003: `M23_003_COMBO_MILESTONE_RESULT=PASS checks=30 failures=0 score_milestones=8 captures=0`.
- M22-001 plugin contract: PASS, checks=21, authority hash 647494875.
- M22-002 semantic bridge: PASS, checks=27, authority hash 647494875.
- M22-003 policy/budget/state-hash parity: PASS, checks=97, failures=0; forbidden API scan and budget validator report no violations; before/after state hash 647494875.
- M02 gameplay physics regression: PASS, including 700 px/s launch baseline and rapid-launch/multiple-body behavior.
- M09 audio/haptics regression: PASS, including M08 merge-feedback and delivery-trail cleanup checks. Headless screenshot captures unavailable.
- M15 VIP/economy regression: PASS. Headless screenshot captures unavailable.
- M21 full progression L1–L100: PASS at checkpoints 1/25/50/75/100; report retained under `regression_probes/M21-progression/M21-003_FULL_PROGRESSION.json`.
- M21 mobile QA probe: FAIL in headless GL Compatibility. It produced 0 captures, missed the tall 720x1440 World Map navigation assertion, and consequently failed the requested image availability checks. Evidence says physical device acceptance is deferred to owner-native M21-006. This task did not alter the M21 navigation/layout scope; the failure remains visible for independent review.
- Godot headless editor import/parse: exit 0; GFF color target class registered and no parse errors.
- `git diff --check`: pass. `git diff --exit-code -- TASKS.md`: pass (unchanged).

Regression probe copies and their JSON reports are retained under `regression_probes/` to preserve earlier evidence. The M21 mobile QA failure is not represented as a pass.

## Limitations and handoff

No physical-device acceptance, owner visual acceptance, or independent audit was performed. Transient effect visibility should be judged from the retained real-renderer captures and trace, with the acknowledged after-window captures and aggregate FPS sampling limitation. No M24 work began. Root `TASKS.md` was not modified. The owner-local `project.godot` diff and both owner PNGs were preserved and excluded from the intended commit.

Required stop marker: `AWAITING_GPT_M23_R02_REAUDIT`.
