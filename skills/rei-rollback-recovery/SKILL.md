---
name: rei-rollback-recovery
description: >
  Rei's rollback and recovery skill for release/deployment failures, partial publication, previous known-good versions, data/schema compatibility, and safe retry decisions.
---


# Rei Rollback & Recovery

Before release define:
- previous known-good version;
- rollback mechanism;
- data/schema compatibility;
- store/deployment constraints;
- what happens if publication partially succeeds.

Before retrying a failed publish:
1. determine whether it actually completed partially;
2. determine whether the operation is idempotent;
3. verify current destination state;
4. choose retry, rollback, or block.

Never blindly repeat a non-idempotent release action.
