# BCM-M21-004 Regression Publication Record V01

This versioned publication record corrects the publication SHA/equality fields for the immutable Child 04 coordination log.

- Work item: `BCM-M21-004`.
- Coordination log: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CODEX_LOG_V01_CHILD_04.md`.
- Regression evidence commit: `0feca0fd3caa86f4a88c910375ef9f6229575b9c`.
- Child 04 log publication commit: `ba37c667b33d01b5f07b198d8acb0d47fe3b97a8`.
- This correction publication is the commit that adds this record; its exact resolved SHA is captured by the final equality command below and by the pushed Git history.

Final publication verification:

```text
git status --short --branch
## main...origin/main

git rev-parse HEAD
the correction publication commit that adds this record

git rev-parse origin/main
the same correction publication commit

git ls-remote origin refs/heads/main
the same correction publication commit  refs/heads/main

git diff --check
PASS
```

The Child 04 regression report records `M21_CHILD_04_RESULT=PASS checks=33 passed=33 failed=0`. Root `TASKS.md` was not modified; its SHA-256 remained `10f8ebf6269a7323d8c8e89d596b777a4334fcdf1d836ac2b2220b8ab2bae9b3`.

Child 04 remains builder evidence pending independent ChatGPT audit.
