# M34-004 Gameplay Viewport Captures

The capture probe runs the production `scenes/main.tscn` and `GameManager` under Godot 4.7.2 with the project's fixed 720×1280 logical viewport. It resized the desktop test window to 390×844, 432×960, and 720×1280, then saved the actual production viewport image at the corresponding output dimensions without compositing. This reproduces the project's viewport scaling; it is not an Android/iOS device screenshot.

| Capture | Source level/state | Result |
|---|---|---|
| `mobile-captures/phone_390_one_starter.png` | Tiki L13; one initial starter; MOVES 96 | Captured at 390×844. |
| `mobile-captures/phone_390_one_starter_after_touch_input.png` | Same session after injected screen-touch drag; MOVES 95 | Captured at 390×844; one move launched through production input path. |
| `mobile-captures/phone_432_two_starters.png` | Tiki L27; two initial starters; MOVES 128 | Captured at 432×960. |
| `mobile-captures/phone_432_two_starters_after_touch_input.png` | Same session after injected screen-touch drag; MOVES 127 | Captured at 432×960; one move launched through production input path. |
| `mobile-captures/phone_390_tutorial_overlay.png` | Tiki L13 with guided tutorial visible | Captured at 390×844. |
| `mobile-captures/reference_720_no_starter.png` | Tiki L1; no initial starter; MOVES 16 | Captured at 720×1280. |
| `mobile-captures/reference_720_no_starter_after_touch_input.png` | Same session after injected screen-touch drag; MOVES 15 | Captured at 720×1280. |

`capture_manifest.json` records the renderer, logical viewport, state, exact dimensions, and probe-level owner-review/device flags. The runtime path passed; the captures still require owner visual review. Input was injected with production `InputEventScreenTouch` / `InputEventScreenDrag` events into the production viewport, not by tapping an Android/iOS device. Physical touch-target reachability, safe areas, assistive technology, reduced-motion visual review, and on-device screenshot parity remain unverified.
