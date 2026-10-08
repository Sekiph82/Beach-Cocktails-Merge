# BCM-M23-R03 Combined Tuning and Color Restoration Report

Status: BUILDER EVIDENCE ONLY — `AWAITING_GPT_M23_R03_REAUDIT`.

## Scope and implementation

R03 changes are limited to `scripts/presentation_feedback_bridge.gd`, the three M23 probes, the isolated lifecycle probe and diagnostic scripts, and this R03 evidence package. No GFF addon source was changed. No gameplay physics, collision, score/economy, campaign, input, HUD geometry, or M21 production layout/navigation code was changed. Root `TASKS.md` remains untouched. No M24 work began.

The bridge now owns color operations per target. It records the target's exact `CanvasItem.modulate`, assigns a generation for each new operation, duplicates the GFF color effect resource with built-in restore disabled, and manually restores the captured base for natural completion, replacement, view changes, target exit, bridge teardown, and plugin failure. A stale generation cannot restore over the current owner. Failed plugin calls that mutate before returning false are restored immediately. Lifecycle diagnostics include event/target/generation, original/requested/final colors, reason, and exact `Color ==` result. Color restoration uses the captured value; it does not assume white.

The installed `GFFColorTarget.get_initial_value()` reads the target's current modulation, while `GFFEffect.restore_after_play` defaults to true and the final restore writes that saved per-play value. Thus, when a later invocation begins during an earlier tint, the plugin's restore snapshot can itself be transient. This source-level behavior explains a plausible persistent tint after overlapping/replaced work; it is an inference from the lifecycle implementation, not proof of every historical occurrence. R03 moves restoration ownership to the bridge's per-target generation. The prior M22 `apply_params` correction remains intact. `GFFEffect` defaults to REPLACE overlap behavior; R03 does not change that addon policy.

## Controlled profile comparison

Values below distinguish profile intent from installed Spark preset defaults. R01 used the `hit` preset's 3 px particle size for launch/contact and omitted an explicit GFF intensity. R02's values are from its committed diagnostic report and source. R03 sets explicit warmer particle colors and sizes. Merge particle lifetimes/speeds are Spark particle properties; GFF punch duration is listed separately.

| Event/profile | R01 pre-R02 | R02 | R03 |
|---|---|---|---|
| FULL launch | 4 particles; 0.14 s; 45 px/s; hit preset 3 px; GFF intensity implicit at default 1 | 4; 0.14 s; 45 px/s; size 6→1.5 px; punch .68 | 4; 0.14 s; 45 px/s; size 4→0.8 px; punch .48 |
| FULL contact | 5; 0.16 s; 40 px/s; hit preset 3 px; no explicit per-call color intensity | 5; 0.16 s; 40 px/s; size 5.5 px; strong cyan-leaning palette | 5; 0.16 s; 40 px/s; size 4.25→0.8 px; soft warm tint |
| FULL merge BASE | 10; 0.28 s; 90 px/s; hit preset 3 px; GFF duration .22 s | 10; 0.28 s; 90 px/s; 5 px; punch .45; duration .18 s | 10; 0.28 s; 55 px/s; 4 px; punch .30; duration .18 s |
| FULL merge SURGE | 10; 0.30 s; 90 px/s; hit preset 3 px; GFF duration .22 s | 10; 0.30 s; 90 px/s; 6.5 px; punch .72; duration .23 s | 10; 0.30 s; 70 px/s; 4.5 px; punch .48; duration .23 s |
| FULL merge PEAK | 18; 0.35 s; 105 px/s; hit preset 3 px; GFF duration .25 s | 18; 0.35 s; 105 px/s; 8 px; punch 1.0; duration .28 s | 18; 0.35 s; 105 px/s; 5 px; punch .68; duration .28 s |
| FULL score | No particles; color presentation | Warm/gold score tint | Softer gold tint `(1,.84,.62,1)` |
| REDUCED merge | No merge particle output | No merge particle output | No merge particle output; pale tint only |

R03 duration values remain at or below the M22 per-event duration ceilings. The approved limits remain launch 4/.14, contact 5/.16, BASE 10/.28, SURGE 10/.30, PEAK 18/.35; live particle cap remains 48. Reduced merge remains particle-free. The palette shifts from the R02 cyan contrast toward a restrained warm tropical tone. R03 reduces particle size and speed where there was excess while retaining the tier count distinction.

## Lifecycle and test evidence

- `color_lifecycle_probe.json`: PASS, 13 checks, 0 failures, 7 scenarios: natural completion; rapid contact→score→merge same-target replacement; concurrent independent targets; view change; target exit; bridge teardown; plugin mutation followed by failure. All reported restoration comparisons use exact `Color ==`.
- The headless probe emitted a non-fatal `3 ObjectDB instances were leaked at exit` warning after cleanup. The test passed, but that cleanup warning is retained here as a limitation for the independent reviewer.
- `real_renderer/capture_manifest.json`: PASS, 28 running-project viewport PNGs, 0 capture failures: FULL event+settled launch/contact/BASE/SURGE/PEAK/score at 720×1280 and 800×1422, plus REDUCED contact/merge event+settled frames at 800×1422. `all_recorded_color_restorations_exact=true`; every captured production color record restored exact source modulation.
- Renderer events were emitted through production `FeedbackService` semantic dispatch. Captures show event/settled timing but do not assert that physical collisions, merges, or score thresholds generated those events. The standalone fixture has no selected campaign island surface, so its gameplay area is gray. The frames do not establish final owner-approved visual composition. Owner F5 visual acceptance remains pending.
- Focused M23 probes: M23-001 PASS 28 checks/0 failures; M23-002 PASS 30/0, 13 dispatches and 40 active particles; M23-003 PASS 30/0, 8 score milestones.
- M22 regressions: M22-001 PASS 21 checks; M22-002 PASS 27; M22-003 PASS 97/0. Authority hash is `307023203` throughout.
- M02 physics regression PASS, including 700 px/s launch, forward-only collision response, merge and rapid-launch integrity. M09 audio/haptics PASS with headless captures unavailable. M15 VIP/economy PASS with headless captures unavailable.
- M21 full progression PASS through L1–L100 and checkpoints. Latest report is included in `regression_probes/M21-progression/`.
- M21 720×1440 mobile QA remains FAIL and separate: zero headless captures and failed `tall presentation reaches World Map` assertion. The R03 read-only navigation diagnostic records the actual 720×1440 production PLAY transition as `GAMEPLAY`; controls, campaign data, and navigation were present/configured. The probe's expected World Map destination conflicts with this observed fresh-session PLAY behavior. This explains the assertion mismatch but does not turn mobile QA green or establish a layout defect. No M21 production geometry/navigation change was made. See `m21_tall_navigation_diagnostic.json` and `regression_probes/M21-mobile-qa/`.
- Godot 4.7.2 headless editor import/parse completed with exit 0. `git diff --check` and `git diff --exit-code -- TASKS.md` are required again before commit.

## Limitations and handoff

No physical-device QA, owner F5 visual review, or independent acceptance audit was performed. Headless screenshot requests remain unavailable. The exact captured renderer sizes, synthetic event source, gray unconfigured gameplay surface, lifecycle cleanup warning, and M21 mobile-QA failure are disclosed for audit. The builder stop marker is `AWAITING_GPT_M23_R03_REAUDIT`.
