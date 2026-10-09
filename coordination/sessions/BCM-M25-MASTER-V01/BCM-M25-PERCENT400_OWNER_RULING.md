# Owner ruling: percent-based moves and stars for 100 Sunny Cove levels

The owner directs the entire level calculation to use the theoretical number of shots under the idealization that **every spawned cocktail is Level 3 and every shot merges perfectly**, with a max move budget equal to 400% of that ideal shot count.

For an ordinary target Lk with k>=3, ideal L3 shots = 2^(k-3). Multiply by target quantity and sum the targets.

Successful shots actually used / ideal target shots * 100 determines stars on WIN:
- below 200%: 3 stars
- at least 200%, below 300%: 2 stars
- at least 300%, through 400%: 1 star.
- At the 400% limit, if required To-Go objectives are not complete after the last shot fully settles: natural LOSE, 0 stars. If orders complete on that last shot: WIN, 1 star.
- Every eligible shot consumes 1 move. Never allow shot (4*T)+1.
- No timer. Score is displayed and economy/records keep score; score does not influence stars.
- Percentage defines all star outcomes. Former VIP completion requirement for the third star is superseded. VIP remains optional and cannot prevent basic WIN.
- Separate VIP goals should not make baseline required To-Go budget easier or harder based solely on an optional side goal. The mandatory To-Go ideal sum determines the base T and the 400% loss budget. VIP completion earns its existing independent reward. Record supplemental VIP ideal shot count in level metadata/evidence. If this policy needs adjustment, request an explicit owner decision, not a silent change.

This supersedes the earlier empirical-fairness gate *for assigning these exact mathematical thresholds*. Technical playability and end-to-end regression remain mandatory, and any structurally impossible objectives must be flagged.
