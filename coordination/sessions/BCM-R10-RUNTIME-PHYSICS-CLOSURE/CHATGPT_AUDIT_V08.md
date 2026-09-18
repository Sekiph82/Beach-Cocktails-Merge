# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit V08

Verdict: **CHANGES_REQUIRED**

Audited implementation:
`6f902737f21c2983dabae6f42f59ed9d1a771e4c`

Builder log:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V08.md`

Locked criteria:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V10.md`

## What passed

1. The V09 Visual -> CocktailSprite transform-composition bug is corrected using actual node transforms.
2. V05 source rail coordinates remain unchanged.
3. L01-L12 gameplay circle radii remain unchanged.
4. Scalar V06-V08 edge-clearance logic remains retired.
5. The production runtime and merge path continue to share one visual-hull projection function.
6. Pre-fix evidence was captured through spawned production drinks and normal physics frames.
7. Builder regression evidence reports the active replacement suite green.

## Blocker 1 — the implementation assumes the frozen piecewise envelope is convex, but the supplied rail vertices are not globally convex

V10 explicitly required a segment-aware or otherwise mathematically valid containment model and warned not to treat finite segments as unrelated infinite-line constraints unless justified.

The new implementation justifies applying every rail segment as an infinite supporting half-plane with this claim:

```text
The frozen rear/left/right vertices form a convex perspective envelope.
```

That claim is false for the frozen source coordinates.

For the first three right-side vertices:

```text
R0 = (833, 478)
R1 = (880, 587)
R2 = (905, 644)
R3 = (942, 734)
```

successive segment vectors are:

```text
v01 = (47, 109)
v12 = (25, 57)
v23 = (37, 90)
```

2D cross products:

```text
cross(v01, v12) = 47*57 - 109*25 = -46
cross(v12, v23) = 25*90 - 57*37 = +141
```

The sign changes. Therefore the polyline contains a local change of turning direction and cannot be treated as one globally convex supporting-half-plane chain.

Consequently, applying all right/left segment lines as global infinite polygon half-planes can reject points that are valid relative to the actual finite piecewise rail. This is exactly the class of issue V10 required the remediation to eliminate.

The current source therefore does not satisfy the locked segment-selection / finite-segment criterion.

### Required correction

Implement containment against the actual finite piecewise boundary rather than assuming global convexity.

Acceptable approaches include:
- select the side segment owning the drink/hull Y-range and test that segment plus adjacent segments near vertices;
- compute closest points / signed constraints against finite segments and explicitly handle segment transitions;
- construct the actual table polygon and use a containment/projection method valid for a non-convex/piecewise polygon.

Do not alter the accepted V05 coordinates to make the polygon convex.

## Blocker 2 — the post-fix regression no longer measures the owner-visible side-escape condition that the pre-fix reproduction used

The mandatory V10 reproduction correctly identified the owner-visible side failure using the **full rendered alpha footprint**, including garnish:

```text
R10_V10_PREFIX_SIDE ... rendered_edge_distance=-22.022
R10_V10_PREFIX_SIDE ... rendered_edge_distance=-40.230
```

The committed post-fix test, however, changes the acceptance metric to:

```gdscript
var distance := _min_body_hull_distance(drink, edge)
```

That checks only the authored glass-body contact hull.

The test file still contains `_rendered_hull_local()` and `_min_rendered_hull_distance()`, but the post-fix side assertions do not use them.

This means the pre-fix and post-fix tests are not measuring the same owner-visible defect.

The log's post-fix statement:

```text
R10_V10_POST_SIDE_ESCAPE=false
```

therefore proves only that the glass-body hull stayed inside. It does **not** prove that the visible cocktail artwork no longer crosses the accepted table envelope.

The locked V10 owner criterion is explicit:

```text
no cocktail visibly crosses the accepted left/right table envelope
```

The current automated evidence does not establish that.

### Required correction

For the same side-crowd scenarios, retain two separate metrics:

1. authoritative glass-body hull containment;
2. owner-visible rendered footprint containment.

The post-fix reproduction must test the same rendered-footprint metric that failed pre-fix. If garnish overhang is intentionally allowed, that is a product-rule change and requires explicit owner approval; it cannot be silently substituted into the acceptance test.

## Rear evidence

The new tests report body-hull rear distances around 0.5 px, which is promising source evidence. However, because the containment solver currently relies on the invalid global-convexity assumption, this is not sufficient to accept V10.

Owner GUI verification remains mandatory after the two blockers above are resolved.

## Final state

- exact visual transform composition: **PASS**
- frozen rails: **PASS**
- unchanged drink-to-drink circles: **PASS**
- shared runtime/merge solver: **PASS**
- pre-fix runtime reproduction: **PASS**
- mathematically valid finite-segment containment: **FAIL**
- same-metric post-fix proof for owner-visible side escape: **FAIL**
- owner visual acceptance: **NOT READY**

Final verdict: **CHANGES_REQUIRED**.
