# BCM-M12-WORLD-MAP — Art Direction Reset Brief V01

Status: **OWNER VISUAL APPROVAL REQUIRED BEFORE IMPLEMENTATION**

## Why this exists

M12 V02 is source-functional but owner-rejected visually.

The current cyan/ocean-route-marker composition must not be iterated further as the visual foundation.

## Target quality bar

The World Map must feel like part of **Beach Cocktails Merge**, not a debug menu.

Use the same polished tropical/beach visual language as the accepted game art:
- bright premium tropical resort atmosphere;
- rich turquoise water;
- warm sand/gold accents;
- lush palms/foliage;
- soft painterly/cartoon-realistic rendering;
- clean, high-value mobile-game finish;
- strong depth, lighting, material richness and readable silhouettes.

Avoid:
- flat cyan debug backgrounds;
- wireframe-looking loops;
- criss-crossing route spaghetti;
- repetitive identical circular lock badges dominating the screen;
- tiny island art floating in empty space;
- generic dashboard/card aesthetics;
- placeholder typography treatments;
- crude procedural shapes as final visual language.

## World Map composition

The screen should read as a **travel map / tropical archipelago** immediately.

Recommended composition:
- full-screen illustrated ocean/world background;
- 8–10 visually distinct island silhouettes/mini-dioramas placed along a coherent travel route;
- islands vary in shape, vegetation, landmark and color;
- route should be a simple readable progression, not intersect itself;
- one current/open island strongly emphasized;
- locked islands visually muted with tasteful lock treatment;
- future islands may partially fade into mist/clouds for depth;
- top title/navigation area should be integrated into the art, not floating debug text;
- bottom information area should be minimal and secondary.

## Sunny Cove

Sunny Cove is the only initially open/selectable destination.

It should:
- be visually brightest/current;
- have a warm highlight/halo or animated sparkle;
- remain readable as a destination even without text;
- feel inviting and playable.

## Locked islands

The remaining displayed destinations must:
- remain spatially visible;
- look distinct from each other;
- be dimmed/desaturated or partially cloud-covered;
- show a tasteful lock badge/overlay;
- remain non-navigable.

Do not use the same dominant circular lock frame for every island.

## Route

Use a readable route:
- dotted nautical path, rope line, wake trail, compass path, or similar;
- one clear sequential path;
- no self-intersections;
- no oversized yellow strokes covering destinations.

## Visual hierarchy

Priority:
1. islands/world art;
2. current destination;
3. route;
4. lock state;
5. labels;
6. auxiliary status text.

The map itself must carry the experience.

## Mobile target

Portrait 720x1280 primary.
Must also remain visually coherent in Godot embedded 405x720 preview.

## Implementation gate

No further Codex implementation prompt should be issued until the owner approves a visual reference/concept image for the World Map.

Once approved, the implementation prompt must explicitly require matching that approved reference while preserving the V02 lifecycle/data-driven fixes.
