# BCM-M25-PERCENT400 Child 01 — Formula audit

## Scope

Derive `T_to_go`, configured `T_vip`, inclusive `T_total`, and `move_limit = 4*T_total` for all 100 canonical Sunny Cove levels. Record each component, identify same-level To-Go/VIP overlaps, and confirm the existing delivery ledger does not spend one cocktail toward two goals unless that is its actual configured behavior. Verify the L6, L8, and L100 anchors and all per-level 2T/3T/4T boundaries.

## Constraints

Use the owner ruling and locked PERCENT400 criteria. Preserve all order targets and VIP reward semantics. Do not edit root `TASKS.md`, owner-local paths, or gameplay physics. Work only in the synchronized main checkout and isolated test copy.

## Evidence and stop

Publish the machine-readable 100-level formula audit and focused property-probe output under `evidence/M25-PERCENT400/`. Record the child commit SHA and validation results in the child log. Do not claim acceptance; hand off for independent audit.
