# V07-R01 Child 02 - Locked Audit Criteria

- The new runner changes only the two locked integrity defects and validates the
  audited V06-R02 source before trial use.
- Exactly 42 candidates receive one carried-forward trial plus four fresh trials,
  producing exactly 168 new trials and five post-V05 trials per candidate.
- All trials use `MERGE_AWARE_V01`, time scale `1.0`, valid flat telemetry,
  legal action logs, and unique seeds; the aggregate registry contains exactly
  213 unique seeds, including the first imported source seed.
- V07-R01 JSON and Markdown contain exactly 100 levels and 45 classes, complete
  per-candidate provenance, all five seeds, counts, classifications, hashes, and
  validation errors equal to none.
- Classification is `SOLVER_FEASIBLE` for completion count >= 1/5 and
  `HIGH_RISK_SOLVER_FAILURE` for 0/5; no candidate remains pending confirmation.
- Post-V05 VIP semantics are forced `0/25`, surplus `25/25`, with no VIP cost in
  normal timers.
- The direct runner returns PASS with exit code 0; no report repair is permitted.

Any failed or unverified item is `CHANGES_REQUIRED` and blocks Child 03.
