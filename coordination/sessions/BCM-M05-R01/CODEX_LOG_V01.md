# BCM-M05-R01 — Codex Remediation Log V01

## Scope and governance

- Work item: BCM-M05-R01, strict cocktail sprite/collider evidence remediation.
- Prompt: coordination/sessions/BCM-M05-R01/CHATGPT_REMEDIATION_PROMPT_V01.md
- Locked criteria: coordination/sessions/BCM-M05-R01/CHATGPT_AUDIT_CRITERIA_V01.md
- Repository: https://github.com/Sekiph82/Beach-Cocktails-Merge.git
- Branch: main
- Workspace: C:\Users\sekip\Desktop\Beach Cocktails - Merge
- Start HEAD for this phase: b23c338403cabc94ea8996551b5875f3e68dd842
- This is builder evidence only; no independent audit or AUDITED_PASS was assigned.
- TASKS.md and all ChatGPT-owned prompt/criteria/audit/policy files were not edited.

## Sync and source preservation

M04-R01 was pushed before this phase. The phase began from a clean synchronized main after the M04 commit:

    git status --short --branch
    ## main...origin/main
    git rev-list --left-right --count HEAD...origin/main
    0 0
    git rev-parse HEAD
    b23c338403cabc94ea8996551b5875f3e68dd842

Canonical source check before staging:

    git diff --quiet -- assets/cocktails assets/environment assets/ui assets/effects
    M05_SOURCE_ASSET_DIFF_EXIT_CODE=0

No owner-approved PNG was changed. M06/M07 production files were not changed by this bounded M05 commit.

## Implementation and provenance correction

Changed files:

    scripts/drink.gd
    tests/m05_sprite_integration_probe.gd
    tests/m05_evidence_canvas.gd
    tools/m05_presentation_manifest.py
    docs/evidence/m05/presentation_manifest.json
    docs/evidence/m05/all_levels_clean.png
    docs/evidence/m05/all_levels_collider_overlay.png
    docs/evidence/m05/touching_pairs.png
    docs/evidence/m05/merge_continuity.png
    coordination/sessions/BCM-M05-R01/CODEX_LOG_V01.md

The production mapping remains one COCKTAIL_TEXTURE_PATHS table plus Drink.texture_for_level(level), with invalid levels returning an empty path/null texture. M05 did not add any L13 path.

The unsupported M04-alpha-bound attribution was removed. The final body dataset is explicitly classified MANUAL_VISUAL_MEASUREMENT_GLASS_BODY. For each level, presentation_manifest.json records source hash/dimensions/whole-image alpha bbox, selected visible glass-body bbox, body width/height/center offset, runtime scale/offset, collider radius and runtime mass. The body boxes deliberately exclude straw, fruit, leaves, flowers and other garnish extremes.

The historical pre-M05 JSON radius correction is retained truthfully in this new log. The correct pre-M05 data/drinks.json radius series is:

    14,21,29,38,48,59,71,84,98,113,129,146

The previous immutable M05 log's incorrect 18,22,26,30,35,41,48,55,63,71,79,89 statement was not edited.

Current evidence-backed glass-body widths are:

    L01=690 L02=725 L03=627 L04=759 L05=545 L06=700
    L07=575 L08=615 L09=650 L10=625 L11=610 L12=710

Current production scales/offsets/radii:

    L01 scale=0.057971 offset=(1.449275,-7.594203) radius=20
    L02 scale=0.063448 offset=(0.920000,-8.438621) radius=23
    L03 scale=0.086124 offset=(-0.387560,-10.162680) radius=27
    L04 scale=0.081686 offset=(0.122530,-8.005270) radius=31
    L05 scale=0.132110 offset=(-0.066055,-20.543120) radius=36
    L06 scale=0.120000 offset=(-0.360000,-15.360000) radius=42
    L07 scale=0.170435 offset=(-0.085217,-20.963480) radius=49
    L08 scale=0.182114 offset=(-1.001626,-24.676420) radius=56
    L09 scale=0.196923 offset=(-0.590769,-28.652310) radius=64
    L10 scale=0.230400 offset=(-2.419200,-32.371200) radius=72
    L11 scale=0.262295 offset=(-2.098361,-36.196720) radius=80
    L12 scale=0.253521 offset=(0.507042,-36.253520) radius=90

