# BCM-M22-001 — Locked Audit Criteria V01
## Exact installed plugin contract, packaging, and graceful fallback

Status: **LOCKED BEFORE EXECUTION**

### Authority inspected by ChatGPT before handoff
Current GitHub `main` contains the exact installed addon source:
- Game Feel Flow plugin.cfg: version **1.0.0**
- Saltmire Spark plugin.cfg: version **1.0.0**
- autoloads: `/root/GameFeelFlow` and `/root/Spark`
- GameFeelFlow production API includes `play`, `play_combo`, `play_global`, `stop`, `stop_all`, `get_effect`, `get_combo`, `resolve_combo`, `get_effect_names`, `get_combo_names`
- Saltmire Spark production API includes `burst`, `at`, `clear`; presets: spark/hit/explode/pickup/dust/confetti

Installed repository bytes override any older planning shorthand.

### PASS criteria
1. Exact addon inventory is captured from repository/local bytes with hashes/version/method names and current autoload/editor-plugin state.
2. No production effect is added in this child.
3. A reusable plugin capability/contract layer may inspect `/root/GameFeelFlow` and `/root/Spark` dynamically, but MUST NOT invoke visual effects. It must use generic Node/has_method checks and must not hard-preload optional plugin scripts.
4. Consumer fallback is proven for:
   - both singleton nodes present;
   - GameFeelFlow absent;
   - Spark absent;
   - both absent;
   - expected method absent;
   - unknown effect/preset lookup;
   - thrown/failed plugin call simulated at the future bridge boundary.
5. Gameplay/campaign startup state hash is identical across fallback cases.
6. No per-frame plugin discovery or polling. Capability discovery is cached once per presentation host/session and explicitly refreshable only for tests/lifecycle.
7. Packaging truth is documented:
   - current canonical package includes both tracked addon folders and current autoloads;
   - graceful fallback means presentation consumers no-op if a singleton/API is unavailable;
   - do not falsely claim the current project can boot after physically deleting tracked addon files while their autoload entries remain.
8. Exact GFF forbidden baseline is recorded: `impulse`, `velocity`, `freeze_frame`, `time_scale`, full-screen `camera_flash`; camera/screen shake remains disabled by default.
9. Stock GFF combos are not blindly whitelisted. Their actual entries are inspected because many include shake/flash/freeze.
10. Spark built-in preset defaults are recorded as references only; future particle counts/lifetimes must be overridden to BCM budgets.
11. Godot editor parse + headless boot + M21 critical smoke remain green.
12. Evidence committed as `.txt/.json/.md`, not ignored local-only `.log`.

### Required evidence
`coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-001/`
- plugin inventory JSON
- API/capability report
- fallback matrix
- boot/state-hash report
- command outputs with exit codes

### Child log
`docs/codex-logs/CODEX_LOG_M22_001_PLUGIN_CONTRACT_V01.md`

Final child marker:
`M22_001_READY_FOR_MASTER_CONTINUATION`
