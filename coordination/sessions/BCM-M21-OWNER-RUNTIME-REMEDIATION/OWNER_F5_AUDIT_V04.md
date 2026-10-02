# BCM-M21 Owner F5 Audit V04

Verdict: **OWNER_RUNTIME_FAIL / RELEASE BLOCKED**

Date: 2026-10-02

The owner manually tested V03 in Godot F5 and supplied screenshots plus debugger errors.

## PASS retained
- 800×1422 debug view.
- Main Menu / navigation basic flow.
- real gameplay input.
- no timer / no TIME UP.
- Pause → Resume.
- restart persistence.

## Release blockers

### World Map
Hotspots/state circles remain displaced from the actual baked themed island images.

### Sunny Cove Island Map
The correct map background now renders, but the procedural alternating node layout does not match the background landmarks. The owner supplied ten target landmark positions. Connector lines are rejected.

### Sunny Cove gameplay table
The correct wooden table renders, but it is too high. Owner requests the complete visual/playable table system lower by approximately 150 canonical pixels. Residual foreground decoration remains visible.

### WIN result
Level completion persists but result UI does not appear.

Debugger evidence identifies the root lifecycle failure:
- result CanvasLayer is added to SceneTree root while it is busy setting up children;
- overlay shell therefore does not reach ready state;
- `_show()` dereferences null labels.

This is a hard release blocker.

## Consequence
Previous V03 TECHNICAL PASS is superseded for final release acceptance on these surfaces.

M21-001, M21-004, and M21-006 remain CHANGES_REQUIRED.
