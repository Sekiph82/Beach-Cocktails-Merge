# BCM-M21-001 — Codex Execution Log

Status: `BUILDER_PASS / AWAITING_CHILD_PUBLICATION`

## Authority and scope

- Prompt: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_EXECUTION_PROMPT_V01_CHILD_01.md`
- Criteria: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01_CHILD_01.md`
- Work item: mobile layout and production-path touch proxy QA only.
- Root `TASKS.md`: not edited.

## Start/preflight

- Start HEAD before M21 implementation: `2dee275`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Initial status: clean `main...origin/main`.
- `git fetch origin main`: completed.
- Initial divergence: `0 23` (local ahead / remote ahead), followed by
  `git merge --ff-only origin/main` to `2dee275`.
- Root `TASKS.md` SHA-256 before implementation:
  `10f8ebf6269a7323d8c8e89d596b777a4334fcdf1d836ac2b2220b8ab2bae9b3`.

## Changes

- Added `tests/m21_mobile_qa_probe.gd`.
- Added canonical/tall captures, JSON report, and Markdown report under
  `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/mobile_qa/`.
- Narrowly changed the Island Map header visual base from `PanelContainer` to
  `Panel` in `scripts/campaign/island_map_controller.gd` to remove observed
  title/summary overlap. No campaign/gameplay authority changed.
- Added this immutable execution record under `docs/codex-logs/`.

## Commands and exact results

1. `godot_console.exe --headless --path . --check-only --script res://tests/m21_mobile_qa_probe.gd`
   - exit `0`.
2. `godot_console.exe --path . --script res://tests/m21_mobile_qa_probe.gd --rendering-method gl_compatibility --display-driver windows`
   - exit `0`.
   - result marker: `M21_CHILD_01_RESULT=PASS captures=14`.
   - captures: 11 canonical `720×1280`, 3 tall `720×1440`.
3. `git diff --check`
   - clean at publication preparation.

The headless renderer was also checked during probe development; it cannot
provide image textures, so capture acceptance uses the available real
OpenGL/GL-Compatibility renderer and records the host limitation rather than
claiming a mobile-device result.

## Manual builder checks

Inspected refreshed onboarding, World Map, Island Map bottom-scroll, and tall
gameplay captures. The Island Map header overlap was fixed and recaptured.
Independent ChatGPT image inspection and owner-native mobile acceptance remain
pending.

## Known limitations

- No physical Android/iOS device was available or used.
- No signed store artifact was involved in this child.
- This is a proxy QA result, not final v1 acceptance.

## Publication handoff

- Implementation commit: to be recorded at child publication.
- Child-log publication commit: to be recorded at child publication.
- Final local/origin/remote equality: to be recorded after push.
