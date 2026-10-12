# BCM-M32-001 — Campaign Foundation V01

Status: `CAMPAIGN_CONTRACT_AND_STAGED_VALIDATION_IMPLEMENTED; BUILDER_EVIDENCE_ONLY`.

## Authority and repository state

- Work item: `BCM-M32-001 — Establish the 10-island, 100-level-each content foundation`.
- Prompt/criteria/ruling: `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/`.
- Start HEAD: `22a1deef473dc65135d9a8fe7397288515d2e915` on `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Root `TASKS.md` was read and not modified. The seven restored owner-local tracked changes remain unstaged; all inventoried untracked evidence remains present.

## Changes

- Added a schema-1 `campaign_contract` to the authoritative island registry with the canonical ten ordered island IDs, 100 levels per island, 1,000 total, and sequential full-island completion.
- `LevelDatabase` validates contract identity/order/linkage, checks contiguous level IDs, reports authored counts as `PENDING_CONTENT`, and rejects an incomplete contracted campaign in `FULL` mode. Legacy fixture roots without a campaign contract retain their prior validation behavior.
- `CampaignManager.is_island_complete` now also requires all contracted content for the island, preventing an authored slice from unlocking the next island prematurely.
- Added `M32ContentWorkflow`: deterministic seeded candidate generation, production schema/target legality checks, existing M17 impossible-target and VIP-interception screens, existing LevelDatabase 4T budget calculation, exact production star-boundary checks, and an adapter to the real M17 physics harness. It does not claim analytical checks are a physics or human-playability proof.
- Added a focused Godot probe for campaign readiness, candidate determinism, objective/VIP/4T/star validation, and strict FULL-mode rejection.
- Protected `data/campaign/levels/sunny_cove.json` was not edited; SHA-256 before/after is `573B5CA14CA75BEC04F40A5B7D00AA441534A266569B200E36E78B28D3591128`.

## Validation performed

- Godot: `4.7.2.stable.official.ed1daf0bf`.
- Isolated sandbox: `C:\Users\sekip\.codex\sandboxes\BCM-M32-CAMPAIGN-FOUNDATION-V01-20261012-01a12fc6`; unique project identity `BCM-M32-Campaign-Foundation-V01-Validation`; actual `user://` resolved to `C:\Users\sekip\AppData\Roaming\BCM-M32-Campaign-Foundation-V01-01a12fc6`.
- Five owner Godot diagnostic log files were copied and SHA-256 checked before M32 runs. A byte/hash and directory snapshot of `CocktailMerge` owner userdata matched after the isolation, import, and probe runs.
- PID-controlled isolation probe: `M27_ISOLATION_PROBE=PASS`; runner recorded exit 0 and zero matching Godot processes after cleanup.
- Initial clean import exposed an indentation parse error in the new validator; corrected before completion. Initial workflow parse exposed dynamic type inference and non-static star-calculator calls; corrected before completion. The initial probe timed out after those parse errors stopped script execution; the PID runner timed out at 180 seconds and verified zero task-owned processes remained.
- Post-fix clean import: exit 0, zero `SCRIPT ERROR` / failed-script-load messages, zero task-owned processes after cleanup, and owner userdata parity PASS.
- Focused `tests/m32_campaign_contract_probe.gd`: exit 0, `M32_CONTRACT_PROBE_RESULT=PASS`.
- `git diff --check` and focused existing campaign regression probes will be recorded at the child/master handoff after all M32 implementation children complete.

## Limits and handoff

- This child deliberately keeps future islands in `PENDING_CONTENT`; no 900 placeholder rows were added. M32-002 will add the first post-Sunny-Cove playable slice. The final nine-island campaign is not declared complete.
- The generated candidates are candidate material only. Any shipping content still requires real physics screening and human design review.
- Product commit SHA, child-log commit SHA, and synchronized local/origin/remote refs are recorded in the M32 master execution log after publication.
- `TASKS.md` was not modified. No save, owner-approved visual asset, timer rule, gameplay physics or store workflow was changed.