Pre-remediation scales were:

    0.055556,0.060526,0.070130,0.070455,0.102857,0.105000,
    0.150769,0.143590,0.142222,0.189474,0.210526,0.200000

The bounded increase is derived from the narrower manually selected glass-body regions, not a fixed arbitrary multiplier. Collider radii and compressed runtime masses remain unchanged. The measured body width multiplied by the production scale equals the live collider diameter for each level, while garnish/straw pixels remain outside the selected sizing boxes.

## Retained runtime evidence

The M05 probe uses actual Drink.create(), live Sprite2D nodes, Drink.visual_scale_for_level(), Drink.visual_offset_for_level() and live CollisionShape2D radii. It generated:

    docs/evidence/m05/all_levels_clean.png
    docs/evidence/m05/all_levels_collider_overlay.png
    docs/evidence/m05/touching_pairs.png
    docs/evidence/m05/merge_continuity.png

Capture hashes:

    all_levels_clean.png dimensions=1600x760 bytes=480046 sha256=B0F3678D415D235F69408A6C0BC9BE49A48D3EAEC0E58F2A546E584F8C1FA58D
    all_levels_collider_overlay.png dimensions=1600x760 bytes=501420 sha256=5263BC7B4E95EA3437C849FE1BDB3C1213EBAE7F3192C9B7599DECFB5B49735C
    touching_pairs.png dimensions=1600x760 bytes=258058 sha256=570A454D609F12180E7BF5D323579DE90B98065DAD1E429367F9D0F53B56C8D5
    merge_continuity.png dimensions=1600x760 bytes=37391 sha256=7E7FADE71CF313735C33FCE1C2DA3868DF88CDB89100C1D6EBB9990AF36E438E
    presentation_manifest.json bytes=12700 sha256=9283465AC69DB9F80E8DF12B204AE92F434C3F72DFAD62900C605EEC30D87CEE

Visual evidence notes:
- all_levels_clean shows the actual L01-L12 Sprite2D progression in three rows without debug circles.
- all_levels_collider_overlay shows the same live sprites with red collider outlines and cyan center/pivot markers.
- touching_pairs shows L01/L02, L06/L07 and L11/L12 at physical contact distances using live radii; this is direct evidence for small/mid/high apparent contact.
- merge_continuity shows actual L02 + L02 and resulting L03 canonical textures.
- Shape diversity was explicitly reviewed: tumbler, martini, highball, goblet, coconut and pineapple bodies are represented; garnish/straw extremes were not used as collider sizing inputs.
- The overlay is evidence of runtime API output, not a claim that a circle is a perfect semantic mesh. Human visual fit remains an independent audit item.

## Commands and exact results

Manifest generation:

    python tools/m05_presentation_manifest.py
    M05_MANIFEST levels=12 output=docs/evidence/m05/presentation_manifest.json
    M05_MANIFEST_METHOD=MANUAL_VISUAL_MEASUREMENT_GLASS_BODY
    M05_MANIFEST_RADII=20.0,23.0,27.0,31.0,36.0,42.0,49.0,56.0,64.0,72.0,80.0,90.0
    M05_MANIFEST_RESULT=PASS
    M05_MANIFEST_PROCESS_EXIT_CODE=0

Focused M05 runtime probe:

    godot_console --path . --script res://tests/m05_sprite_integration_probe.gd --rendering-method gl_compatibility --display-driver windows
    Godot Engine v4.7.2.stable.official.ed1daf0bf
    OpenGL API 3.3.0 - Build 31.0.101.3616 - Compatibility - Using Device: Intel - Intel(R) Iris(R) Xe Graphics
    M05_PROBE PASS: main scene loads as PackedScene
    M05_PROBE PASS: runtime world and shot controller are ready
    M05_PROBE PASS: invalid levels fail safely without an L13 texture
    M05_PROBE PASS: all L01-L12 table drinks use the canonical Sprite2D mapping
    M05_PROBE PASS: all L01-L12 visual/body scales stay bounded for the portrait playfield
    M05_EVIDENCE_CAPTURE path=res://docs/evidence/m05/all_levels_clean.png dimensions=1600x760 error=0
    M05_EVIDENCE_CAPTURE path=res://docs/evidence/m05/all_levels_collider_overlay.png dimensions=1600x760 error=0
    M05_EVIDENCE_CAPTURE path=res://docs/evidence/m05/touching_pairs.png dimensions=1600x760 error=0
    M05_EVIDENCE_CAPTURE path=res://docs/evidence/m05/merge_continuity.png dimensions=1600x760 error=0
    M05_PROBE PASS: runtime collider/pivot/contact evidence captures saved
    M05_PROBE PASS: held launch drink uses a canonical Sprite2D
    M05_PROBE PASS: merge creates the correct next-level sprite atomically
    M05_PROBE PASS: merge result preserves forward/lateral momentum without visual teleport
    M05_PROBE PASS: L12 has no L13 texture/path and stays capped
    M05_RAPID_VISUALS launches=6 verified_steps=6 current_level=1
    M05_PROBE PASS: rapid launches preserve coherent current/next Sprite2D visuals
    M05_PROBE PASS: restart leaves one playable held Sprite2D and no orphan visuals
    M05_PROBE PASS: Game Over preserves visual/body ownership without orphan nodes
    M05_PROBE PASS: restart after Game Over restores one canonical held visual
    M05_PROBE_RESULT=PASS
    M05_GODOT_PROCESS_EXIT_CODE=0

