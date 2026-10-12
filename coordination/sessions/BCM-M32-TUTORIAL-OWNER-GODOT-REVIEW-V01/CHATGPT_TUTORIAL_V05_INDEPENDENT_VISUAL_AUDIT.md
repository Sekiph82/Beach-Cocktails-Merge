# BCM-M32 Tutorial V05 independent visual audit

**Verdict: V05 VISUAL REMEDIATION CONDITIONAL PASS for the major V04 layout defects; OWNER ACCEPTANCE PENDING.**

I inspected both user-provided six-step contact sheets (390x844 and 432x960) as visual evidence, and checked the published V05 README. This is an actual screenshot-based review, not automatic approval of Codex assertions.

**Resolved relative to V04:** The teaching card is considerably smaller and relocated below gameplay for stages 1–5; PAUSE is unobscured; VIP NEXT and SKIP are now inside both viewports; Stage 6 exposes the actual Results dialog including the visible, highlighted RETRY button, with the tutorial instruction moved to a separate upper card; result text and action row are no longer obscured. The real cocktail sprite is used in gameplay demonstrations. Stage 5 displays the actual T-based 3/2/1 star conditions. Both capture sets show all six steps.

**Remaining visual reservations:** Instruction icon badges still look small, mostly simplified graphic cues compared with the high-detail art of the game, especially LAUNCH/MERGE/DELIVER; the directional lesson could be clearer with an animated gesture demonstrated in real-time. The tutorial captions are quite small on 390x844, especially the formula in MOVES & STARS, though not clipped. VIP step points to the HUD but teaching how optional VIP actually works may require owner usability testing. Step 2 highlight is near the MOVES/HUD area and the currently displayed drink positions, which warrants checking in a manually played run that it highlights the intended real merge target rather than a transient location. Static screenshots do not establish live animation legibility, input hit area or accessibility. The 432x960 set is generally easier to read.

**Scope of proof:** The reported real event-driven flow and clickable Retry are builder claims supported by V05 traces, but I did not execute Godot or test touch input. Neither Windows captures nor passing probes substitute for owner-led Godot interaction or iPhone/Android approval. All OWNER_FEEDBACK cells remain PENDING_OWNER.

**Decision:** Keep tutorial owner review OPEN; do not change its status to ACCEPTED or resume M33 until the owner explicitly approves. If owner dislikes icon legibility or teaching clarity, prepare narrow V06 revisions rather than a wholesale UI redesign. No production code or canonical TASKS.md changed in this audit.
