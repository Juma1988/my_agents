---
name: yuna-developer-testing
description: >
  Yuna's focused developer-testing skill for meaningful new logic, state transitions, widgets, repositories, integrations, and regression tests. Use during implementation before independent Kira QA.
---

# Yuna Developer Testing

Yuna owns focused developer evidence.
Kira owns independent QA.

## Principle

Changed meaningful behavior requires changed evidence.

Do not maximize test count.
Protect behavior that is likely to break.

## Test Mapping

### Business Rule
Use unit tests.

### Bug Fix
Add a regression test that fails before the fix where practical.

### State / Controller
Test meaningful transitions:
- initial;
- loading;
- success;
- error;
- retry;
- cancellation/stale response if relevant.

### Repository / Data
Test:
- mapping;
- local/remote selection;
- cache policy;
- error translation;
- persistence behavior.

### Reusable Widget
Use widget tests when:
- interaction matters;
- states matter;
- regression risk is real.

Do not test Flutter framework behavior.

### Integration
Use integration tests when multiple real boundaries must work together.

## Arrange / Act / Assert

Keep tests readable.
Do not over-abstract test setup.

Repeated test setup is sometimes clearer than a shared fixture hiding dependencies.

## Regression Tests

A bug regression test should capture the actual failure mode, not just add arbitrary coverage.

Name tests by behavior.

Good:
`showsOfflineStateWhenRecipeLoadTimesOut`

Weak:
`testLoad1`

## Async Tests

Control:
- fake time when useful;
- streams/subscriptions;
- retries;
- cancellation;
- stale responses.

Avoid flaky sleeps.

## Failure Evidence

Never weaken assertions just to make tests pass.

Classify failures:
- product defect;
- test defect;
- environment/tooling;
- missing requirement.

## Confidence

If no automated test protects the path, say so.

Do not call a refactor "safe" solely because analyze/build passes.

## Minimal Verification Order

1. narrowest relevant test;
2. static analysis;
3. broader related tests;
4. app/smoke run only when behavior needs runtime verification.

## Output

```text
🧪 TEST_PLAN:
TESTS_ADDED:
COMMANDS:
RESULTS:
GAPS:
CONFIDENCE:
KIRA_SHOULD_VERIFY:
```
