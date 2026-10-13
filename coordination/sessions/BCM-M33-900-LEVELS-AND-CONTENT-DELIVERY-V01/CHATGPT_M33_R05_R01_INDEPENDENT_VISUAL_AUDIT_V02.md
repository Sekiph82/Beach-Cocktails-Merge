# BCM-M33-R05-R01 Independent VISUAL Audit V02

**Verdict: VISUAL FAIL; R05 tabletop starter scale and placement need remediation.** This supersedes the earlier evidence-only audit for visual acceptance.

Independent GPT inspection of three actual user-uploaded PNGs: `tiki_390x844.png`, `nine_island_gallery_390x844.png`, `nine_island_gallery_432x960.png`. These are visible image pixels, not solely Codex self-report.

**Critical P0:** Starter cocktails are substantially oversized compared with held/launch cocktails and the narrow playable tabletop. In Tiki L013 the starter orange cocktail appears several times taller/wider than the small held red launch cocktail; L027 two huge cocktails take significant lateral tabletop area, dominating board. Same conspicuous size mismatch appears across all nine islands, both viewport sizes, with starter blue/orange cocktails scaled far larger than launch drinks. This appears to be runtime sprite-scale inconsistency, NOT an owner-approved big obstacle mechanic. It damages visual balance and likely physics/fairness (collision footprint and easy access), though touch/physics is not provable from stills.

**P1:** One-starter layouts consistently place a very large drink around central board just above dashed boundary. In Tiki L013 and many islands, sprite lower edge/shadow is close to red dashed line. Several drinks look rather close to MOVES/FOCUS overlays when taller. L027 two-drink pair is horizontally separated, but oversized cocktails occupy too much useful placement/shooting area. Visual placement should be judged using sprite bounds and collision radius, not only center coordinates.

**P1:** Across islands, starting stock looks repetitive in placement: frequently one center-left/center-right large glass; two-starter layout rare in gallery. Variety benefit may be undermined by visible layout similarity despite different JSON signatures. Need sample audit at game-play scale, not just validation counts.

**Preserve:** Existing tropical art, island boards, HUD, danger line, shelf, shooter and accepted gameplay. The preplaced-cocktail concept is good, but implementation is NOT visually accepted. Do not mark R05 closed and do not resume next milestone before correction and owner visuals. No change to recipe goals, 4T/VIP policy or Sunny/Tiki protected records from this visual-only audit.
