---
name: rei-release-readiness
description: >
  Rei's release-readiness skill for final preflight, exact QA provenance, version/build checks, release configuration, required artifacts, and blocking criteria before publication.
---


# Rei Release Readiness

A release is ready only when:
- explicit authorization exists;
- exact revision is pinned;
- Kira PASS matches that revision;
- required checks are not silently skipped;
- version/build is valid;
- release config is correct;
- artifact provenance is known;
- rollback path is understood.

Return READY or BLOCKED with exact blocker.
