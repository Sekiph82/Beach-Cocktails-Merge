# BCM-M21-005 Release Manifest R01

## Release-candidate identity

- Release-candidate source SHA: `8d8cf5453f484647b37dd59c374c5327855b9eda`.
- Verification command: `git rev-parse 8d8cf5453f484647b37dd59c374c5327855b9eda; git cat-file -t 8d8cf5453f484647b37dd59c374c5327855b9eda`.
- Observed: the exact SHA and object type `commit`.
- Godot: `4.7.2.stable.official.ed1daf0bf`.
- Production main scene: `res://scenes/campaign/ApplicationShellScene.tscn`.
- Canonical viewport: `720x1280` portrait.
- Campaign save schema: `2`.
- Schema verification source: `scripts/campaign/save_manager.gd:7`, `const SCHEMA_VERSION := 2`.
- Schema verification command: `rg -n "SCHEMA_VERSION|schema_version" scripts/campaign/save_manager.gd`.

## Export and artifact status

- `export_presets.cfg`: absent.
- Attempted command: `godot_console.exe --headless --path . --export-release "Windows Desktop" <temporary-output>`.
- Attempted export exit: `1`; Godot reported that no root export preset exists.
- Generated distributables: none.
- Generated distributable SHA-256 list: empty.
- `adb`, `gradle`, `xcodebuild`, `keytool`, `jarsigner`, and `apksigner`: unavailable.
- Android/iOS export, signing, store packaging, and physical-device acceptance remain `UNVERIFIED_OWNER_ENVIRONMENT`.

## Reproducible checks

- Persistence smoke: `godot_console.exe --headless --path . --script res://tests/m21_release_persistence_probe.gd` → exit `0`, marker `M21_RELEASE_PERSISTENCE_RESULT=PASS`.
- Import/editor smoke: `godot_console.exe --headless --path . --editor --quit` → exit `0`.

## R01 boundary

R01 adds evidence manifests and audit transport derivatives only. It does not alter release-candidate product bytes, `project.godot`, campaign data, canonical assets, or original M21 V01 evidence. Owner-native acceptance remains pending.
