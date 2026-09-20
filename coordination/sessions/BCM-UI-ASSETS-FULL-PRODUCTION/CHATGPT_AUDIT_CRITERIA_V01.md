# BCM-UI-ASSETS-FULL-PRODUCTION — Locked Audit Criteria V01

Status: LOCKED BEFORE CODEX EXECUTION  
Audit owner: ChatGPT  
Builder: Codex  
Repository: `Sekiph82/Beach-Cocktails-Merge`  
Required branch: `ui-assets`

This document is the acceptance contract for the first full visual-asset production pass. Builder logs are claims, not proof.

## A. Branch isolation — blocking

A01. All production commits must be on `ui-assets`.  
A02. `main` must not be updated, force-pushed, merged into, rebased, or otherwise mutated by this work.  
A03. The final builder log must show start/end HEAD, current branch, `origin/ui-assets`, and remote refs.  
A04. Root `TASKS.md` must be byte-for-byte unchanged by the builder.  
A05. Existing runtime folders `assets/cocktails/`, `assets/environment/`, `assets/effects/`, and `assets/ui/` must not be deleted or overwritten in this pass.  
A06. New production assets must live under `assets/ui_assets/**`, except explicitly allowed branch-only tooling/evidence/log paths.

Failure of any A01-A05 is a blocking audit failure.

## B. Required source documents — blocking

B01. Builder must read and follow:
- `ui-assets-tasks.md`
- `docs/ui-assets/FULL_VISUAL_ASSET_MANIFEST_V1.md`
- `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V1.md`
- this audit criteria
- execution prompt V01
- root `AGENTS.md`

B02. Builder may not silently reinterpret a mandatory deliverable. If a required generation capability is unavailable, the builder must mark the item blocked in its log and stop rather than substituting placeholders and claiming completion.

## C. Full-manifest completeness — blocking

C01. Every required runtime asset in `FULL_VISUAL_ASSET_MANIFEST_V1.md` must either:
- exist at the specified path as a usable final PNG, or
- be explicitly listed as blocked in the builder log with a concrete reason.

C02. A claimed PASS requires 100% of mandatory manifest assets.  
C03. Placeholder rectangles, duplicated files renamed as distinct assets, empty/near-empty PNGs, text-only stand-ins, or obvious temporary mocks do not count as final assets.  
C04. Each of the ten island environment packs must include every mandatory file listed in the manifest.  
C05. All ten islands must be visually distinguishable by theme while remaining part of one coherent product.

## D. Table geometry — blocking

D01. Base viewport is 720×1280 portrait.  
D02. All ten gameplay tables use the exact same master canvas dimensions.  
D03. All ten gameplay tables use the same outer tabletop alpha/silhouette mask.  
D04. Front-left outer table corner is exactly the viewport bottom-left corner in canonical raster coordinates.  
D05. Front-right outer table corner is exactly the viewport bottom-right corner in canonical raster coordinates.  
D06. Rear edge is centered and approximately 64% of viewport width, using the frozen geometry values recorded in `table_geometry_v1.json`.  
D07. Rear Y, table depth, perspective centerline, launch alignment, and playable-boundary geometry are identical for every island.  
D08. No island may have a custom/wider/narrower gameplay footprint.  
D09. Builder must produce `assets/ui_assets/tables/table_geometry_v1.json`.  
D10. Builder must produce a common silhouette/mask asset or reproducible equivalent and an overlay/contact-sheet proof that the ten tables align.  
D11. The first asset pass must not modify live gameplay boundary code or existing runtime scene integration.  
D12. The log must explicitly defer runtime table/play-area integration to UIA-M14.

Any geometry mismatch beyond documented symmetric one-pixel raster rounding is a failure.

## E. Visual quality and coherence

E01. Style is bright, polished, tropical casual-mobile, premium, readable, and internally consistent.  
E02. Panels/buttons/icons share a coherent bevel, rim, shadow, highlight, stroke, and material language.  
E03. Asset lighting direction is consistent enough that screens do not look composited from unrelated packs.  
E04. Text-bearing art should avoid baking dynamic values into PNGs. Dynamic content areas must remain usable by Godot labels/sprites.  
E05. Small icons remain recognizable at intended mobile sizes.  
E06. Dark-island and light-island assets preserve gameplay/UI contrast.  
E07. Effects are restrained and do not obscure cocktail silhouettes or order readability.

## F. Island identity requirements

F01. Sunny Cove: bright teak + turquoise resin + white beach-club trim.  
F02. Tiki Island: dark teak + bamboo + carved tiki warmth.  
F03. Azure Bay: white yacht-deck + aqua resin + marina luxury.  
F04. Coconut Beach: natural pale wood + woven/coconut organic details.  
F05. Sunset Island: mahogany + amber/coral sunset reflections.  
F06. Party Beach: dark lacquer + controlled neon club accents.  
F07. Frozen Paradise: frosted/icy pale-blue crystalline treatment.  
F08. Volcano Bay: obsidian/basalt + restrained lava seams.  
F09. Billionaire Island: walnut + white marble + gold trim.  
F10. Final Island: exotic blackwood + mother-of-pearl/turquoise inlay + premium gold climax.  
F11. None of these identity changes may move the table edge or gameplay footprint.

