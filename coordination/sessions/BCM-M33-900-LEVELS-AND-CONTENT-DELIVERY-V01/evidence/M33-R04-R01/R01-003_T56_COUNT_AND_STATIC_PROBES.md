# R01-003 — T56 count and static campaign probes

**Disposition: PASS for arithmetic correction and current-package probes; regenerated package remains blocked.**

The R04 README's `870/879` count was wrong. The per-island `after_generated_normal_T56_or_less` values sum to 879 ordinary generated records at or below T56. The nine level-100 capstones are excluded from this ordinary denominator. `README.md` now states `879/879`; the new deterministic test checks the sum and verifies zero ordinary records above T56.

Current package checks, before any regeneration:

- `python tools/validate_m33_campaign_content.py` — PASS; 900 packaged records, 12 inherited M32 Tiki records, 888 generated records, 539 global full signatures including inherited rows, 361 cross-island repeats, and nine capstones.
- Godot 4.7.2 `tests/m33_campaign_content_probe.gd` — PASS.
- Godot 4.7.2 `tests/m33_campaign_navigation_probe.gd` — PASS; all ten production islands, synthetic completion to global level 1000, and schema-two save round trip.
- Exact Sunny Cove and original M32 Tiki source hashes match the current R04 report and isolated validation sandbox.

These checks validate the existing R04 package only. They do not certify the requested L6+ correction or a replacement manifest. No 899-level physics sweep or human playtest was run.
