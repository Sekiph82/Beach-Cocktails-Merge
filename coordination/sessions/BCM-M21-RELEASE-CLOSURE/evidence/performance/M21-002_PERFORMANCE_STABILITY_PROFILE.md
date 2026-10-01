# BCM-M21-002 — Performance & Stability Profile

Status: `BUILDER_PASS / HOST_PROFILE_ONLY`

## Environment

- Windows desktop host, Intel Iris Xe, GL Compatibility renderer.
- Godot `4.7.2.stable.official.ed1daf0bf`.
- Production `ApplicationShellScene` and canonical campaign database.
- No physical Android/iOS device was used; mobile performance remains an
  owner-native gate.

## Bounded run

- 12 Island Map open/close + scroll cycles.
- 8 gameplay launch → LOSE → result-action → Island Map cycles.
- 20 campaign save write/read cycles.
- 20 Settings write/read cycles.
- 20 onboarding write/read cycles.
- 60 process-frame timing samples.

## Results

- World Map nodes: 10 entries / 10 marker nodes throughout.
- Island Map: 100 level buttons throughout; map authority stayed at 2 instances.
- Gameplay authority: 1 instance while active, 0 after each return-to-map cycle.
- Object count: 2,867 warmup minimum; 2,875 after map cycles; 2,934 during
  gameplay cycles; no progressive increase across repeated cycles.
- Orphan node count: 0 for all 21 lifecycle samples.
- Campaign payload: 301 bytes for every save sample.
- Save IO: 20 writes and 20 reads all returned valid state.
- Settings IO: 20 writes and 20 reads all returned schema version 1.
- Onboarding IO: 20 writes and 20 reads all returned completed state.
- Host frame samples: 60; minimum `0.018 ms`, median `7.856 ms`, average
  `7.662 ms`, maximum `16.230 ms`.

The full per-cycle samples and exact IO timings are in
`M21-002_PERFORMANCE_STABILITY_PROFILE.json`.

## Interpretation and limitations

The bounded host run shows stable node/instance counts, zero orphan nodes, a
constant save payload, and no progressive object-count trend. These are host
measurements only; they do not establish target-device FPS, memory ceilings,
thermal behavior, touch latency, or store-install behavior. Those remain
explicitly `UNVERIFIED_OWNER_NATIVE_GATE`.