## G. Technical asset validity — blocking where applicable

G01. Every declared PNG must decode successfully.  
G02. Transparent UI/effect assets must actually contain usable alpha where expected.  
G03. Full-screen backgrounds must have appropriate opaque coverage unless the manifest explicitly expects layering.  
G04. No asset may be zero-byte, corrupt, malformed, or accidentally stored as another format with a .png extension.  
G05. Naming/path case must match the manifest.  
G06. No unsupported machine-local absolute paths may be embedded in manifests or generation metadata.  
G07. Generated runtime assets must not depend on uncommitted local font/image files.  
G08. No font files are to be committed as part of this task unless already present and licensed in the repository; prefer Godot/system/project typography handling.

## H. Originality / provenance — blocking

H01. No watermarked art.  
H02. No scraped assets from other games or websites.  
H03. No unlicensed third-party icon/texture packs copied into the repository.  
H04. The manifest/log must state the generation/source method for each family.  
H05. If external generation tooling is used, builder must still commit the resulting final assets and enough metadata to reproduce the export process where feasible.

## I. Required metadata and evidence — blocking

I01. `assets/ui_assets/ASSET_MANIFEST.json` exists and covers every produced runtime asset.  
I02. `assets/ui_assets/ASSET_DIMENSIONS.csv` exists and agrees with actual files.  
I03. `assets/ui_assets/README.md` documents folder structure and generation/export workflow.  
I04. Required contact sheets exist:
- `CONTACT_SHEET_GLOBAL.png`
- `CONTACT_SHEET_ISLANDS.png`
- `CONTACT_SHEET_TABLES.png`
- `CONTACT_SHEET_SCREENS.png`

I05. Contact sheets must be readable enough to audit visual consistency and cannot merely be filename lists.

## J. Required branch-only validation

J01. Builder must run an automated manifest-existence check.  
J02. Builder must run PNG decode/dimension validation.  
J03. Builder must run table-canvas equality validation.  
J04. Builder must run table alpha/silhouette equality validation.  
J05. Builder must run front-corner and rear-width geometry assertions against `table_geometry_v1.json`.  
J06. Builder must verify no pre-existing asset path was modified.  
J07. Builder must verify no changes were pushed to `main`.  
J08. Validation commands and exact results must be recorded in the log.

## K. Allowed and forbidden code scope

Allowed:
- `assets/ui_assets/**`
- `tools/ui_assets/**`
- `tests/ui_assets/**`
- `scenes/ui_assets_preview/**`
- `docs/ui-assets/**` only when adding builder-produced evidence/readme that does not rewrite locked criteria
- `coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CODEX_LOG_V01.md`

Forbidden in V01:
- `scripts/game_manager.gd`
- live gameplay scenes
- existing runtime asset files outside `assets/ui_assets/**`
- root `TASKS.md`
- main-branch campaign code
- merge/rebase conflict resolution against other active work

## L. Builder log requirements — blocking

`coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CODEX_LOG_V01.md` must include:
- prompt version;
- audit-criteria version;
- branch;
- start HEAD;
- end HEAD;
- list of commits;
- files changed summary;
- generation method/tooling;
- complete/blocked manifest counts;
- table geometry measurements;
- validation commands/results;
- contact-sheet paths;
- known limitations;
- explicit confirmation root `TASKS.md` untouched;
- explicit confirmation current gameplay code untouched;
- explicit confirmation main untouched;
- final `git status --short --branch`;
- final remote ref verification.

## M. Audit verdict logic

**PASS** requires every blocking criterion and complete mandatory manifest.

**CONDITIONAL** may be used only for genuinely minor visual polish defects when all mandatory assets, geometry, validation, isolation, and metadata requirements pass.

**FAIL / CHANGES_REQUIRED** is mandatory for:
- missing mandatory asset families;
- placeholders presented as final assets;
- table geometry mismatch;
- branch contamination;
- existing asset overwrite;
- gameplay-code edits in V01;
- missing validation evidence;
- corrupt assets;
- provenance concerns.

## N. Remediation protocol

If audit is not unconditional PASS:
1. ChatGPT writes `CHATGPT_AUDIT_V01.md`.
2. ChatGPT writes a versioned remediation prompt, e.g. `CHATGPT_REMEDIATION_PROMPT_V01.md`.
3. ChatGPT writes matching locked remediation criteria, e.g. `CHATGPT_REMEDIATION_AUDIT_CRITERIA_V01.md`.
4. Codex executes only that remediation scope on `ui-assets`.
5. Codex writes a new immutable remediation log.
6. ChatGPT re-audits before updating `ui-assets-tasks.md`.

The builder may not self-close or merge this branch.
