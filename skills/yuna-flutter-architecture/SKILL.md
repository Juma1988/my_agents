---
name: yuna-flutter-architecture
description: >
  Yuna's Flutter architecture skill for feature structure, state ownership, dependency direction, services, repositories, navigation, persistence boundaries, API integration, and incremental architecture decisions. Use during implementation when new work risks tight coupling or unclear ownership.
---

# Yuna Flutter Architecture

Use this skill to keep Flutter feature work clean without over-architecting.

## Goal

Prefer the simplest structure that:
- keeps responsibilities clear;
- keeps state ownership obvious;
- makes important behavior testable;
- prevents UI, business logic, and data access from collapsing together;
- allows future changes without touching unrelated code.

Do not create layers just because they look professional.

## Decision Order

Before adding files or abstractions:

1. Define the behavior.
2. Define the state.
3. Decide who owns the state.
4. Decide where the business rule belongs.
5. Identify external boundaries.
6. Define how external data becomes app data.
7. Define which widgets consume the result.
8. Decide what needs independent tests.
9. Keep feature-private code private.
10. Share code only when multiple callers truly share a reason to change.

## Responsibility Boundaries

### Presentation
Owns:
- widgets and layout;
- interaction events;
- visual state rendering;
- navigation requests;
- presentation-only formatting.

Must not own:
- database queries;
- raw HTTP;
- persistence policy;
- long-lived business rules.

### Application / State
Owns:
- async coordination;
- state transitions;
- feature flow;
- loading/error/success state;
- calling repositories/services.

Avoid giant controllers that become feature dumping grounds.

### Domain / Business Rules
Use only when there is meaningful reusable business behavior.

Owns:
- calculations;
- policies;
- validation that should survive UI changes.

Do not create a domain layer for trivial CRUD.

### Data / Infrastructure
Owns:
- HTTP;
- storage/database;
- cache;
- DTOs/serialization;
- platform APIs;
- repository implementations.

Must not decide user-facing flow.

## Dependency Direction

Healthy:
```text
Widget
  ↓
State / Use Case
  ↓
Repository Contract
  ↓
Repository Implementation
  ↓
API / Database / Platform
```

Avoid:
```text
Widget → SQLite
Widget → HTTP
Repository → Widget
Business rule → Navigator
Service → BuildContext
```

## State Ownership

Use local widget state when it is purely visual and short-lived.

Use feature/application state when:
- multiple widgets depend on it;
- it coordinates async work;
- it represents a user flow;
- it must survive rebuilds.

Use app-global state only when the whole app genuinely depends on it.

Do not promote state globally "just in case."

## Single Source of Truth

For each important state value, identify one authoritative owner.

Avoid:
- widget + provider + cache all pretending to be authoritative;
- duplicate auth/session truth;
- UI state manually mirroring backend state without synchronization.

## Shared Code

Before moving code into `core`, `shared`, `common`, or `utils`, ask:
- Is it genuinely reused?
- Do callers share a reason to change?
- Is the API narrow?
- Is it independent of feature assumptions?

Avoid universal dumping grounds.

## Repositories

Use a repository only when it creates a real boundary.

Good uses:
- local + remote coordination;
- DTO → app-model mapping;
- cache policy;
- stable app-facing operations.

Avoid one-line pass-through chains that add ceremony without value.

## API / DTO / Models

Map external data when it protects the app from:
- naming differences;
- transport-only fields;
- unstable schemas;
- nullability mismatch;
- version changes.

Do not duplicate models without a reason.

## Async Boundaries

Define:
- duplicate-request behavior;
- stale-response behavior;
- cancellation;
- retry;
- lifecycle/disposal;
- loading ownership.

Avoid async work in widget `build`.

## Custom Widgets

Honor the project 3+ reuse rule.

Shared widgets should own presentation, not business rules or repositories.

Prefer composition and small semantic APIs.
Avoid mode-flag mega-widgets.

## Architecture Smells

Report:
- layer collapse;
- global-state creep;
- leaky external contracts;
- circular dependencies;
- shared-code dumping grounds;
- flag-driven abstractions;
- business behavior that cannot be tested without Flutter UI.

For every finding state:
- WHAT
- WHERE
- WHY
- SMALLEST correction
- SCOPE

## Refactor Strategy

Prefer:
1. one boundary;
2. one responsibility move;
3. update callers;
4. test/analyze;
5. continue only if useful.

Avoid "clean architecture rewrite."

## Adam Approval Required

Return to Adam before:
- replacing state management;
- introducing app-wide layers;
- changing storage strategy;
- major shared-code moves;
- major global state;
- major dependency additions;
- project-wide reorganization;
- widespread code generation.

Small reversible internal choices remain Yuna's authority.

## Output

```text
ARCHITECTURE_STATUS: GOOD | NEEDS_ADJUSTMENT | BLOCKED
CURRENT_FLOW:
TARGET_FLOW:
RESPONSIBILITY_MAP:
SMALLEST_NEXT_SLICE:
RISKS:
ADAM_DECISION_NEEDED:
IMPROVEMENT_RADAR:
```
