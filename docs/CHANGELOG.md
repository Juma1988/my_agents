# Changelog

All notable changes to Risk Roulette.

## 2026-09-16

### Added
- **Phase 6:** Save for Later (Bookmark skill) — save tasks to queue (max 3), 5-round cooldown, saved tasks sheet at turn start
- **Phase 7:** Shop system — ShopService, ShopScreen with 4 tabs, coins (1:1 with points), Quick Skip, Double Points, Task Shield, Bookmark skill, shop button in drawer, coin display in player bar
- **Achievements:** 20 achievements replacing milestones — completion, category mastery, challenge types, streak, shop, social, special
- **AchievementUnlockPopup:** Animated gold notification overlay on unlock
- **Dev overlay:** Always-visible restart + copy-file-path buttons (isDebug only)

### Changed
- Drawer: milestones replaced with achievements grid
- Settings: progression summary shows achievement count instead of milestones
- Restart button: changed from long-press to tap (was too hard to trigger)

### Fixed
- Shop service and shop screen files were not committed (now included)

## 2026-09-15

### Added
- **Phase 1:** Onboarding, SoundService, ConfettiOverlay, session score delta
- **Phase 2:** History screen, Settings page, done tracking, drawer navigation
- **Phase 3:** Skip cooldown system (10 rounds per-player, persists in Hive)
- **Phase 4:** Enhanced sound engine (variable tick intensity, double/triple beeps, celebration haptic, task reveal whoosh)
- **Phase 5:** Progression system (tier unlocking at 25/50 tasks, milestones at 10/25/50/100, progress bar in drawer)

### Fixed
- Removed 4 dead-code widgets: `score_bar`, `result_card`, `card_stack`, `category_chip_selector`
- Set `isDebug = false` in main.dart
- Fixed smoke test (Hive initialization)

## 2026-09-14

### Added
- Screen 1 (The Spin): ListWheelScrollView card wheel with 3D perspective
- Screen 2 (Timer): Full-screen countdown with circular progress, alarm, color transitions
- 2-Player system: Separate scores, nicknames, avatars, auto-switch after accept
- Drawer: Category selection, tier multi-select, player profiles
- Design system: AppColors constants, dark-only theme, custom snackbar
- Skip penalty: -points, same player rolls again
- Haptic ticks during spin
- Semantics on interactive elements
- Hive persistence for scores, settings, profiles
- Error handling with retry for task.json loading
- Empty state when no categories selected

### Changed
- Renamed from "Handicap" to "Risk Roulette"
- Menu button moved to right side of player bar
- Categories as vertical list in drawer (replaced grid)
- Tier selector changed to vertical list with checkmarks

## Earlier

- Initial Flutter project scaffold
- Category descriptions added then removed
- Custom snackbar widget created
- Card design iterations (Row-based layout, accent bar, category section)
