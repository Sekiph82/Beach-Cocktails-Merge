# BCM-M21-005 Release Manifest V01

## Verified production inputs

- Godot `4.7.2.stable.official.ed1daf0bf` is available.
- `project.godot` configures `res://scenes/campaign/ApplicationShellScene.tscn` as the main scene.
- The project remains portrait `720x1280` with GL Compatibility rendering.
- The production shell exposes no reachable `debug_progression_bypass` control.

## Persistence smoke

Command:

```text
godot_console.exe --headless --path . --script res://tests/m21_release_persistence_probe.gd
```

Result: exit `0`, marker `M21_RELEASE_PERSISTENCE_RESULT=PASS`.

The probe used the production `ApplicationShellScene`, isolated `APPDATA` outside the repository, and verified onboarding, settings, campaign completion, and all three values after a second shell restart.

## Import/export tooling

`godot_console.exe --headless --path . --editor --quit` returned exit `0`. The only known import warning is the ignored nested `res://original_reference/project.godot`.

No `export_presets.cfg` exists in this checkout. The attempted Windows release export:

```text
godot_console.exe --headless --path . --export-release "Windows Desktop" <temporary-output>
```

returned exit `1` because the project has no export preset. No distributable was generated and therefore no artifact hash is claimed.

The following tools were unavailable on this machine: `adb`, `gradle`, `xcodebuild`, `keytool`, `jarsigner`, and `apksigner`. Android/iOS exports, signing, and store submission remain `UNVERIFIED_OWNER_ENVIRONMENT`.

No signing secrets, keystores, certificates, provisioning profiles, passwords, tokens, or machine-specific SDK paths were committed.

## Claim boundary

The persistence PASS is production-path runtime evidence. It is not an exported or signed-release acceptance claim. Owner-native device and release-environment verification remains required.
