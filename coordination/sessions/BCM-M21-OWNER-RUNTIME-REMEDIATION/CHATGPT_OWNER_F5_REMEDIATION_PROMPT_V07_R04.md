# BCM-M21-001 + BCM-M21-006 — V07-R04 Master-Locked Sunny Cove Gameplay Composition

Work in the canonical checkout on `main`.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V07_R04.md`
4. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R04.md`
5. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V07_R03.md`
6. V07-R03 review composites for negative comparison only.

Root `TASKS.md` is read-only to Codex.

## Owner decision

Candidates A, B, and C are all rejected. Do not ask the owner to select one and do not promote any of them.

Create ONE new V07-R04 Sunny Cove composition following the owner master structure.

### Critical correction

The newly supplied master image is **NOT** the source for these five HUD designs:

- Beach Cocktails Merge logo
- To-Go Orders
- Best Score
- Score
- Next

Those five must remain the CURRENT Beach Cocktails Merge design already present in the project/current V07-R03 review composition.

Do not copy or imitate the master image's versions of those five HUD elements.

Everything else in the gameplay scene should follow the master composition as closely as practical.

## Required visual result

The master should be interpreted as a close player-facing gameplay board, not a complete freestanding table.

Build the scene around these facts:

- table rear edge begins below the existing current HUD;
- table is narrower at the rear and expands strongly toward the player;
- table fills almost the entire screen width at the near edge;
- the tabletop occupies most of the center/lower screen;
- strong raised side/front rails;
- near edge reaches roughly y=980..1040 at 720×1280;
- no need to show complete table legs;
- no large sand gap below the table;
- directly below the front edge is a wide integrated L1-L12 progression strip using almost the full width;
- all 12 progression cocktails are large/readable and arranged horizontally;
- never squeeze progression between table legs.

The old R03 between-leg progression solution is forbidden.

## Tabletop

Use one horizontal deadline, positioned on the tabletop in a master-like lower-middle location.

Place the held/current cocktail naturally in front of that deadline, close to the player-facing end.

A subtle master-like held/launch marker below the cocktail is allowed.

DO NOT reproduce the master's vertical dotted/arrow guide line.

Forbidden:
- vertical dotted guide;
- arrow path;
- trajectory preview;
- target ray;
- substitute aiming line;
- launch-zone box;
- colored/shaded/labeled launch region.

## Current HUD lock

Use the real current project assets and current accepted layout for:

- current logo;
- current To-Go Orders;
- current Best Score;
- current Score;
- current Next.

These five should look exactly like the current Beach Cocktails Merge design, not like the master reference.

Do not redesign them to fit the master. Design the rest of the scene around them.

Preserve gameplay Pause behavior; do not let Pause redesign drive this visual task.

## Sunny Cove environment

Keep a bright tropical Sunny Cove environment around/behind the board:
- ocean;
- beach/resort/deck context;
- palms/tropical foliage;
- appropriate side framing.

Use the owner master for scale, perspective, table/front/progression hierarchy, and scene density. Adapt only decorative/environment details to the Beach Cocktails art language.

## Review composite

Create one definitive 720×1280 review composite showing:

- the five frozen current-design HUD elements;
- the master-derived close board;
- one horizontal deadline;
- current held cocktail in front of deadline;
- no vertical guide line;
- integrated full-width L1-L12 strip immediately below the table front;
- representative crowded tabletop using current cocktail assets so the owner can judge scale/readability.

Also export the clean surface separately.

Do not bake runtime cocktails, progression icons, or the five HUD panels into the clean static surface if they are runtime UI/content.

## Scope guard

This is still a visual gate.

Do not modify:
- production collision/playable geometry;
- physics;
- scoring;
- To-Go/VIP logic;
- campaign truth;
- World Map/Island Map;
- persistence;
- current production surface binding;
- root `TASKS.md`.

Create:
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/SUNNY_COVE_MASTER_REDESIGN_V07_R04.md`
- matching measurement JSON;
- review evidence under `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/visual-candidates/v07-r04/`
- `docs/codex-logs/CODEX_LOG_OWNER_F5_REMEDIATION_V07_R04.md`

Finish exactly:

`AWAITING_OWNER_VISUAL_ACCEPTANCE_V07_R04`
