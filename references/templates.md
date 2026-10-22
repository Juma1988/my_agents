# Required Documentation Templates

Loaded when creating or reconciling project docs. EVE v1.4 · create `docs/README.md` and `docs/last-session.md` from these exactly.

## `docs/README.md` (documentation index)

```markdown
# Project Documentation

## Purpose
Durable project context maintained by Eve. It records decisions, progress, evidence, skills, and the next resumable checkpoint without duplicating source code or transient chat.

## Index
| Path | Purpose | Updated when |
|---|---|---|
| `project-memory.md` | Locked decisions and durable project facts | A decision or fact changes |
| `progress.md` | Current milestone and active work | Meaningful work checkpoint |
| `CHANGELOG.md` | User-visible completed changes | A change is completed |
| `skill-lock.md` | Project-local skill provenance and usefulness | A skill is installed or used |
| `last-session.md` | Resume-ready handoff | Checkpoints and `/gn` |
| `improvement_radar.md` | Scoped future improvements | A qualified idea is found |
| `qa/` | Test evidence and known risks | Verification work |
| `decisions/`, `strategy/`, `design/` | Detailed durable records | Applicable Focus work |

## Maintenance Rules
- Current-state files contain only current truth; superseded operational details are removed or summarized.
- Historical evidence stays in changelog, decisions, and QA records; never erase it merely to shorten a file.
- Avoid copying source code, tool transcripts, or transient conversation.
```

## `docs/last-session.md` (resume-ready handoff)

```markdown
# Last Session

## Current Goal
[One-sentence outcome being pursued]

## Mode and Progress
- Mode: Flash | Focus
- Progress: [0–100]%
- Active spotlight: [Eve or specialist]

## Open TODOs
- [ ] [Specific next task]

## Last Successful Checkpoint
- [What completed, revision/artifact if applicable, and key evidence]

## Pending Decisions / Blockers
- [Only choices or blockers requiring attention; write `None` when empty]

## Resume Instruction
[One concrete next action that restores productive work]

_Last reconciled: [ISO 8601 timestamp]_
```

## Doc lifecycle rules (owned by Eve)

| Mode | Behavior |
|---|---|
| Flash | Maintain `project-memory.md`, `progress.md`, `CHANGELOG.md`, `skill-lock.md` only when their facts change; refresh `last-session.md` at a meaningful checkpoint or before stopping |
| Focus | Maintain all applicable documentation: detailed decisions, design/strategy records, QA evidence, and the index |
| Any | Read-then-merge before updating; remove duplicate entries, completed TODOs, stale progress, resolved blockers, superseded operational notes |
| Durable history | Preserve locked decisions, changelog entries, revision/test evidence, explicit supersession; summarize or archive when necessary; never silently delete |
| Never store | Secrets, source-code dumps, raw specialist transcripts |
