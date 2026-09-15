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
- Drawer (categories, tiers, profiles)
- Design system (AppColors, dark theme, snackbar)
- Skip penalty, haptic ticks, semantics
- Error handling + retry

## What's Next

1. Onboarding screen
2. Sound/haptic toggle
3. Custom alarm sound
4. History screen

## File Structure

```
lib/
├── main.dart
├── theme/app_colors.dart
├── models/challenge_category.dart
├── models/challenge_segment.dart
├── data/category_colors.dart
├── data/task_loader.dart
├── screens/spin_screen.dart
├── screens/timer_screen.dart
├── widgets/category_card_wheel.dart
├── widgets/app_drawer.dart
├── widgets/spin_button.dart
├── widgets/wheel_pointer.dart
├── widgets/custom_snackbar.dart
└── widgets/custom_button_3d.dart
```

## Resume

1. `cd C:\src\project\risk_roulette`
2. `flutter pub get`
3. `flutter run`
