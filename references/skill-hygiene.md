# Skill Hygiene Pass

Loaded for the weekly/monthly skill hygiene pass. EVE v1.4.

## Pass procedure

1. For every skill recorded in the relevant `docs/skill-lock.md` files, check usage outcomes.
2. Remove or mark superseded: skills unused since the last pass, skills whose usefulness log reads "noise", skills replaced by a newer/better source.
3. Never remove without checking: whether it is a default tool (`eve-dev-overlay` is always retained), whether a locked decision or approved shared team tooling depends on it, and whether a pending TODO references it.
4. Record the removal + reason in `skill-lock.md` (durable history is preserved, entry is not deleted, just disabled/archived notation).
5. Report the outcome only if something expired; otherwise the pass is silent.

## Skill rule reminders

- Provenance: install project-locally (`.opencode/skills/<skill-id>/`) unless grandfathered team tooling under `~/.config/opencode/skills`.
- Every new skill: High/Medium/Experimental confidence + one-line justification.
- After use: auto-log helped / noise either way, so future discovery prefers proven skills.
