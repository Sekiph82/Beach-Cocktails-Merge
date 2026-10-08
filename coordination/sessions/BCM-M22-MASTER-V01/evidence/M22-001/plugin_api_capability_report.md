# M22-001 installed API and packaging report

The synchronized repository baseline was `45086e032cb91553f264c825abefcc2618b5cb06` on `main`, with `HEAD = origin/main = origin/main live ref`; the pre-sync history was `0 ahead / 13 behind`. `project.godot` enables both editor plugins and declares both autoloads. Exact source/config byte sizes and SHA-256 hashes are in `plugin_source_hashes.json`; the dynamic runtime inventory is in `plugin_runtime_inventory.json`.

## Installed consumer APIs

- Game Feel Flow 1.0.0, autoload `/root/GameFeelFlow`: `play`, `play_combo`, `play_global`, `stop`, `stop_all`, `get_effect`, `get_combo`, `resolve_combo`, `get_effect_names`, `get_combo_names`. Runtime registered 31 effect names and 15 built-in combo names. The exact names and resolved combo entries are retained in the runtime inventory.
- Saltmire Spark 1.0.0, autoload `/root/Spark`: `burst(global_position, opts={})`, `at(node, opts={})`, `clear()`. Built-in presets: `spark`, `hit`, `explode`, `pickup`, `dust`, `confetti`. Runtime default is 14 particles, 220 px/s, 0.45 s; individual preset effective amounts range to 34 particles and lifetime to 0.9 s. These are reference defaults, not BCM policy budgets.

## Effect safety findings

GFF registers `impulse`, `velocity`, `freeze_frame`, `time_scale`, and `camera_flash`; these remain forbidden. `camera_shake` is also excluded. Source-resolved stock combos contain position shake, color flash, scale/position punches, and several contain freeze-frame entries; none is whitelisted by this contract. The bridge and policy must use explicit safe single-effect selections and bounded Spark overrides. This child made no effect call.

## Packaging and optional-consumer contract

Both addon directories are tracked canonical project source and both current autoloads remain enabled. The project does not claim to boot if addon files are physically deleted while autoload declarations remain. `PresentationPluginContract` uses generic `Node` method/property inspection, contains no addon script preload, emits no effect, and performs no per-frame polling. The host explicitly refreshes the capability snapshot once and may explicitly refresh it in tests/lifecycle. Missing singleton or expected methods produce unavailable capabilities; unknown names/presets fail closed.

## Validation

`tests/m22_001_plugin_contract_probe.gd` passed 21/21 checks with both real singletons, each singleton absent, both absent, partial method sets, unknown lookup, and unchanged authority fingerprint. It invoked only lookup APIs. Godot 4.7.2 editor parse/import passed. M21 100-level progression and real production World Map mouse/touch input checks are recorded in the accompanying command-output files. An older V07 gameplay probe is parse-stale because it references removed `IslandEntry.MARKER_CENTER`; no production M21 code was changed to accommodate that stale probe.
