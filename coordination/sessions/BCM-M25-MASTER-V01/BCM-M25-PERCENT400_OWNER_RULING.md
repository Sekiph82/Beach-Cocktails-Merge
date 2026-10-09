# Owner ruling: percent-based moves and stars for 100 Sunny Cove levels

The owner directs the entire level calculation to use the theoretical number of shots under the idealization that **every spawned cocktail is Level 3 and every shot merges perfectly**, with a max move budget equal to 400% of that ideal shot count.

For a target Lk with k>=3, ideal L3 shots = 2^(k-3). Multiply by target quantity and sum **both mandatory To-Go Orders and configured VIP Orders** for each level. Let T = T_to_go + T_vip (T_vip=0 if no VIP). The same inclusive T determines both percentage stars and the 400% move limit.

Successful shots actually used / ideal target shots * 100 determines stars on WIN:
- below 200%: 3 stars
- at least 200%, below 300%: 2 stars
- at least 300%, through 400%: 1 star.
- At the 400% limit, if required To-Go objectives are not complete after the last shot fully settles: natural LOSE, 0 stars. If orders complete on that last shot: WIN, 1 star.
- Every eligible shot consumes 1 move. Never allow shot (4*T)+1.
- No timer. Score is displayed and economy/records keep score; score does not influence stars.
- Percentage defines all star outcomes. Former VIP completion requirement for the third star is superseded. VIP remains optional and cannot prevent basic WIN.
- **Latest owner amendment: VIP is included in theoretical shots T and hence in the 400% move budget and stars formula.** VIP remains optional for level WIN and retains its separate rewards. That means completing To-Go without VIP may still end a WIN, evaluated using the inclusive T; this tradeoff is deliberate from the stated arithmetic, and tests should clearly disclose it. Document T_to_go and T_vip separately as well as inclusive T. Avoid double-counting cocktails delivered to overlapping To-Go and VIP goals; validate actual order consumption rules.

This supersedes the earlier empirical-fairness gate *for assigning these exact mathematical thresholds*. Technical playability and end-to-end regression remain mandatory, and any structurally impossible objectives must be flagged.
