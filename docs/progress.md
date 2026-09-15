# Progress

> Last updated: 2026-09-15

## Current State

The core app is functional: spin wheel, task reveal, accept/skip, timer, 2-player scoring, persistence.

## What Works

- Spin wheel with task cards (ListWheelScrollView, 3D perspective)
- Task bottom sheet with accept/skip/timer
- Full-screen timer countdown with alarm + vibration
- 2-player system with scores, nicknames, avatars
- Drawer: category + tier selection, profile editing
- Hive persistence (survives restart)
- Error handling + retry for task loading

## What's Missing (Priority Order)

### HIGH
1. Onboarding intro screen (3-slide "How to Play")
2. Sound/haptic toggle in drawer (currently hardcoded on)
3. Custom alarm sound (`assets/sounds/alarm.mp3`)

### MEDIUM
4. History screen (past tasks)
5. Timer pause/resume
6. Better test coverage

### LOW
7. Shop system (spend points on items)
8. Skills system (unlockable abilities)

## Active Blockers

None.

## Next Action

Onboarding screen is the most impactful next step.
