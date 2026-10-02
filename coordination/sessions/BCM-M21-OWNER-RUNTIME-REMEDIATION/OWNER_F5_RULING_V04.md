# BCM-M21 Owner F5 Ruling V04 — Map Calibration, Landmark Level Layout, Lower Table, Result Lifecycle

Date: 2026-10-02
Status: **OWNER-AUTHORITATIVE**

This ruling records the owner's second manual F5 review after V03.

## Owner checklist result

PASS:
- 1 — 800×1422 debug view is accepted.
- 6 — real gameplay input/playability is accepted.
- 7 — no countdown / no TIME UP is accepted.
- 8 — Pause → Resume is accepted.
- 10 — restart persistence is accepted.

PARTIAL / FAIL:
- 2/3 — yellow runtime routes are gone and Sunny Cove is lower-left, but World Map island interaction/state markers still do not sit on the actual baked island visuals.
- 4 — Sunny Cove has its own map background, but level nodes are not on the owner-marked landmarks and connector lines must not exist.
- 5 — wooden table is visible, but the complete table/playable geometry is too high; owner marked a lower target. Residual foreground/decor is still visible.
- 9 — gameplay completion persists, but the WIN result surface fails to appear; result buttons do not appear.

## 1. World Map hotspot calibration

The 10 island interaction/state centers must sit on the actual themed island visuals baked into the canonical World Map.

Current `map_position` values are not accepted merely because they are data-driven.

Owner-visible target seeds, transcribed from the 2026-10-02 F5 screenshot and expressed in the existing MapCanvas normalized coordinate system:

- sunny_cove: [0.15, 0.88]
- tiki_island: [0.12, 0.65]
- azure_bay: [0.64, 0.80]
- coconut_beach: [0.28, 0.52]
- sunset_island: [0.50, 0.52]
- party_beach: [0.81, 0.59]
- frozen_paradise: [0.75, 0.03]
- volcano_bay: [0.23, 0.04]
- billionaire_island: [0.61, 0.19]
- final_island: [0.82, 0.36]

These are calibration seeds, not permission to blindly copy numbers. Final centers must be visually refined onto the actual baked island bodies, within ±0.025 normalized adjustment when needed.

Runtime island thumbnail art remains hidden. State ring/name/lock/click target must share the exact same calibrated center.

No runtime route line is reintroduced.

## 2. Sunny Cove Island Map landmark layout

Owner rejects the procedural alternating zig-zag node layout and all connector lines.

For Sunny Cove, use a 10-slot landmark page layout.

Owner-marked canonical full-viewport level-center targets for slots 1..10:

1. (353, 272)
2. (647, 327)
3. (169, 427)
4. (402, 486)
5. (616, 586)
6. (66, 664)
7. (642, 789)
8. (386, 839)
9. (162, 942)
10. (553, 1078)

With the current fixed 178 px Island Map header, equivalent scroll-page local centers are approximately:

1. (353, 94)
2. (647, 149)
3. (169, 249)
4. (402, 308)
5. (616, 408)
6. (66, 486)
7. (642, 611)
8. (386, 661)
9. (162, 764)
10. (553, 900)

Tolerance: ±12 canonical pixels per center.

Sunny Cove 100-level behavior:
- page/block 1: L1-L10 use slots 1-10;
- page/block 2: L11-L20 use the same 10 landmarks on a repeated Sunny Cove map page;
- continue through L91-L100;
- one background page per 10-level block;
- selected/current level page opens automatically;
- completed/open/locked state remains authoritative;
- **no Line2D/connector path is visible**.

This layout must be data-driven so future islands can define different landmark slots.

## 3. Sunny Cove table vertical placement

Owner accepts the wooden table design but rejects its current vertical placement.

The table/playable system must be translated **150 canonical pixels downward** as one rigid system.

Move together by +150 px Y:
- gameplay_table_shadow visual;
- gameplay_table visual;
- table_edge_overlay visual;
- logical launch line;
- rear/front/table rail geometry;
- death/launch Y;
- R11 playable footprint coordinate system.

Do **not** rescale the table or change the rail shape. This is a pure translation.

The gameplay background and HUD remain fixed.

A translation-invariance report must prove the R11 shape is identical after subtracting the +150 Y offset.

## 4. Residual decor / launch-zone art

The owner still sees unwanted foreground decoration.

The previous V03 proof showed `decor_left/right/back` files are not rendered. Therefore the remaining decoration must be isolated from the five active theme layers.

New owner rule:
- do not render `launch_zone.png` as a full-screen decorative Sprite2D;
- retain launch mechanics;
- if a launch boundary indicator is desired, draw only a simple programmatic line at the translated launch Y;
- do not restore decor_left/right/back;
- preserve canonical source PNGs unchanged.

Produce a five-layer isolation contact report identifying what each active layer contributes.

If unwanted residual foreground is still present after removing launch-zone art, identify its exact source layer. Remove only the foreground decorative pixels/nodes while preserving the wooden table and background identity. Original canonical assets remain unchanged; any cleaned derivative must be a new runtime asset with provenance.

## 5. Result lifecycle is a release blocker

Owner runtime debugger captured these production errors:

1. `campaign_navigation_controller.gd:235 @ _ensure_result_feedback(): Parent node is busy setting up children, add_child() failed. Consider using add_child.call_deferred(child) instead.`
2. `CampaignFeedbackOverlay._show: Invalid assignment of property or key 'text' ... on a base object of type 'Nil'.`

Observed behavior:
- To-Go objective reaches completion;
- progression/save advances;
- gameplay remains visually stuck at 0 remaining orders;
- WIN result and buttons do not appear;
- after restart, the next level is correctly unlocked.

This proves campaign completion logic succeeds but result presentation lifecycle is broken.

Required result behavior:
- result surface is fully instantiated/ready before any `show_result()`;
- no `root.add_child()` during SceneTree child-setup contention;
- result presentation may be deferred safely, but terminal result payload must not be lost;
- `CampaignFeedbackOverlay` must never access null title/body/action controls;
- WIN card appears exactly once;
- Next Level and Island Map actions work;
- LOSE card Retry/Island Map remain valid;
- no gameplay input or score/delivery mutation after terminal;
- zero red Godot runtime errors during the full completion/result/action flow.

The fact that progression already persisted does not count as result PASS.

## 6. Audit rule

No automated probe can close these owner-visible surfaces without another owner F5 review.

V04 technical handoff must stop at:
`AWAITING_OWNER_F5_ACCEPTANCE_V04`
