---
name: yuna-dependency-health
description: >
  Yuna's Flutter/Dart dependency-health skill. Use when adding, replacing, upgrading, or reviewing packages; when a package looks stale; or when dependency risk could affect implementation.
---

# Yuna Dependency Health

Use this skill for Flutter/Dart package decisions.

## Before Adding a Package

Ask:
1. Can Flutter/Dart/platform APIs solve it?
2. Does the project already include something suitable?
3. Is a small local implementation cleaner?
4. Does the package materially reduce complexity?

## Evaluate Candidate

Check:
- maintenance recency;
- Flutter/Dart compatibility;
- platform support;
- issue quality;
- release cadence;
- license;
- transitive dependency weight;
- native/platform requirements;
- migration history;
- API stability.

Do not equate popularity with suitability.

## Existing Dependency Review

Use:
```bash
bash scripts/yuna_dep_health.sh <project-dir>
```

Then classify:
- safe patch/minor;
- major migration;
- stale but acceptable;
- risky/unmaintained;
- removable/unneeded.

Do not auto-apply major upgrades.

## Package Replacement

Before replacing:
- identify why current package fails;
- compare migration cost;
- compare feature parity;
- measure blast radius;
- define rollback.

Do not replace a working package because another is trendier.

## Lockfile Discipline

Respect the actual lockfile.
Do not mix package managers/tooling conventions.

## Dependency Proposal

```text
📦 DEPENDENCY_PROPOSAL
NEED:
CURRENT_OPTION:
CANDIDATE:
WHY:
ALTERNATIVES:
MAINTENANCE:
PLATFORM_RISK:
MIGRATION_COST:
APPROVAL_REQUIRED:
```

## Escalate to Adam

Escalate:
- new meaningful dependency;
- package replacement;
- major-version upgrade;
- package requiring native config changes;
- licensing concerns;
- package with unclear maintenance/safety.
