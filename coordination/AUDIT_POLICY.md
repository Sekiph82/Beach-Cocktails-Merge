# Beach Cocktails Merge — Independent Audit Policy

## Core rule

Every implementation/remediation session must use the same four-artifact protocol as the proven ScrubBots workflow:

1. `CHATGPT_PROMPT_VNN.md` — issued by ChatGPT before builder work.
2. `CHATGPT_AUDIT_CRITERIA_VNN.md` — issued and locked by ChatGPT before builder work.
3. `CODEX_LOG_VNN.md` — immutable builder execution/evidence log written by Codex.
4. `CHATGPT_AUDIT_VNN.md` — independent post-build audit written by ChatGPT.

Canonical location:

`coordination/sessions/<SESSION-ID>/`

## Ownership

ChatGPT owns:
- `CHATGPT_PROMPT_*`
- `CHATGPT_AUDIT_CRITERIA_*`
- `CHATGPT_AUDIT_*`
- tracker transitions in root `TASKS.md`

Codex owns only:
- implementation within the issued scope;
- tests/support evidence within scope;
- `CODEX_LOG_*`.

Codex must never edit ChatGPT-owned session artifacts or `TASKS.md`.

## Pre-issue rule

`CHATGPT_AUDIT_CRITERIA` must exist before implementation begins. It is the immutable acceptance contract for that version of the session. Criteria may not be relaxed after seeing builder output.

If the owner changes the contract after issuance, ChatGPT creates a new version (`V02`, etc.) and explicitly supersedes the prior version. Historical files remain immutable.

## Evidence classes

- **E1 — builder claim:** prose in Codex log.
- **E2 — builder-generated evidence:** test outputs, screenshots, hashes, runtime captures produced by Codex.
- **E3 — independent ChatGPT evidence:** actual repository diff/source/test inspection, independently inspected screenshots/assets, independently rerun checks when tools permit, and direct owner-native acceptance/rejection.

E1 alone never satisfies a material criterion. E2 must be cross-checked. Material visual acceptance requires independent image inspection, not merely dimensions/hashes or a builder statement.

## Audit rule

ChatGPT audits criterion-by-criterion against the pre-issued criteria and actual repository truth. Test PASS output does not override a direct contract violation. Tests modified by the implementer must be inspected for weakened assertions or shared incorrect assumptions.

Any material criterion that is not independently verifiable is marked `UNVERIFIED`. A material `UNVERIFIED`, `FAIL`, BLOCKER, or MAJOR finding prevents unconditional `AUDITED_PASS`.

For visual milestones, ChatGPT must inspect the committed production screenshots/images themselves against the owner-approved visual reference before PASS. If image bytes cannot be inspected with available tools, visual acceptance cannot be inferred and remains unverified unless the owner provides direct native acceptance.

## Verdicts

- `AUDITED_PASS` — all material locked criteria pass; no BLOCKER/MAJOR; required independent evidence exists.
- `CHANGES_REQUIRED` — any material criterion fails or remains unverified.

No milestone/task is advanced in `TASKS.md` until `CHATGPT_AUDIT` reaches `AUDITED_PASS`.

## Builder stop rule

Codex commits/pushes intended work and its immutable `CODEX_LOG`, returns `AWAITING_AUDIT`, and stops. Codex never self-audits and never updates tracker state.
