---
name: kira-regression-testing
description: >
  Kira's regression-testing skill for turning defects and changed behavior into focused tests, selecting adjacent regression scope, and avoiding low-value test duplication.
---


# Kira Regression Testing

Regression testing protects behavior that has already failed or is likely to fail because of a change.

For each change:
1. identify old behavior;
2. identify intended new behavior;
3. identify adjacent assumptions;
4. create the smallest test that captures the failure mode;
5. re-run adjacent paths.

Bug regression tests should fail for the original defect where practical.

Do not add broad duplicate coverage with no extra signal.

Return:
- defect/change;
- regression test;
- adjacent risk;
- evidence;
- remaining gap.
