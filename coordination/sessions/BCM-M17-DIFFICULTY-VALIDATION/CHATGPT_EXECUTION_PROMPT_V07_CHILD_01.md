# V07 Child 01 - Preflight, Source Integrity, and Frozen-Scope Proof

Read the V07 master prompt and Child 01 criteria before acting. Work only in the canonical Desktop checkout.

## Scope

Perform the synchronized preflight and prove the V06-R02 source, V05 semantics, canonical Sunny Cove data, and frozen-scope inputs are present and unchanged. Derive the exact 42 confirmation candidates and verify the three carried-forward feasible classes from the audited V06-R02 report. Do not run confirmation trials, modify production code, modify canonical data, edit root `TASKS.md`, or alter historical evidence.

## Required evidence

- exact `git status`, remote, fetch, divergence, and final SHA evidence;
- SHA-256 for canonical Sunny Cove data, V06-R02 JSON, and V05 optionality evidence;
- source schema/status/policy/time-scale validation;
- exact candidate list/count, representative/member mapping, and carried-forward class list;
- proof that the V07 runner is evidence-only and that the frozen paths remain unchanged.

## Stop conditions and handoff

Stop with a truthful blocked child log if synchronization is ambiguous, any source hash/schema or mapping check fails, or any frozen path is changed. Do not repair by resetting, stashing, rebasing, force-pushing, or overwriting owner work.

Write `CODEX_LOG_V07_CHILD_01.md`. On a clean pass, hand off to Child 02. Child 02 is not accepted until this child passes.
