# CODEX Execution Log — BCM-M21-005

Status: `COMPLETE_BUILDER_EVIDENCE_AWAITING_AUDIT`

## Work item and locked scope

- Work item: `BCM-M21-005` — export/release configuration and persistence smoke.
- Prompt: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_EXECUTION_PROMPT_V01_CHILD_05.md`.
- Criteria: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01_CHILD_05.md`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Start HEAD after Child 04 equality: `9bcd96534fb5d6cb08b80864b3f4fb60d3cdb250`.
- Implementation/evidence commit: `b1604a2c752712feba7eb113fbfedf4d3d1ec368`.

## Preflight and protected scope

- Canonical checkout was clean and synchronized before Child 05.
- `git fetch origin main`: completed.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
- Root `TASKS.md` was not modified; SHA-256 remained `10f8ebf6269a7323d8c8e89d596b777a4334fcdf1d836ac2b2220b8ab2bae9b3`.
- No secrets, keystores, certificates, provisioning profiles, passwords, tokens, or machine-specific SDK paths were committed.

## Production configuration and smoke

- `project.godot` main scene: `res://scenes/campaign/ApplicationShellScene.tscn` — verified.
- Production viewport: `720x1280` portrait; GL Compatibility — verified.
- Production shell control inspection found no reachable `debug_progression_bypass` control.
- Added `tests/m21_release_persistence_probe.gd`.
- Command: `godot_console.exe --headless --path . --script res://tests/m21_release_persistence_probe.gd`.
- Isolated `APPDATA` user-data root was outside the repository.
- Result: exit `0`, `M21_RELEASE_PERSISTENCE_RESULT=PASS`.
- Verified onboarding dismissal, settings writes, campaign completion/save, and all three values after a second production shell restart.

## Export/toolchain evidence

- Godot: `4.7.2.stable.official.ed1daf0bf` available.
- `godot_console.exe --headless --path . --editor --quit`: exit `0`; nested `res://original_reference/project.godot` warning is known and ignored by the editor scan.
- `export_presets.cfg`: absent.
- `godot_console.exe --headless --path . --export-release "Windows Desktop" <temporary-output>`: exit `1`; Godot reported no root export preset.
- No distributable was generated; no artifact hash is claimed.
- `adb`, `gradle`, `xcodebuild`, `keytool`, `jarsigner`, and `apksigner`: unavailable.
- Android/iOS export, signing, store packaging, and physical-device release smoke are `UNVERIFIED_OWNER_ENVIRONMENT`.

## Published evidence

- `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/release/M21-005_RELEASE_MANIFEST.json`.
- `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/release/M21-005_RELEASE_MANIFEST.md`.
- The manifest explicitly separates PASS production-path runtime evidence from unavailable exported/signed release acceptance.

## Publication gate

- Implementation/evidence commit pushed: `b1604a2c752712feba7eb113fbfedf4d3d1ec368`.
- Child 05 log publication commit: to be recorded by the versioned publication log.
- Equality after implementation publication:
  - local `HEAD`: `b1604a2c752712feba7eb113fbfedf4d3d1ec368`
  - `origin/main`: `b1604a2c752712feba7eb113fbfedf4d3d1ec368`
  - `git ls-remote origin refs/heads/main`: `b1604a2c752712feba7eb113fbfedf4d3d1ec368`
- Worktree clean at implementation publication.

Child 05 is builder evidence only; independent audit and owner release environment remain authoritative.