M01 regression after M05 changes:

    godot_console --headless --path . --script res://tests/m01_contract_probe.gd
    M01_PROBE_RESULT=PASS
    M01_PROCESS_EXIT_CODE=0

M02 regression after M05 changes:

    godot_console --headless --path . --script res://tests/m02_physics_regression.gd
    M02_BODY_CONFIG level=6 mass=2.5 radius=42.0 freeze_mode=0 ccd=2 linear_damp=0.0 angular_damp=3.0 friction=0.07999999821186 bounce=0.0
    M02_RAPID_LAUNCH launches=6 world_drinks=7 simulated_previous=6 current_valid=true current_state=0
    M02_PROBE_RESULT=PASS
    M02_PROCESS_EXIT_CODE=0

M03 regression after M05 changes:

    godot_console --headless --path . --script res://tests/m03_economy_regression.gd
    M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
    M03_PROBE_RESULT=PASS
    M03_PROCESS_EXIT_CODE=0

M04 regression after M05 changes:

    godot_console --headless --path . --script res://tests/m04_asset_import_probe.gd
    M04_GODOT_ASSET_COUNT expected=22 observed=22 cocktails=12 environment=1 ui=8 effects_required=1
    M04_GODOT_PROBE PASS: repository PNG directory counts match canonical scopes
    M04_GODOT_RESULT=PASS
    M04_PROCESS_EXIT_CODE=0

Godot/import/startup:

    godot_console --version
    4.7.2.stable.official.ed1daf0bf
    VERSION_PROCESS_EXIT_CODE=0
    godot_console --headless --quiet --path . --editor --import --quit
    WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
    IMPORT_PROCESS_EXIT_CODE=0
    godot_console --headless --quiet --path . --quit-after 3
    STARTUP_PROCESS_EXIT_CODE=0

Hygiene:

    git diff --check
    M05_DIFF_CHECK_EXIT_CODE=0
    git diff --name-only -- TASKS.md
    M05_TASKS_DIFF_EXIT_CODE=0
    git diff --name-only -- coordination/sessions/BCM-M05-R01
    M05_COORDINATION_DIFF_EXIT_CODE=0

Existing tests were not weakened. The M05 test addition is evidence-producing and retains the original gameplay/visual ownership assertions; the only bound change is the documented visual extent envelope from 320 to 360 to accommodate the evidence-backed larger high-level sprites without changing physics.

## Verification classification and limitations

Verified by machine: canonical mapping/invalid level safety, runtime Sprite2D ownership, finite scale/offset/radius, merge texture/collider atomics, rapid launch, restart/Game Over ownership, M01-M04 probe results, Godot import/startup and source asset diff.

Manual visual evidence: body bbox selection, garnish/straw exclusion, shape-diversity review, apparent contact quality and pivot credibility. These are explicitly represented by retained images and the manifest but remain subject to independent ChatGPT inspection.

Unverified by builder: independent acceptance verdict, owner-native device acceptance and final milestone transition. No M06 or M07 implementation was introduced in this phase.

## Commit/push

M05 is committed separately from M04 and before M06:

    git diff --check
    M05_PRECOMMIT_DIFF_CHECK_EXIT_CODE=0
    git commit -m "Remediate M05 sprite collider evidence"
    git push origin main
    M05_PUSH_PROCESS_EXIT_CODE=0

    The final M05 commit SHA and equality are recorded after push.
