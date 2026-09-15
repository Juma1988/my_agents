---
name: kira-runtime-debugging
description: >
  Kira's runtime-debugging skill for reproducing crashes, hangs, async timing defects, navigation failures, lifecycle bugs, and environment-vs-product failures in Flutter.
---


# Kira Runtime Debugging

When runtime behavior fails:

1. reproduce reliably;
2. record device/environment/revision;
3. capture minimal logs without secrets;
4. isolate trigger;
5. distinguish product, test, and environment failure;
6. reduce to smallest reproduction;
7. retest after correction.

For hangs:
- identify last observable state;
- check outstanding async work;
- check lifecycle/disposal;
- avoid infinite waiting.

Do not fix production behavior yourself.
Return evidence to Adam.
