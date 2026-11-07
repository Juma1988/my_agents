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

## Design-quality tools

For visually important web work, Sora may use the project-local Taste Skill and Impeccable output as inputs. Apply only design principles compatible with the product and framework; do not import web-specific React or Tailwind conventions into Flutter work.

Use `sora-design-references` when a design-system reference materially improves a decision. References inform the contract; they never replace user-approved direction.
