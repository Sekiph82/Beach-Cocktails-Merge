# BCM-M21-001 — Mobile Layout & Touch QA Proxy

Status: `BUILDER_PASS / PHYSICAL_DEVICE_DEFERRED`

This evidence exercises the production `ApplicationShellScene` at the canonical
720×1280 viewport and a representative 720×1440 portrait `SubViewport`. It
drives the existing production `Button` controls/signals for onboarding,
Settings, PLAY, island selection, level selection, pause/resume, retry, and
result-to-map navigation. It does not mutate campaign completion dictionaries
or claim physical-device acceptance.

## Environment

- Godot: `4.7.2.stable.official.ed1daf0bf`
- Renderer: OpenGL 3.3 / GL Compatibility on Intel Iris Xe
- Host: Windows desktop proxy; no physical mobile device was used
- Production viewport: `720×1280`
- Taller portrait proxy: `720×1440`

## Automated/proxy results

- Onboarding → Main Menu: PASS; five-page production control path.
- Main Menu → World Map: PASS through PLAY button.
- World Map: PASS; production island controls, no horizontal clipping, locked
  feedback, and one map-node per campaign island.
- Island Map: PASS; 100 level buttons, no horizontal clipping, vertical scroll
  reaches the lower levels, and no duplicate level nodes.
- Gameplay: PASS; level-button launch, pause overlay, resume, and gameplay
  capture.
- Results: PASS; LOSE, RETRY, WIN, and WIN → Island Map actions.
- Repeated navigation: PASS; the router retains one World Map/Island Map pair
  and one gameplay instance at a time.

## Captures

All captures were saved by the real-renderer run and have the dimensions shown
in their filenames. The JSON report records the machine-readable capture list.

- Canonical: onboarding, Main Menu, Settings, World Map, locked feedback,
  Island Map top/bottom, gameplay, pause, LOSE, and WIN.
- Taller portrait: World Map, Island Map bottom, and gameplay.

## Narrow in-scope fix

The Island Map header used a `PanelContainer` while its title, subtitle, and
summary were explicitly positioned children. The lower-scroll capture showed
those controls being container-relayout into an overlapping header. The
production visual surface is now a plain `Panel`; no gameplay, campaign,
physics, or authority logic changed.

## Limitations / handoff

Physical touch, device-specific safe areas, device performance, installation,
and owner-native visual acceptance remain explicitly deferred to M21-006. The
technical evidence is a desktop/mobile-layout proxy only.
