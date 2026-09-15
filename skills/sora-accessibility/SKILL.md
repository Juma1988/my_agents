---
name: sora-accessibility
description: >
  Sora's accessibility design skill for contrast, semantics, text scaling, touch targets, focus order, screen-reader behavior, reduced motion, and accessible state/error design.
---


# Sora Accessibility

Accessibility is part of the design contract.

Review:
- contrast and non-color cues;
- touch target size;
- semantic labels;
- screen-reader reading order;
- focus/navigation behavior;
- text scaling;
- disabled-state clarity;
- error identification;
- keyboard interaction where relevant;
- reduced motion;
- destructive actions.

For Flutter, design so implementation can expose meaningful semantics without duplicating visible labels unnecessarily.

Do not solve large text by shrinking below readable sizes.

Classify:
- BLOCKING: core flow inaccessible;
- REQUIRED: meaningful compliance/usability issue;
- IMPROVEMENT: optional enhancement.

Return exact expected accessible behavior, not generic advice.
