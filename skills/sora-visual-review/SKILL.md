---
name: sora-visual-review
description: >
  Sora's screenshot/runtime visual-review skill for comparing implemented Flutter UI against the approved design contract, including spacing, hierarchy, responsiveness, RTL, accessibility, and state fidelity.
---


# Sora Visual Review

Use screenshots/recordings/runtime evidence as implementation evidence.

Compare:
- hierarchy;
- spacing rhythm;
- typography;
- alignment;
- density;
- contrast;
- safe areas;
- clipping/overflow;
- keyboard;
- real states;
- RTL/text expansion;
- reusable-component consistency;
- motion where observable.

Return:
```text
FIDELITY: PASS | ISSUES | BLOCKED

ISSUE:
EXPECTED:
OBSERVED:
IMPACT:
CORRECTION:
```

Do not infer engineering correctness from appearance.
Kira independently verifies behavior.
