---
name: kira-accessibility-qa
description: >
  Kira's accessibility QA skill for verifying semantics, touch targets, text scaling, contrast-related implementation, focus order, keyboard behavior, reduced motion, and RTL-sensitive accessibility.
---


# Kira Accessibility QA

Verify implemented behavior against Sora's accessibility contract.

Check where tooling/runtime permits:
- semantics labels/roles;
- reading/focus order;
- touch targets;
- large text;
- disabled states;
- error association;
- keyboard navigation;
- reduced motion;
- RTL interaction/readability.

Separate:
- design requirement missing;
- implementation defect;
- tooling limitation.

Do not mark PASS when required accessibility behavior was not actually checked.
