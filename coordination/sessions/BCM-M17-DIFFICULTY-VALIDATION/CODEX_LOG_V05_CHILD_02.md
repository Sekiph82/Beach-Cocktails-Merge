# CODEX V05 Child 02 — Mandatory Reserve Runtime Guard

## Scope and synchronization

- Work item: BCM-M17 V05 VIP optionality structural remediation.
- Child: 02 — deterministic reserve planner and both production capture guards.
- Prompt/criteria: `CHATGPT_EXECUTION_PROMPT_V05.md` / `CHATGPT_AUDIT_CRITERIA_V05.md`.
- Start HEAD: `448802f303398a5ae41c9c36e015cf9c77132238`.
- Implementation HEAD: `2b32e45a83e03ad0aef810dba4293d92b38f653a`.
- Branch/remote: `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Pre-child status: clean `main...origin/main`.
- Pre-child fetch: `git fetch origin main` succeeded.
- Pre-child divergence: `0 0`.

## Implementation

- Added `scripts/campaign/m17_vip_optionality_model.gd`.
- The planner builds deterministic power-of-two objective bins from authoritative `normal_remaining` state and computes maximum assignable value from indivisible eligible board cocktails. Missing value is the minimum additional production cost; a candidate is surplus only when removing it does not increase that cost.
- Added the same surplus guard to direct merged-cocktail routing in `GameManager.on_merged()` and stocked-cocktail routing in `_try_collect_stocked_target()`.
- Higher cocktails cannot fit lower objective bins, so the reserve calculation does not split them.
- Same-level normal-first routing remains ahead of VIP routing.

## Tests and evidence

- `godot --headless --path . --editor --quit`: PASS (parse/import check).
- `git diff --check`: PASS before publication.
- Generated `.translation` sidecars created by the Godot import check were verified as reproducible generated artifacts and removed by exact path; none were staged.
- Focused V05 planner and production fixtures are Child 03 and remain pending.

## Publication proof

- Implementation commit pushed to `origin/main`: `2b32e45a83e03ad0aef810dba4293d92b38f653a`.
- `git rev-parse HEAD`: `2b32e45a83e03ad0aef810dba4293d92b38f653a`.
- `git rev-parse origin/main`: `2b32e45a83e03ad0aef810dba4293d92b38f653a`.
- `git ls-remote origin refs/heads/main`: `2b32e45a83e03ad0aef810dba4293d92b38f653a`.
- Post-child divergence: `0 0`.
- Post-child worktree: clean.
- Root `TASKS.md`: not modified.

## Child result

`CHILD_02_COMPLETE` — runtime reserve protection is implemented and published. Independent audit remains pending.

