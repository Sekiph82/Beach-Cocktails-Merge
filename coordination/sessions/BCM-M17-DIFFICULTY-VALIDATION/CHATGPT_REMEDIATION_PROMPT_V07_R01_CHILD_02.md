# V07-R01 Child 02 - Bounded Runner Remediation and Fresh Evidence

Read the V07-R01 master remediation prompt, Child 02 criteria, and the passing
Child 01 handoff before acting. Do not begin if Child 01 is blocked or unverified.

## Scope

1. Create the new evidence-only runner
   `tools/campaign/m17_canonical_confirmation_v07_r01.gd`.
2. Correct only the two locked integrity defects: semantic comparison of
   JSON-loaded mappings, and registration/validation of every aggregate seed,
   including the first imported V06-R02 source seed.
3. Produce fresh V07-R01 JSON and Markdown reports using the exact 42 audited
   candidates, one carried-forward source trial, four fresh trials per candidate,
   `MERGE_AWARE_V01`, time scale `1.0`, and the locked seed namespace.
4. Require the direct runner itself to return PASS / exit 0 before handing off.

Do not modify the historical failed V07 runner/report/log, canonical data,
timers/objectives, VIP data, gameplay, HUD, physics, economy, progression,
root `TASKS.md`, or M18+.

## Required handoff

Write the immutable child log:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R01_CHILD_02.md`

Record exact changed files, direct-run command and exit code, 168-new-trial and
213-seed proof, 42x5 aggregates, class results, VIP semantics, hashes, and
limitations. On any direct-run or integrity failure, stop without repair-after-
failure and do not start Child 03. Only a direct PASS permits Child 03.
