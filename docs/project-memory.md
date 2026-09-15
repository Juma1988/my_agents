# Risk Roulette — Project Memory

> Last updated: 2026-09-15

## What Is This

A couples' challenge roulette app built in Flutter. Two players take turns spinning a wheel of tasks across 7 categories and 3 intensity tiers. Points are earned for accepting, lost for skipping. Timed tasks get a full-screen countdown.

## Tech Stack

- **Flutter** (SDK ^3.13.1)
- **Hive** — local persistence (scores, settings, profiles)
- **google_fonts** — Inter font
- **flutter_animate** — animations
- **audioplayers** — declared but alarm uses SystemSound fallback

## Architecture

```
lib/
├── main.dart                    # App entry, Hive init
├── theme/app_colors.dart        # Color constants
├── models/
│   ├── challenge_category.dart  # Category + HeartState + tier logic
│   └── challenge_segment.dart   # Task (id, text, points, timer)
├── data/
│   ├── category_colors.dart     # Per-category color map
│   └── task_loader.dart         # Loads task.json with retry
├── screens/
│   ├── spin_screen.dart         # Main screen (wheel + players + bottom sheet)
│   └── timer_screen.dart        # Full-screen countdown
└── widgets/
    ├── category_card_wheel.dart # ListWheelScrollView card wheel
    ├── app_drawer.dart          # Right-side drawer (categories, tiers, profiles)
    ├── spin_button.dart         # 3D gold spin button
    ├── wheel_pointer.dart       # Triangle indicator
    └── custom_snackbar.dart     # Styled snackbar
    └── custom_button_3d.dart    # 3D push-button base widget
```

## Key Decisions

| Decision | Status |
|----------|--------|
| App name: Risk Roulette | Locked |
| No sharing feature | Locked |
| Session end: flexible, no fixed rounds | Locked |
| Dark-only theme (#1A1A2E) | Locked |
| 2-player mode with auto-switch | Locked |
| Skip penalty = task.points (same player rolls again) | Locked |
| Skip cooldown: 10 player rounds, skill reduces to 3 | Locked |
| Tier unlock: Soft (start), Kink (25 done), Entertainment (50 done) | Locked |
| Save for Later skill: max 3 saved, 2 tasks next turn, own cooldown | Locked |
| Session score: green/red delta, resets on full app close | Locked |
| Settings: hide completed tasks (Always Ask / Keep Favorite / Enable / Disable) | Locked |
| Sound design: tick-tick-tick + landing thud | Planned |
| Visual celebration: confetti on accept | Planned |

## Roadmap

See `docs/strategy/roadmap.md` for full phased plan (8 phases).

## Data

- `task.json` — 7 categories, 3 tiers each, 10-17 tasks per tier
- Categories: Domestic, Dirty Truth, Spicy Dare, Roleplay, Sensation, Wildcard, 2 Player
- Tiers: soft (1-3 pts), kink (4-5 pts), entertainment (6-8 pts)

## Persistence (Hive box: 'settings')

- `selectedCategoryIds` — List<String>
- `selectedTiers` — List<String>
- `current_player` — int (1 or 2)
- `player1_score`, `player2_score` — int
- `player1_nickname`, `player2_nickname` — String
- `player1_avatar`, `player2_avatar` — String (emoji)

## Known Risks

- `audioplayers` package is in pubspec but unused — alarm uses `SystemSound.play`
- No onboarding flow yet
- No history/log of completed tasks
- Sound/haptic toggle settings not persisted (hardcoded `true`)
