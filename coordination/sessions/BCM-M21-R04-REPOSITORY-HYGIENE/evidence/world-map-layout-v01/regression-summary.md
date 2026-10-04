# BCM-M21-001 World Map layout regression summary

All required checks ran against Godot 4.7.2.stable.official.ed1daf0bf after the final source change.

| Check | Result | Evidence |
|---|---|---|
| Clean editor import / parse / boot | PASS, exit 0 | `godot-clean-import-parse-boot.log` |
| M12 World Map probe, run 1 | PASS, exit 0 | `post-fix-m12-run-1.log` |
| M12 World Map probe, run 2 consecutive | PASS, exit 0 | `post-fix-m12-run-2.log` |
| Renderer-capable World Map diagnostic and GUI capture | PASS, exit 0, 720×1280 | `post-fix-renderer-diagnostic.log` and `post-fix-*.png` |
| Godot AI runtime node/UI inspection | PASS, live non-stale frame | `world-map-layout-causality.md` and `post-fix-layout-report.json` |
| M10 campaign architecture | PASS, exit 0 | `m10-regression.log` |
| M11 save migration/progression | PASS, exit 0 | `m11-regression.log` |
| M13 Island Map | PASS, exit 0 | `m13-regression.log` |
| M14 gameplay session bridge | PASS, exit 0 | `m14-regression.log` |
| M20 app shell/navigation | PASS, exit 0 | `m20_app_shell-regression.log` |
| R04 surface/profile authority | PASS, 10 islands / 71 checks | `r04_authority-regression.log` |
| Asset validator | PASS, 356/356 manifest checksums; 10/10 R04 families; invalid semantic duplicates 0 | `asset-validator.log` |
| `git diff --check` | PASS | builder log |

## Visual captures

Pre-fix screenshots: `pre-fix-full-fresh-720x1280.png`, `pre-fix-top-area-720x360.png`, `pre-fix-bottom-area-720x360.png`, `pre-fix-locked-selection-720x1280.png`, and `pre-fix-selected-current-720x1280.png`.

Post-fix screenshots: `post-fix-full-fresh-720x1280.png`, `post-fix-top-area-720x360.png`, `post-fix-bottom-area-720x360.png`, `post-fix-locked-selection-720x1280.png`, and `post-fix-selected-current-720x1280.png`.

The pre-fix M12 report and exact command output are retained alongside the post-fix canonical and two-island geometry report. See `world-map-layout-causality.md` for the diagnosed overlap, cleanup-baseline comparison, and bounded repair.
