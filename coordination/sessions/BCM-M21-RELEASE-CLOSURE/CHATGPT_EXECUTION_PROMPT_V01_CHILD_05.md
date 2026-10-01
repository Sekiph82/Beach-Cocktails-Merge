# BCM-M21-005 — Export / Release Configuration

Execute only after Child 04 publication equality.

Audit/create the minimum production release/export configuration needed for the current project without committing secrets.

Verify:
- production App Shell is main scene;
- no production UI exposes test/debug progression bypass;
- campaign/settings/onboarding persist across release-mode restart smoke;
- export presets/templates/toolchains actually available on this machine;
- create reproducible release candidate artifact(s) where possible;
- hash any generated distributable;
- record unavailable Android/iOS/signing/toolchain items exactly.

Never commit signing secrets, keystores, certificates, provisioning profiles, passwords, tokens, or machine-specific SDK paths.

Publish release manifest + `CODEX_LOG_V01_CHILD_05.md`; prove equality before Child 06.
