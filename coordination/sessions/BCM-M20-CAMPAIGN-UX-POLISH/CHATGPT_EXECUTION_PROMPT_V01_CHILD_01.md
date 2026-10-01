# BCM-M20-001 — App Shell / Main Menu Entry

Execute only Child 01.

Introduce one application shell above the existing CampaignNavigationScene.

Requirements:
- boot to Main Menu;
- PLAY/CONTINUE launches the existing campaign flow;
- SETTINGS entry exists but Child 03 owns its full implementation;
- World Map can return to Main Menu through an application-level navigation signal;
- campaign/save/economy authorities are not duplicated;
- campaign progress is never reset by entering/leaving Main Menu;
- one live CampaignNavigation instance maximum.

Update project main_scene only as required for the shell.

Add focused tests for boot state, play/continue, return-to-menu, instance count, and progress preservation.

Populate `CODEX_LOG_V01_CHILD_01.md`, publish, prove equality, then stop before Child 02 if anything fails.
