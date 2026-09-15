# Changelog

All notable changes to Risk Roulette.

## 2026-09-15

### Added
- Onboarding screen (3-slide, first launch only)
- SoundService: centralized haptic/audio (wheel tick, landing thud, accept, skip, timer)
- ConfettiOverlay: 80-particle burst on task accept
- Session score delta (green/red ±delta in player bar)
- History screen: list with filters (All/Accepted/Skipped), category chips, favorites
- Settings page: hide completed dropdown, haptic/sound toggles, reset scores, clear history
- History tracking: records all accept/skip events (FIFO 200)
- Drawer navigation: History + Settings buttons at bottom

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
