# BCM-M25-PERCENT400 independent audit V01

**Verdict: TECHNICAL SOURCE/EVIDENCE PASS; PHYSICAL DEVICE OWNER QA OPEN.**

Reviewed GitHub master implementation log, locked audit criteria and production source for level database ideal-L3 calculation, campaign shot-count and stars, GameManager exhaustion, plus owner-file integrity report. Four separately committed child workstreams are evidenced in master log: a06e2e8, c507c5c, 99e746e, 7eb35fc. The final owner-shared SHA is 4a681790dce921bc293cbd5ab1faa0aa675a56d5.

Source: Lk requires 2^(k-3) ideal L3 shots times quantity; T includes all To-Go plus enabled VIP. Total limit 4T. E.g. L6 T=12, max=48; L8 T=16, max=64; L100 T=76, max=304. Campaign records successful shot IDs once, prevents shots past cap, and scores only committed-move thresholds (<2T 3-star, <3T 2-star, through 4T 1-star) for completed objectives; otherwise 0. Score is no longer a star criterion. VIP is in T yet remains optional for normal WIN, per owner ruling. Collision/merge settle guard exists before exhaustion LOSE, preserving final-shot WIN precedence.

Builder evidence: 100 level formula/boundary probe PASS, FULL/REDUCED GL genuine natural WIN and LOSE, Retry/map routing, mobile layouts at 720x1280/720x1440, M21 QA 2 runs 16 images and exit 0, broad M02–M25 regressions PASS, editor import and 120-frame boot exit 0. Protected owner manifest: 262 identical files, zero missing and no newly created real app-userdata files. CAL02's two previously rotated-out logs were not recovered; no new damage is asserted.

Limitations: this audit is independent review of committed code and builder artifacts, NOT independently executed native Godot tests. Physical-device QA and human balancing remain unverified; no claim of population fairness. Technical implementation meets source/evidence gate. M25 milestone closure and M26 transition require explicit owner disposition on physical-device QA/acceptance; do not declare owner inspection or M26 started.
