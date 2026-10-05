# BCM-M21 Final Owner F5 Acceptance Checklist V03

Status: **OWNER ACTION REQUIRED**

This is the current final M21 owner runtime checklist. It reflects the owner-approved R04 integrated gameplay-surface architecture and the audited World Map 720×1280 layout closure.

Run the synchronized canonical project in Godot using F5. For each item mark exactly one PASS or FAIL. Keep screenshots/runtime notes for any FAIL.

1. Confirm the desktop review window is comfortably visible at the current 800×1422 override while the canonical project viewport remains 720×1280.  
   Owner: [ ] PASS  [ ] FAIL

2. Open the World Map and confirm the full 720×1280 map presentation is clean:
   - title/header is unobstructed;
   - Back and Compass fit the top band;
   - Frozen Paradise and Volcano Bay marker/ring presentation does not collide with the header;
   - the boat sits in open water and does not cover Sunny Cove;
   - all ten hotspots visually correspond to their baked islands.  
   Owner: [ ] PASS  [ ] FAIL

3. Open Sunny Cove Island Map. Confirm the accepted Sunny Cove map artwork fills correctly, the level path/nodes remain readable, locked/open/current state feedback is correct, and back navigation works.  
   Owner: [ ] PASS  [ ] FAIL

4. Launch Sunny Cove Level 1. Confirm the current owner-approved R04 integrated gameplay surface is shown and no retired generic background, split-table layer, stale overlay, or obsolete visual appears.  
   Owner: [ ] PASS  [ ] FAIL

5. Use real mouse drag/release to launch at least ten cocktails. If testing on a touch-capable device, also verify touch launch. Confirm input feels normal and cocktails remain constrained by the accepted playable geometry.  
   Owner: [ ] PASS  [ ] FAIL

6. Confirm gameplay remains untimed:
   - no countdown;
   - no TIME UP;
   - no active +Time reward/ad path;
   - Pause → Resume works.  
   Owner: [ ] PASS  [ ] FAIL

7. Confirm To-Go progress works normally and VIP remains optional when present. No HUD/control element should block ordinary gameplay interaction.  
   Owner: [ ] PASS  [ ] FAIL

8. Complete a level. Confirm the result presentation is topmost/clean, contains no timer wording, and Retry / Next Level / Island Map actions work as applicable.  
   Owner: [ ] PASS  [ ] FAIL

9. Navigate Main Menu → PLAY → World Map → Sunny Cove → Island Map → gameplay → Results → map again and confirm there is no broken route, duplicate screen, stale modal, or blocked navigation.  
   Owner: [ ] PASS  [ ] FAIL

10. Restart the project and confirm campaign progress, settings, unlock state, and save persistence remain intact.  
    Owner: [ ] PASS  [ ] FAIL

## Final owner marker

All ten PASS:

`OWNER_F5_ACCEPTED_V03`

Any FAIL:

`OWNER_F5_REJECTED_V03`

If rejected, report the failing checklist item number(s) and attach the relevant screenshot/runtime observation.

Codex automated probes, screenshots, and Godot AI captures are technical evidence only. M21 release closure requires this explicit owner decision.
