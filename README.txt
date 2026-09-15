Beach Cocktails - Merge / Prototype v6.7
========================================

Godot: 4.7.x
Main scene: res://scenes/main.tscn

SYNCHRONIZED BASELINE
---------------------
This repository contains the accepted BCM-M00-001 synchronization baseline and the
BCM-M00-002 Godot 4.7.x hygiene/import baseline. Production sources are the root
project.godot, scenes/, scripts/, data/, and assets/ trees. The original_reference/
folder is retained as non-production reference material.

OPEN / RUN
----------
- Open the repository root in Godot 4.7.x and press F6/F5 as appropriate.
- The configured main scene is res://scenes/main.tscn.
- Deterministic headless validation: godot --headless --path . --editor --import --quit
- Headless main-scene startup validation: godot --headless --path . --quit-after 5

PHYSICS BASELINE (accepted v6.7)
--------------------------------------
- Launch speed: 700 px/s.
- Slide deceleration: 180 px/s^2.
- No cruise/assist/minimum-speed support.
- Existing collision, forward-only movement, merge momentum, danger line, game-over and restart behavior are unchanged.
- To-Go Orders targets remain L6-L12; the first target is L8 and immediate repeats are avoided.

SCORING SYSTEM
--------------
Merge score is awarded when the resulting level is created:
- L2: 20
- L3: 50
- L4: 100
- L5: 200
- L6: 350
- L7: 600
- L8: 1,000
- L9: 1,600
- L10: 2,500
- L11: 4,000
- L12: 6,500

Combo:
- Combo window: 1.5 seconds. Every merge refreshes the timer.
- x1: +0% of merge score
- x2: +25%
- x3: +50%
- x4: +75%
- x5: +100%
- x6+: +125% (capped at x6)

TO-GO ORDERS
------------
- L8: 3,000
- L9: 5,000
- L10: 8,000
- L11: 12,000
- L12: 18,000
- When a newly merged drink matches the active order, normal merge/combo points are paid first, then the separate order bonus.
- The same stock rule applies to every order level L6-L12. If a matching drink already exists on the table when a later order appears, one matching drink is automatically delivered.
- A stored drink does NOT earn its merge score or old combo again when delivered later; only the To-Go Orders bonus is awarded.
- If multiple matching drinks exist, one drink fulfils one order and the others stay on the table.

VISUAL STATUS
-------------
Placeholder visuals are intentionally retained. The dedicated v7 art pass follows after the scoring/gameplay baseline is accepted.


v6.7 INPUT RHYTHM:
- A new held glass appears immediately after every shot.
- The player can fire again while previous glasses are still sliding.
- Multiple moving glasses are intentionally supported for richer collisions and combos.
