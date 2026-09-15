# Risk Roulette — Memory

> Last updated: 2026-09-15
> Branch: `feature/task-cards-on-wheel`

## Project

- Couples' challenge roulette app (Flutter)
- 2 players, 7 categories, 3 tiers
- Dark theme, Hive persistence, haptic feedback

## What's Done

- Spin wheel (ListWheelScrollView, task cards, 3D perspective)
- Timer screen (countdown, circular progress, alarm, vibration)
- 2-player system (scores, nicknames, avatars, auto-switch)
- Drawer (categories, tiers, profiles, history, settings)
- Design system (AppColors, dark theme, snackbar)
- Skip penalty, haptic ticks, semantics
- Error handling + retry
- Onboarding (3-slide, first launch)
- SoundService (centralized haptic/audio)
- ConfettiOverlay (burst on accept)
- Session score delta (green/red)
- History screen (filters, favorites, FIFO 200)
- Settings page (hide completed, toggles, reset, clear)
- Done tracking (records all accept/skip events)

## What's Next

Phase 3: Skip Cooldown System

## AI Workflow Rules

### After Every Phase
1. `flutter analyze` — 0 warnings/errors
2. `flutter test` — all tests pass
3. `flutter run` — launch on emulator, verify visually
4. Commit with descriptive message
5. Update docs (progress.md, CHANGELOG.md)

### Task Breakdown + Progress Updates
- Use TodoWrite tool for EVERY multi-step task
- Before starting: create todo list
- While working: update status in real-time
- User should ALWAYS see the todo list updating

## File Structure

```
lib/
├── main.dart
├── theme/app_colors.dart
├── models/
│   ├── challenge_category.dart
│   └── challenge_segment.dart
├── data/
│   ├── category_colors.dart
│   ├── task_loader.dart
│   ├── sound_service.dart
│   └── history_service.dart
├── screens/
│   ├── spin_screen.dart
│   ├── timer_screen.dart
│   ├── onboarding_screen.dart
│   ├── history_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── category_card_wheel.dart
    ├── app_drawer.dart
    ├── spin_button.dart
    ├── wheel_pointer.dart
    ├── confetti_overlay.dart
    ├── custom_snackbar.dart
    └── custom_button_3d.dart
```

## Resume

1. `cd C:\src\project\risk_roulette`
2. `flutter pub get`
3. `flutter run -d emulator-5554`
