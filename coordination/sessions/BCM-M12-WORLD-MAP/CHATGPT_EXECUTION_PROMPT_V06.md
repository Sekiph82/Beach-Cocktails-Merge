# BCM-M12-WORLD-MAP — V06 Semantic Asset De-duplication Remediation

Remediate the V05 production library against:
`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_V05.md`

Do not redo accepted V04 masters.
Do not alter protected logo, reference boards, or frozen table geometry.

Primary task:
Find and fix every semantically invalid duplicate asset in the 398-entry production library.

Required process:
1. Parse `assets/ui_assets/V05_ASSET_REGEN_STATUS.csv` and group rows by final SHA256.
2. For every duplicate group, inspect intended path/category/use.
3. Keep shared bytes only when reuse is genuinely intentional and semantically valid.
4. Any semantically different assets must be regenerated/derived into distinct purpose-appropriate visuals.
5. Use the owner-approved V04 masters as primary visual authority and the two original style boards as secondary authority.
6. Preserve the exact same visual style as V04.

Mandatory known fixes include at least:
- disabled / locked / primary / secondary / small button variants;
- generic large / medium / small panel variants;
- popup frame;
- tooltip frame;
- large / small reward frames;
- star-track checkpoint / chest large / chest small / fill / marker / panel;
- daily-ready / finale / milestone / new / new-content / reward-ready / sale badge family;
- any other duplicate SHA group where filenames or intended semantics differ materially.

Add a validator that scans the entire manifest for duplicate SHA groups and fails semantically invalid reuse.

The validator must output:
- duplicate group SHA;
- all paths in the group;
- allowlisted intentional reuse if any;
- invalid duplicate count;
- final PASS only when invalid duplicate count is 0.

Update:
- `V05_ASSET_REGEN_STATUS.csv` or create `V06_ASSET_REMEDIATION_STATUS.csv`;
- manifest hashes/source metadata;
- contact sheets affected by remediation;
- relevant uniqueness reports.

Table visual rule remains frozen:
- no table silhouette change;
- no playable-area geometry change;
- no rear/front/perspective geometry change;
- all table alpha masks remain pixel-identical to the canonical mask.

Run regressions after remediation.

Write:
`coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V06.md`

Return:
- log URL
- implementation SHA
- invalid duplicate groups before
- invalid duplicate groups after
- remediated asset count
- validation result
- regression result
- AWAITING_AUDIT

Then STOP.