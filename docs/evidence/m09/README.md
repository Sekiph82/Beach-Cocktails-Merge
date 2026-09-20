# BCM-M09 audio/haptics/micro-polish evidence

The focused M09 probe is:

```text
godot_console.exe --headless --path . --script tests/m09_audio_haptics_probe.gd
```

It verifies the owner-directed normal-game target sequence `L5 -> L6 -> L7`, normal `L6-L12` selection after the first three orders, the unchanged reward table including `L5=0`, exactly-once merge/order feedback hooks, disabled and unsupported haptics no-ops, and M08 effect cleanup.

Normal GUI evidence from the same probe:

- `startup_l5_720x1280.png`
- `l5_delivery_in_progress_720x1280.png`

No canonical audio files exist in the repository. Audio dispatch is therefore a safe registered-stream hook with no stream registered; it cannot change timing or state. Haptics default to a no-op on desktop/unsupported platforms and are rate-limited when a supported mobile platform is available.

These are Codex builder evidence artifacts. Independent ChatGPT audit and owner runtime acceptance remain pending.
