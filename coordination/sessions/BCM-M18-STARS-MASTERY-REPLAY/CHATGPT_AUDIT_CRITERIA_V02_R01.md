# BCM-M18 V02-R01 — Locked Remediation Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `CHATGPT_AUDIT_V02.md`
- `CHATGPT_AUDIT_CRITERIA_V02.md`
- `OWNER_RULING_V02.md`
- preserved V02 implementation and evidence at audited handoff `597eabdd42ce42e688ea0774cfec8b0fbc97c17e`.

## A — governance and preservation

- Work only on clean synchronized `main`.
- CODEX must not edit root `TASKS.md`.
- Preserve all historical V01 and V02 prompts, criteria, audits, reports, and logs byte-for-byte.
- Do not reimplement M18-001/002.
- Do not start M19.
- Do not touch Sunny Cove timers/objectives/VIP content, gameplay physics, HUD layout, purchases, ads, backend behavior, or unrelated assets.

## B — bounded cumulative-reward fix

Correct only the cumulative-star reward claim behavior in the existing campaign authority.

Required behavior:
1. If `economy == null`, an eligible cumulative-star threshold remains unclaimed and no reward is reported as granted.
2. Level completion, next-level progression, island completion, and island unlock remain non-blocking when economy is unavailable.
3. When an economy authority is later attached, a still-eligible threshold may be granted exactly once.
4. If `GameEconomy.grant_reward()` returns `ok=false`, the threshold remains unclaimed and may be retried later.
5. If the economy ledger already contains the reward id and returns a successful duplicate result, claim-state reconciliation remains idempotent and must not double-grant.
6. Successful grants append the threshold once to `claimed_star_rewards`.
7. Existing owner-approved 30..300 payload remains unchanged.

Focused tests must explicitly prove:
- threshold crossed with no economy: progression succeeds, threshold not claimed;
- attach economy and retry/trigger reconciliation: reward granted once and threshold claimed;
- forced failed grant: threshold remains unclaimed;
- duplicate ledger state: no second inventory grant and claim state becomes/remains consistent;
- normal 29→30 and save/reload behavior remain green.

## C — required replay-state captures

Produce repository evidence captures for the original Child 05 locked states:
1. completed level with authoritative prior stars/best score visible;
2. worse replay preserving the visible stored record;
3. improved replay showing upgraded stars/best score;
4. return to the same Island Map context with selected/focus/scroll state restored.

Requirements:
- captures must come from the actual M18 runtime/probe path, not mockups;
- no visual redesign is authorized;
- each capture must have an accompanying evidence note identifying scenario, source command/run, and relevant state;
- unavailable owner/native-device subjective acceptance may remain explicitly unverified, but the four builder captures are mandatory;
- if the environment cannot produce valid captures, stop with truthful failure instead of claiming PASS.

## D — evidence correction

Do not rewrite historical V02 logs.

The new remediation log must explicitly state:
- historical log typo: `f9ae43e6d2df9dedb9cc3fe25aa0e55954d7c5b3`;
- actual merge commit: `f9ae43ef7b928b2815bc54c9b9845ce2ccacab22`;
- proof that the actual commit is in final V02 ancestry and preserves ChatGPT commit `bd20dc04821717d31e63b5fc593ee8d7fe003a60`.

## E — focused validation

Required direct checks after the bounded fix:
- updated/new cumulative-star remediation probe;
- original `m18_cumulative_star_rewards_probe.gd`;
- `m18_completion_progression_probe.gd`;
- `m18_island_map_replay_probe.gd`;
- `m18_integration_probe.gd`;
- `m18_star_contract_probe.gd`;
- `m18_replay_persistence_probe.gd`;
- M11 save migration/progression;
- M13 Island Map;
- M14 GameplaySessionBridge;
- M15 VIP/economy;
- M16 Sunny Cove content;
- `git diff --check`;
- prove root `TASKS.md` unchanged by CODEX.

Any material test failure stops the batch. Do not silently fix unrelated failures.

## F — final handoff

Create:
- `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CODEX_LOG_V02_R01.md`

The log must contain:
- exact preflight and synchronization;
- exact product diff;
- cumulative-reward fix explanation;
- focused tests and exact exit codes/PASS markers;
- paths to all four captures and evidence note;
- exact historical SHA correction;
- protected-scope checks;
- final local/origin/remote equality.

Successful handoff ends exactly:

`AWAITING_M18_AUDIT_V02_R01`

Any failed, missing-capture, speculative, or unverified material criterion is `CHANGES_REQUIRED`.
