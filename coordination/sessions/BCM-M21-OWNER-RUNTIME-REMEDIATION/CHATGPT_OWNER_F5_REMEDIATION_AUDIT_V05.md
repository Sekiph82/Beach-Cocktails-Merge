# BCM-M21 Owner F5 Remediation V05 — Independent Audit

Verdict: **TECHNICAL_AUDITED_PASS / OWNER_F5_ACCEPTANCE_REQUIRED**

Auditor: ChatGPT  
Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`  
Audited HEAD: `5b6535ecb1407ee469a382657b30af2656d7f993`

## 1. Scope

Active tasks:
- BCM-M21-001
- BCM-M21-006

BCM-M21-004 remains closed.

Authority:
- `OWNER_F5_RULING_V05.md`
- `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V05.md`
- current source, runtime report and builder log.

## 2. Result-layer input lifecycle — PASS

Current source confirms:
- result CanvasLayer is created hidden;
- full-screen result root uses `MOUSE_FILTER_IGNORE`;
- CampaignNavigation `visibility_changed` is observed;
- hiding CampaignNavigation hides result feedback and result CanvasLayer;
- World Map / Island Map / Retry / Next Level transitions hide result feedback;
- result CanvasLayer is made visible only for an actual ready result card.

Therefore the previous invisible full-screen result surface no longer remains active over the Main Menu.

## 3. Real GUI input proof — PASS

The V05 GUI probe uses:
- `InputEventMouseButton`;
- `Viewport.push_input(event, true)`;
- visible production Control centers.

Independent source inspection confirms real GUI clicks are dispatched for:
- PLAY / CONTINUE;
- World Map Back;
- SETTINGS;
- BACK TO MENU;
- Sunny Cove;
- Level 1;
- result Next Level;
- result Island Map;
- post-result PLAY / SETTINGS.

The probe does not use direct calls to:
- `press_play_continue()`;
- `show_settings()`;
- `close_settings()`;
- result action handlers.

Final report:
- GUI click count = 15;
- failed checks = [];
- result layer visible at finish = false;
- result root mouse filter = IGNORE.

## 4. Runtime error gate — PASS

Final V05 probe log contains:
- `ERROR:` = 0;
- `SCRIPT ERROR:` = 0;
- `Parent node is busy setting up children` = 0;
- `Invalid assignment ... on Nil` = 0;
- final marker `M21_OWNER_F5_REMEDIATION_V05_GUI_RESULT=PASS`.

## 5. V04 behavior preservation — PASS

Builder regression evidence reports:
- V04 owner-runtime probe PASS;
- mouse launch 10/10;
- touch launch 10/10;
- no timer;
- preserved World Map / Island Map behavior;
- preserved +150 table geometry;
- preserved result lifecycle;
- settings persistence PASS;
- release/save persistence PASS;
- Godot parse/import PASS;
- `git diff --check` PASS.

No new gameplay regression is identified.

## 6. Repository integrity — PASS

- final local/origin/remote handoff reported at `5b6535ecb1407ee469a382657b30af2656d7f993`;
- root `TASKS.md` was not modified by CODEX;
- 14 generated translation sidecars remain untracked and untouched;
- existing preservation stash remains retained.

## 7. Owner checklist

`OWNER_F5_ACCEPTANCE_CHECKLIST_V05.md` exists with all owner PASS/FAIL fields blank.

CODEX did not claim owner acceptance or release-ready status.

## 8. Final verdict

**TECHNICAL_AUDITED_PASS.**

No further CODEX remediation is authorized unless the owner F5 V05 review identifies a defect.

- BCM-M21-001 remains pending owner manual acceptance.
- BCM-M21-006 remains pending owner manual acceptance and final release closure.
- BCM-M21-004 remains CLOSED.

Next actor: **OWNER**.
