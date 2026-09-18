# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V10

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

V09 failed owner runtime verification.

Two owner-observed failures must be fixed together:

1. the rear/opposite-edge visible gap still remains;
2. cocktails can visibly cross outside the accepted left/right playable envelope.

In addition, the independent V09 audit found that the runtime visual contact hull transform does not exactly match the rendered Sprite2D transform.

V10 is a remediation round. Do not redesign unrelated gameplay.

## Frozen baseline

Do not change:
- owner-approved V05 rail source coordinates;
- canonical cocktail PNGs;
- drink-to-drink COLLIDER_RADII;
- launch speed, deceleration, merge scoring/economy, To-Go, HUD, held alignment, NEXT/progression;
- no-backward gameplay rule;
- lock_rotation;
- drink-to-drink circle physics.

## Mandatory first step: reproduce the real failure

Before changing production code, add a focused runtime diagnostic that reproduces the two owner failures using the actual production scene/physics path:

- visible side escape at left/right rails under crowded/merged conditions;
- excessive rear clearance while drinks accumulate against the rear region.

The diagnostic must use real spawned drinks and normal physics frames, not only direct calls to the containment helper.

The new test must FAIL against the current V09 implementation before the fix.

## Fix V09 transform composition

Correct `Drink.get_boundary_contact_hull_local()` so the hull exactly matches the rendered hierarchy:

`RigidBody2D -> Visual -> CocktailSprite`.

The transform must be equivalent to:

```text
body_local_point =
    visual_root_transform
    * cocktail_sprite_transform
    * source_point
```

Do not manually approximate only scale if node transforms can be composed directly.

Add a test that compares hull points with equivalent composed node transforms at multiple Y positions where `_visual_root.scale != 1.0`.

## Boundary solver correctness

Audit and fix the custom containment solver with the owner runtime failures in mind.

Requirements:
- use the accepted piecewise rail geometry without moving it;
- do not treat a finite rail segment as an unrelated infinite-line constraint outside the segment's valid region unless mathematically justified;
- ensure the correct active/adjacent segment is selected for a drink near a piecewise side boundary;
- handle corners/segment transitions without gaps or escapes;
- rear boundary must constrain the visible hull to the rear rail with no large artificial empty strip;
- side boundaries must keep the entire intended visual contact hull inside the accepted envelope;
- preserve tangential velocity and remove only outward normal velocity;
- keep one authoritative projection function for runtime and merge-time correction.

If the existing all-segments half-plane approach is the cause, replace it with a segment-aware or polygon-containment method that is mathematically valid for the accepted boundary.

## Collision architecture

Keep:
- drink CircleShape2D for drink-to-drink collisions only;
- table StaticBody2D rails non-authoritative for cocktail collision response unless explicitly reintroduced as a diagnostic/reference layer.

Do not reintroduce V06-V08 scalar half-width logic as the primary solution.

## Required evidence

Provide:
1. pre-fix reproduction showing current V09 failure;
2. post-fix focused reproduction showing no side escape and materially reduced rear gap;
3. transform-equivalence test;
4. crowded/merge stress case near left, right, rear, and rear corners;
5. representative L01, L06, L12 cases;
6. normal GUI capture at 720x1280;
7. full active regression.

## Acceptance

Automated PASS is not enough.

Owner must run the normal game and confirm:
- rear empty strip is gone or visually natural;
- no cocktail visibly crosses the accepted left/right table envelope;
- no new popping/jitter at segment transitions;
- merge behavior and momentum remain acceptable.

Codex must not edit TASKS.md, ChatGPT-owned audit/criteria files, canonical PNGs, or start M08+.
