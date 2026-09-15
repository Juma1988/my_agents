---
name: yuna-flutter-performance
description: >
  Yuna's Flutter performance skill for jank, rebuilds, startup, scrolling, memory, async work, image handling, lists, caching, and unnecessary work. Use when performance matters or when implementation touches a hot path.
---

# Yuna Flutter Performance

Optimize for user-visible impact, not benchmark vanity.

## Rule

Do not optimize because code "looks slow."
Identify:
- hot path;
- measurable symptom;
- likely cause;
- smallest fix.

## Rebuilds

Watch for:
- large widget subtrees rebuilding for tiny state changes;
- providers/listeners scoped too broadly;
- expensive derived values recomputed every build;
- unstable keys;
- unnecessary parent state ownership.

Prefer:
- narrow listeners;
- local state where appropriate;
- memoized/derived state only where it pays;
- const widgets when naturally applicable.

Do not cargo-cult `const` everywhere as a performance strategy.

## Lists

For long/dynamic lists:
- use lazy builders;
- paginate when datasets can grow;
- avoid building full hidden lists;
- keep item widgets lightweight;
- avoid expensive work per row.

## Images

Consider:
- target display size;
- caching;
- decoding cost;
- oversized assets;
- repeated remote fetches;
- placeholders/error states.

Do not decode giant images for tiny thumbnails.

## Async Work

Avoid:
- blocking main isolate with heavy CPU work;
- repeated requests on rebuild;
- duplicate simultaneous fetches;
- stale responses overwriting newer state.

Consider isolates only for genuinely heavy CPU work.

## Startup

Be careful with:
- eager initialization;
- synchronous disk/network work before first frame;
- loading services not needed immediately;
- heavy dependency setup.

Prefer progressive initialization when safe.

## State Management

Performance problems often come from ownership/scope, not the library itself.

Check:
- what changed;
- who listened;
- how much rebuilt;
- whether derived state can be narrower.

Do not recommend a state-management migration for one rebuild problem.

## Caching

Cache only with a clear invalidation story.

Define:
- authoritative source;
- freshness;
- eviction;
- offline behavior;
- refresh trigger.

A cache without invalidation is a delayed bug.

## Database / API

Watch for:
- N+1 requests/queries;
- unpaginated large loads;
- repeated transformations;
- fetching data already available locally;
- serial work that can safely be parallelized.

## Performance Finding

```text
⚡ PERFORMANCE
SYMPTOM:
HOT_PATH:
CAUSE:
SMALLEST_FIX:
EXPECTED_IMPACT:
MEASURE:
SCOPE:
```

## Escalate

Return to Adam before:
- replacing major libraries;
- introducing complex caching infrastructure;
- background services;
- isolate-heavy architecture;
- large data-layer redesign.
