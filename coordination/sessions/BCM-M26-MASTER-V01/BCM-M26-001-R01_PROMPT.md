# M26-001-R01 editor import investigation

First synchronize local with GitHub main without discarding any owner modifications. Preserve project.godot, saves and addons. Verify the test sandbox and real user-data log isolation before launching Godot.

Investigate why Godot AI plugin.gd references a missing export/mcp_export_plugin.gd file. Determine whether the repository has an incomplete plugin installation or whether this is only a test sandbox problem. Do not invent an empty replacement. Obtain a compatible genuine file only when provenance can be verified. Otherwise demonstrate clean editor import with the addon disabled in a disposable sandbox only, and report the regular editor-import blocker as unresolved. Never edit owner project.godot or overwrite local plugin files.

Rerun editor import, 120-frame boot, M26-001 GL probe, M22 policy and relevant plugin fallback checks. Keep original owner saves and user-data logs identical. Publish evidence and execution log to GitHub, with accurate limits. Codex does not edit TASKS.md. Do not begin M26-002 or M27. Stop for GPT audit.
