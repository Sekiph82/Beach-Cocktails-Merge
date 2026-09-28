# M17 Telemetry Schema V02

This document defines the corrected M17 validation telemetry. It is builder evidence and does not replace the independent audit.

## Outcome semantics

| Field | Meaning |
|---|---|
| `outcome` | `completed`, `danger`, `timeout`, or bounded `harness_abort`. WIN terminal results are `completed`; table-danger/game-over results are `danger`; only actual time-limit exhaustion is `timeout`. |
| `terminal_reason` | Preserved production bridge reason, including `TABLE_DANGER` and `TIMEOUT`; bounded non-terminal exits retain their harness reason. |
| `danger_line_exposure_sec` | Fixed-step duration during which a settled production drink extends below the configured danger line. This is diagnostic exposure, not a replacement for the production game-over terminal. |

`TABLE_DANGER` must never be counted as `timeout`. The V01 report contains the known danger/timeout misclassification and must not be used for tuning.

## Contact and rail metrics

| Field | Meaning |
|---|---|
| `contact_count` | Count of `Drink.body_entered` body-collision callbacks. It is retained as a production callback metric and does not claim to measure rail interaction. |
| `rail_contact_count` | Deterministic footprint-to-authoritative-playable-boundary proximity transition proxy. It is not a PhysicsServer/body-collision callback count. |
| `rail_contact_metric` | Machine-readable value `footprint_proximity_transition_proxy`. |
| `rail_enter_threshold_px` | `<= 1.0` signed footprint distance enters the near-rail state. |
| `rail_release_threshold_px` | `> 3.0` signed footprint distance releases the near-rail state. |

For every live non-held drink and every edge returned by `GameManager.get_playable_boundary_edges()`, the harness calculates the minimum signed distance over the drink footprint. State is keyed by drink instance ID and edge name. A false-to-near transition increments `rail_contact_count` once; continued proximity does not repeat the event; release beyond 3 px clears the state; later re-entry creates a new event. Keys absent from the current live-drink/edge sample are deleted as stale.

The proxy uses production boundary geometry without changing collision layers, colliders, gameplay physics, or canonical level data.

## Report interpretation

V02 reports retain the V01 seed formula, baseline lane policy, analytical cost/timer model, R7 percentile method, and explicitly documented physics time scale. Each required level has exactly three trials. Report counts are derived from underlying trial outcomes, and the Markdown table includes the median rail-proxy event count. A weak deterministic bot is not an impossible-level verdict and must not be used to tune canonical Sunny Cove data.
