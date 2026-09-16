# BCM-M06-001 — ChatGPT Independent Re-Audit V02

Decision: **CHANGES_REQUIRED**

Supersedes the visual-acceptance conclusion of:

`docs/audits/BCM-M06_MILESTONE_COMPLETION_V01_AUDIT.md`

## Reason

The previous audit explicitly stated that ChatGPT had **not independently inspected the binary screenshot pixels**, yet still treated that missing visual verification as non-blocking and issued PASS. That was an invalid audit standard for a milestone whose acceptance gate depended materially on visual table/environment agreement.

The owner subsequently inspected the committed M06 evidence images and rejected them as materially inconsistent with the intended master gameplay composition.

Canonical owner master:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

## What remains valid from M06 V01

The following builder evidence remains useful but is not sufficient for visual acceptance:

- background node integration exists;
- source-to-viewport mapping exists;
- production rail geometry is deterministic;
- M01-M05 regression probes were reported green;
- Godot import/startup evidence was reported green;
- Codex did not edit `TASKS.md`.

## Material failure

**F-M06-VISUAL-001 — owner master composition was not independently verified and owner-native review rejects the committed evidence.**

The milestone cannot be accepted merely because geometric helpers and tests agree with coordinates chosen by the same implementation. The actual rendered table/environment must visually agree with the owner-approved master.

## Final verdict

**CHANGES_REQUIRED**

M06 visual acceptance is reopened. M07 final HUD acceptance must not rely on M06 V01 as a visually accepted base.

Remediation session:

- `coordination/sessions/BCM-M06-R01/CHATGPT_PROMPT_V01.md`
- `coordination/sessions/BCM-M06-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

After Codex produces `CODEX_LOG_V01.md`, ChatGPT must inspect actual committed screenshot pixels against the owner master before any `AUDITED_PASS`.
