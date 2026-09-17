# BCM-M06-R04 — Independent ChatGPT Audit V01

## Verdict
**FAIL / CHANGES_REQUIRED**

## Root dependency failure
M06-R04 was required to rebuild geometry around the owner's newly approved background. The actual owner attachment for `game_board_background 2.png` is SHA-256 `5d3d795935e2a69175e048c354ab4ce82ef13627cd27a8894f0605f78f0559b3` (1024x1536). M06-R04 instead measured and integrated canonical background SHA `bf9ef25bfe27b78805c487410601a9fef16b36f83c97b9bc6f3bf70670dfd17a`.

Therefore the entire geometry/evidence package is tied to the wrong background bytes.

## Findings
1. **BLOCKER — geometry is correct only for the wrong canonical background.** New landmarks `(154,472)/(870,472)/(16,1186)/(1008,1186)`, danger `1080`, and launch `1136` cannot be accepted for the actual owner attachment until remeasured from that exact image.
2. The responsive calculations and tests are internally coherent, but internal coherence does not satisfy the locked owner-artwork requirement when the source image is wrong.
3. The regenerated clean captures, overlays, expected_landmarks and render_space_landmarks are stale for the true owner asset by definition.
4. The M06 locked criteria V01 contains the original correct owner background hash; the later master V02 attempted to supersede source identity based on a mistaken local-file decision. Owner chat attachments take precedence over that mistaken supersession.
5. No gameplay retuning or governance violation was found in the bounded M06 commit.

## Required remediation
After the exact owner background SHA `5d3d7959...` is canonicalized, independently remeasure far/mid/near visible wood rails, tabletop top/bottom, danger and launch positions from that exact image and regenerate all three viewport evidence sets. Do not reuse the current `bf9ef25b...` measurements unless the new image independently proves them.
