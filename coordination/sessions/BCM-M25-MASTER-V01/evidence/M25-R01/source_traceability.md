# BCM-M25-R01 source-to-criterion traceability

This is a builder evidence index. It does not assign acceptance.

| Child criterion | Production source | Focused evidence | R01 disposition |
| --- | --- | --- | --- |
| M25-001: immutable title/body/score/stars/reward and action choices | `scripts/campaign/campaign_feedback_overlay.gd::show_result`; `scripts/campaign/campaign_navigation_controller.gd::_on_session_terminal` and `_present_pending_terminal_result` | `tests/m25_result_presentation_probe.gd`, 22/22; M21/M24 route and overlay regressions | Synthetic fixture checks pass. Real FULL/REDUCED gameplay WIN captures exist. Pointer activation of result actions did not route in the real-input capture. |
| M25-001: bounded entrance, no gameplay change, duplicate terminal suppression | `scripts/presentation_feedback_bridge.gd::emit_semantic` and `::_result_presentation_plan`; `campaign_navigation_controller.gd::_on_session_terminal` | M25 result probe checks duplicate semantic suppression, immutable source payload, visible opaque settled result; GL gameplay captures | Existing implementation is integrated with the M25-002/003 planner, so no separately committed no-Spark intermediate M25-001 build exists. |
| M25-002: ordinary WIN/mastery/first-clear/reward tier order and 48-live cap | `scripts/presentation_feedback_bridge.gd::_result_presentation_plan` (tier selection and live-particle clamp); result-token guard in `emit_semantic` | M25 result probe checks 1/3-star, first-clear, new reward, duplicate suppression and active live pool; M22 policy 97 checks; M23-002 peak 40 | Focused checks PASS; genuine FULL and REDUCED WIN each reached 3 stars. Genuine 1- and 2-star results were not obtained. |
| M25-002: plugin absence and exact effect restoration | `scripts/presentation_feedback_bridge.gd` plugin readiness guards and cancellation/restore path | M22-001 21 checks; M22-002 27 checks; M23 R03 color lifecycle 13 checks / seven scenarios | Absent-plugin no-op and exact Color equality probes PASS. |
| M25-003: calm LOSE cue, no Spark, retry/map actions | `scripts/presentation_feedback_bridge.gd::_result_presentation_plan` `game_fail` branch; `campaign_feedback_overlay.gd::show_result` and button signal path | M25 result probe checks no Spark, duration caps, unchanged result text, Retry/Island Map, stable button bounds and single Retry emission | Synthetic policy/action checks PASS. Genuine FULL and REDUCED gameplay LOSE routes were not obtained; report this as an open acceptance gap. |
| M21 R01 process shutdown | `tests/m21_mobile_qa_probe.gd::_cancel_bridges_under`, `::_shutdown_rendering_tree`, `_run` teardown | `evidence/M25-R01/clean_gl_run_01` and `clean_gl_run_02`; each 16 captures, assertions PASS, GL exit 0; prior WER fault record | Repeatable teardown mitigation passes. WER identifies Intel GL driver fault at process exit; exact vendor driver root cause remains unproven. |

## Integrated-delivery deviation

The M25-001, M25-002 and M25-003 implementation was already delivered together in the prior integrated source commit. This R01 contains no retroactive child commits and does not claim an independently built M25-001 intermediate state.
