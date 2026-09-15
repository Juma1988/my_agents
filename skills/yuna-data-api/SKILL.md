---
name: yuna-data-api
description: >
  Yuna's data and API integration skill for repositories, remote/local sources, DTO mapping, caching, pagination, retries, idempotency, persistence, migrations, and sync behavior. Use whenever implementation touches network or storage boundaries.
---

# Yuna Data & API

Use this skill whenever a task crosses network or persistence boundaries.

## Contract First

Define:
- request/input;
- response/output;
- error cases;
- auth requirements;
- retry behavior;
- idempotency;
- pagination;
- offline behavior;
- caching;
- persistence expectations.

## API Integration

Keep raw transport concerns below presentation.

Separate:
- transport status;
- developer diagnostics;
- app/domain failure;
- user-facing message.

Do not leak raw HTTP exceptions into widgets.

## DTO Mapping

Map external payloads when it protects the app from unstable/awkward contracts.

Avoid mapping ceremony when external and app models are genuinely identical and stable.

## Repositories

Use repositories to create real boundaries:
- local + remote coordination;
- cache policy;
- data transformation;
- stable app-facing operations.

Avoid pass-through repository/service stacks with no value.

## Pagination

Define:
- page/cursor ownership;
- deduplication;
- end-of-list;
- refresh interaction;
- error/retry;
- stale page behavior.

Do not mix pagination state into arbitrary widgets.

## Retries

Retry only when the operation is safe.

Be careful with:
- writes;
- payments;
- destructive calls;
- non-idempotent operations.

Define idempotency before automatic retry.

## Caching

For every cache define:
- source of truth;
- freshness;
- invalidation;
- refresh trigger;
- offline behavior.

Do not add a cache without an invalidation story.

## Persistence

Keep storage-engine details out of presentation.

For migrations:
- define old schema;
- new schema;
- migration path;
- rollback/recovery;
- test data preservation;
- failure behavior.

Medium/Large migrations require Adam visibility.

## Sync / Offline

If data can change locally and remotely, define:
- authority;
- conflict detection;
- conflict resolution;
- queueing;
- retry;
- duplicate prevention;
- clock/version strategy;
- user-visible conflict behavior.

Do not call something "offline-first" without a real sync model.

## Data Integrity

Validate assumptions at boundaries.

Avoid:
- duplicate records;
- silent partial writes;
- client-generated truth for server-owned rules;
- nullable fields with undefined semantics.

## Output

```text
DATA_FLOW:
SOURCE_OF_TRUTH:
CACHE:
OFFLINE:
ERROR_MODEL:
PAGINATION:
MIGRATION:
RISKS:
ADAM_DECISION_NEEDED:
```
