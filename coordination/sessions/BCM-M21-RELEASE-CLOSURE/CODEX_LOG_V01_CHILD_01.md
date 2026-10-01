# CODEX Execution Log — BCM-M21 V01 Child 01

Status: `BUILDER_PASS / AWAITING_M21_CHILD_02`

Work item: `BCM-M21-001 — Mobile layout and touch QA`

Authority:
- `CHATGPT_EXECUTION_PROMPT_V01_CHILD_01.md`
- `CHATGPT_AUDIT_CRITERIA_V01_CHILD_01.md`
- `CHATGPT_AUDIT_CRITERIA_V01.md`

## Preflight and ordered publication

- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Start HEAD after required sync: `2dee275`.
- Initial `git status --short --branch`: clean `main...origin/main`.
- `git fetch origin main`: completed; initial divergence was `0 23`.
- Synchronization: `git merge --ff-only origin/main` → `2dee275`.
- Root `TASKS.md` was not edited. SHA-256 before child: `10f8ebf6269a7323d8c8e89d596b777a4334fcdf1d836ac2b2220b8ab2bae9b3`.
- Child implementation/evidence commit: `698eedaca007903ea6dca396037e33ee7bd5908f`.
- Child implementation push completed before this log publication.

## Scope and files

The child remained within mobile-layout/touch proxy QA. It added:

- `tests/m21_mobile_qa_probe.gd`;
- `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/mobile_qa/` with the
  machine-readable report, Markdown report, and 14 PNG captures;
- the narrow Island Map header visual-surface correction in
  `scripts/campaign/island_map_controller.gd`;
- `docs/codex-logs/BCM-M21-001_MOBILE_LAYOUT_V01_CODEX_LOG.md`.

No `TASKS.md`, campaign data, gameplay physics, progression authority, timer,
reward, economy, table, or HUD authority was changed.

## Exact validation results

- `godot_console.exe --headless --path . --check-only --script res://tests/m21_mobile_qa_probe.gd` — exit `0`.
- `godot_console.exe --path . --script res://tests/m21_mobile_qa_probe.gd --rendering-method gl_compatibility --display-driver windows` — exit `0`.
- Probe marker: `M21_CHILD_01_RESULT=PASS captures=14`.
- Captures: 11 canonical `720x1280`; 3 taller portrait `720x1440`.
- Production paths exercised: onboarding, Main Menu, Settings/toggle, PLAY,
  World Map island selection, locked feedback, 100-level Island Map and scroll,
  level selection, gameplay, pause/resume, LOSE, RETRY, WIN, and WIN → Island
  Map.
- No horizontal clipping was reported by the World Map or Island Map layout
  reports; Island Map vertical scroll and duplicate-node checks passed.
- Repeated navigation retained one World Map/Island Map pair and one gameplay
  instance.
- `git diff --check` — clean.

## Builder visual/manual checks

The refreshed onboarding, World Map, Island Map lower-scroll, and taller
gameplay captures were inspected as builder checks. The observed Island Map
header overlap was corrected with the in-scope `PanelContainer` → `Panel`
change and the complete probe was rerun. Independent ChatGPT inspection and
owner-native mobile acceptance were not performed.

## Limitations

- This is a desktop/mobile-layout proxy; no physical Android/iOS device was
  used.
- Device-specific touch, safe-area, performance, installation, and signed-store
  acceptance remain M21-006 owner-native/audit gates.
- The headless dummy renderer cannot produce image textures; real OpenGL/GL
  Compatibility capture was used and no device claim is made.

## Publication equality

Publication commit: to be recorded after this log commit.

After publication, the required equality checks will record the same SHA for:

```text
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
```

The next child may start only after that equality is proven.
