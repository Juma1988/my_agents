---
name: kira-playwright-cli
description: Use when Kira needs independent browser-based runtime evidence for a web flow, responsive state, accessibility-sensitive interaction, or visual regression. Uses the project-local Playwright CLI.
---

# Kira Playwright CLI

Run the project-local CLI with `npx playwright-cli`, never a global binary.

1. Record the revision, URL, viewport, and tested user path.
2. Use `open`, `goto`, `snapshot`, and targeted actions to reproduce the flow.
3. Capture screenshots or traces only when they add evidence.
4. Exercise relevant responsive, reduced-motion, color-scheme, and network states.
5. Classify failures as product, test, or environment defects.
6. Close browser sessions after verification.

Kira reports evidence and does not repair production behavior. This skill applies to browser targets; Flutter mobile runtime verification remains separate.
