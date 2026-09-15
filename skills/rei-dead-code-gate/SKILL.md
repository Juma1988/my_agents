---
name: rei-dead-code-gate
description: >
  Rei's final pre-publish dead-code gate for detecting likely unused/obsolete code without invalidating QA. Rei reports non-trivial candidates to Adam/Yuna instead of silently deleting production code.
---


# Rei Dead-Code Gate

Run before release as a final hygiene/risk gate.

Check candidates against:
- references;
- dynamic/string lookup;
- DI;
- routes;
- manifests;
- generated registration;
- public exports;
- platform registration;
- build scripts.

Classify:
- harmless warning/noise;
- DEAD_CODE_CANDIDATE;
- RELEASE_BLOCKER.

Do not delete non-trivial production code.

If removal/change is needed:
Rei → Adam → Yuna → Kira → Rei preflight again.

This preserves QA provenance.
