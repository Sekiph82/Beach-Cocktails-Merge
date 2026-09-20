# BCM-UI-ASSETS-FULL-PRODUCTION — Remediation Audit Criteria V02

Status: LOCKED BEFORE REMEDIATION V02

This is a narrow state-differentiation remediation. Do not regenerate accepted asset families unnecessarily.

## V2-1 Preservation — blocking

- Stay on `ui-assets`.
- Do not modify main.
- Do not modify root `TASKS.md`.
- Do not modify live gameplay/runtime paths.
- Preserve canonical owner logo bytes/checksum.
- Preserve table geometry JSON and common table mask.
- Preserve accepted semantic icons and island icons unless a direct state-pair defect requires a related asset update.

## V2-2 Mandatory state pairs — blocking

The following pairs must be visibly and byte-wise distinct:

### Stars
- `campaign/island_map/star_small_empty.png` vs `star_small_filled.png`
- `ui/rewards/star_empty.png` vs `star_filled.png`
- `ui/rewards/star_large_empty.png` vs `star_large_filled.png`

Empty must read as unearned/unfilled. Filled must read as earned/filled.

### Chests
- small closed vs small open
- big closed vs big open
- premium closed vs premium open
- milestone closed vs milestone open

Open state must clearly show an opened lid/interior/reward glow or equivalent. Size/premium tiers must also remain distinguishable.

### Toggle
- `toggle_off.png` vs `toggle_on.png`

OFF and ON must differ in at least knob position and state color/illumination.

### Level nodes
- `level_node_locked.png` vs `level_node_unlocked.png`

Locked must visibly communicate lock/inaccessibility. Unlocked must communicate selectable availability.

### Tabs
- `tab_active.png` vs `tab_inactive.png`

Active must clearly have selected emphasis; inactive must visually recede.

## V2-3 Stateful-manifest audit — blocking

Create a machine-readable list:
`assets/ui_assets/STATEFUL_PAIR_REPORT.json`

It must cover at minimum:
- stars;
- chests;
- toggle;
- tabs;
- level nodes;
- daily reward current/claimed/locked;
- booster locked/selected/default;
- route marker normal/current/complete;
- any other filename families containing paired state words such as active/inactive, on/off, open/closed, empty/filled, locked/unlocked, current/complete/claimed/selected.

For every pair/group:
- report paths;
- SHA-256;
- perceptual distance;
- expected relationship;
- PASS/FAIL.

No opposite semantic states may have identical SHA.

## V2-4 Validation — blocking

Extend `validate_assets.py` so it:
- loads the stateful pair/group specification;
- fails if opposite states are byte-identical;
- fails if perceptual difference is below an intentional threshold appropriate to that family;
- explicitly prints PASS lines for stars, chests, toggles, level nodes, tabs, and daily/route/booster states.

Do not use a single global threshold if it produces false confidence. State semantics must be encoded explicitly.

## V2-5 Contact-sheet evidence

Add:
`assets/ui_assets/CONTACT_SHEET_STATEFUL_UI.png`

It must show side-by-side:
- empty/filled stars;
- closed/open chest tiers;
- toggle off/on;
- locked/unlocked/current/completed level nodes;
- active/inactive tabs;
- daily reward state set;
- booster state set;
- route marker state set.

Regenerate manifest and dimensions after changes.

## V2-6 No scope regression

The V02 diff must be narrow and should primarily affect:
- stateful UI PNGs;
- generator renderers for those state families;
- validation/report tooling;
- metadata/contact sheets;
- V02 builder log.

Do not reopen table/world/island art without evidence of a new defect.

## V2-7 Builder log

Create:
`coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CODEX_REMEDIATION_LOG_V02.md`

Include:
- start/end HEAD;
- exact state pairs changed;
- before/after SHA evidence;
- validation output;
- report/contact-sheet paths;
- protected-scope verification;
- main ref observation.

## V2-8 Verdict

PASS requires every mandatory opposite state pair to be visually distinct and validation-enforced, while all accepted V01 remediation work remains preserved.
