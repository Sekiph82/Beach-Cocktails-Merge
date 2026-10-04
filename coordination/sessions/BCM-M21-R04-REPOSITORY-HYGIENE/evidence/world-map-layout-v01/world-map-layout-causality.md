# World Map layout diagnosis — BCM-M21-001 V01

## Pre-fix reproduction

- Command: `godot_console.exe --headless --path . --script tests/m12_world_map_probe.gd`
- Godot: `4.7.2.stable.official.ed1daf0bf`
- Exit: `1`; all M12 checks passed except `visual map 720x1280 geometry remains clean`.
- Full output: `pre-fix-m12-run.log`; exit value: `pre-fix-m12-exit-code.txt`.
- Exact two-island and canonical reports, including marker, label, ring, canvas, header and footer rectangles: `pre-fix-layout-report.json`.

## Cleanup causality

- Controller blob at cleanup baseline `6febc285` and pre-task handoff `fdd1e534` is identical: `0fa46a41e2983ad9eebc64ed6bff12d0055bacb7`.
- The M12 probe diff between those commits only removes retired `map_background` fixture keys; layout assertions are unchanged.
- All ten canonical `map_position` values are byte/value-identical between cleanup baseline, pre-task handoff, and current `data/campaign/islands.json`.
- Therefore the report failure predates cleanup. The renderer showed that the failure was accompanied by real presentation overlap, so the task was not closed by relabeling the old assertion alone.

## Rendered cause and bounded repair

At a real 720×1280 OpenGL renderer viewport, the northern Frozen Paradise and Volcano Bay selection rings passed behind the title panel. The decorative boat was also rendered at the source texture's native 320×180 size despite the intended 86×62 control size, and covered Sunny Cove's marker and labels.

The repair preserves all island `map_position` values, unlock state, tap target size, campaign logic, and gameplay assets. It:

- constrains the title/back/compass band to y=0..76 and reapplies texture-control sizes after parenting, so the title panel is 444×76 and compass is 70×70;
- restores the intended MapBoat size to 86×62 after parenting, places it in open water clear of Sunny Cove's label, and draws it behind markers;
- makes the layout report distinguish horizontal and vertical viewport clipping, actual marker overlap with header/status/navigation, and header controls that overflow their safe band.

The pre-fix and post-fix screenshots are retained in this directory. `world_map_layout_diagnostic.gd` is the renderer-capable 720×1280 capture/report harness.

## Godot AI runtime inspection

The current World Map was run through the connected Godot AI editor session after reloading the scene from disk. Runtime UI inspection confirmed:

- viewport: 720×1280;
- Header: `(0,0)` size `720×76`;
- TitlePanel: `(138,0)` size `444×76`;
- Compass: `(624,3)` size `70×70`;
- MapBoat: `(205,1030)` size `86×62`;
- StatusPanel: `(24,1120)` size `672×78`;
- SelectionBoundary: `(26,1210)` size `668×46`.

Godot AI reported a live, non-stale game capture at native framebuffer size 720×1280 (displayed at 405×720 in the tool UI). The full-size post-fix screenshot is `post-fix-full-fresh-720x1280.png`.
