# BCM-M21 Owner F5 Audit V05

Verdict: **OWNER_RUNTIME_FAIL / RELEASE BLOCKED**

Owner manual F5 observation:
- application opens;
- Main Menu renders;
- PLAY / CONTINUE does not respond;
- SETTINGS does not respond;
- owner cannot enter World Map.

Source audit identifies a full-screen result CanvasLayer created by CampaignNavigation that remains independently active when CampaignNavigation Control is hidden.

V04 technical PASS is therefore superseded for final owner acceptance on menu/input lifecycle.

Active tasks:
- BCM-M21-001
- BCM-M21-006

BCM-M21-004 remains closed.
