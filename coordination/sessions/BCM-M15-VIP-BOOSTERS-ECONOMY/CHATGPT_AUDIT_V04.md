# BCM-M15 VIP, Boosters, Rewards & Economy — Independent Audit V04

Verdict: **CHANGES_REQUIRED / OWNER_VISUAL_REMEDIATION_REQUIRED**

Auditor: ChatGPT
Builder: Codex
Branch: `main`
Audited pre-publication HEAD: `418190651e87973eb434e02a856957c46e9f51fe`

## 1. VERDICT

The direct owner decision is valid for the live tracker gate and is now
recorded in `OWNER_DECISION_V04.md`.

The M15 V03 technical audit remains a technical pass, but the required owner
visual gate fails for VIP pending, partial, and completed states. The non-VIP
baseline passes. This is a bounded VIP overlay remediation, not a rejection of
the V03 economy or gameplay implementation.

Final V04 verdict: **CHANGES_REQUIRED**.

## 2. CONTRACT RECOVERY

The live `origin/main` tracker was at M15 `OWNER_REQUIRED`, with the next
action explicitly requesting owner review of the four V03 captures. The
supplied owner decision therefore applies to the current gate and is not being
applied to a stale or later task.

Locked technical authority remains:

- `CHATGPT_EXECUTION_PROMPT_V03.md`
- `CHATGPT_AUDIT_CRITERIA_V03.md`
- `CHATGPT_AUDIT_V03.md`
- `CODEX_LOG_V03.md`

The new owner decision and bounded remediation authority are:

- `OWNER_DECISION_V04.md`
- `CHATGPT_REMEDIATION_PROMPT_V01.md`
- `CHATGPT_AUDIT_CRITERIA_V04.md`

## 3. BRANCH / HEAD / DIFF SCOPE

Before this controller publication, the canonical checkout was clean on
`main`, and local `HEAD`, `origin/main`, and remote `main` were all
`418190651e87973eb434e02a856957c46e9f51fe`.

This controller cycle changes only ChatGPT-owned coordination artifacts and
the authorized root tracker transition. No product source, asset, test, or
Codex log is changed here.

## 4. ACCEPTANCE CRITERIA MATRIX

| Gate | Result | Finding |
| --- | --- | --- |
| A. Shared VIP target policy | **PASS / INHERITED** | V03 independently passed normal/VIP policy parity. |
| B. 2x VIP delivery payout | **PASS / INHERITED** | V03 independently passed exact per-unit delivery payout and zero-payout guards. |
| C. Score authority / stars | **PASS / INHERITED** | V03 independently passed GameManager and bridge score authority. |
| D. Separate economy reward | **PASS / INHERITED** | V03 independently passed terminal, separate, idempotent economy reward behavior. |
| E. Same-level precedence | **PASS / INHERITED** | V03 independently passed mandatory-normal-first behavior. |
| F. VIP overlay visual gate | **FAIL** | Owner rejects pending, partial, and completed VIP states; non-VIP baseline passes. |
| G. V03 focused tests | **PASS / INHERITED** | V03 independent M15 runs and listed regression probes passed. |
| H. Governance / scope | **PASS** | Owner decision is applied only because the live tracker was `OWNER_REQUIRED`; no product implementation is performed in this cycle. |

## 5. OWNER FINDING

The owner identifies the VIP overlay as the defect boundary:

- pending text overlaps the cocktail image;
- the VIP target image is absent;
- the `2X` indication disappears;
- partial `1/2` text does not make progress sufficiently visible;
- the long `COMPLETED` label damages the panel further;
- non-VIP passes when the VIP overlay is absent.

The next implementation must therefore be limited to the VIP overlay visual
states and must preserve the non-VIP baseline and the normal To-Go panel
asset.

## 6. REQUIRED REMEDIATION

Execute only:

`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_REMEDIATION_PROMPT_V01.md`

against the locked criteria:

`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V04.md`

Required actor is CODEX. M16 content population remains prohibited.
