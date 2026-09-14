# Risk Roulette — Follow Up

> Last updated: 2026-09-14
> Branch: `feature/task-cards-on-wheel`
> Commit: `b421b58`

---

## What's Done ✅

### Screen 1: The Spin
- ListWheelScrollView wheel with 3D perspective
- Task cards showing actual task text (not category icons)
- Premium card design: left color accent bar, vertical category section, gradient background
- Category section takes 1/4 of card width (icon + name + divider)
- Cards are NOT clickable (view only)
- Task pool is shuffled randomly (no same-category grouping)
- Empty state: "Select categories to play" when no categories selected
- Error handling: retry button if task.json fails to load

### Player System
- 2-player mode with separate scores, nicknames, avatars
- Player toggle bar at top: `😈 Player 1  VS  👿 Player 2  ☰`
- Menu button on right side of player bar
- Scores persist in Hive (survive app restart)
- Auto-switches to other player after accepting a task

### Skip/Accept Logic
- **Accept:** +task.points, toggle player, green "+X" floating animation
- **Skip:** -task.points (same as reward), same player rolls again, red "-X" floating animation
- Skip button shows dynamic penalty: "Skip (-3 pts)"

### Timer Screen (Screen 2)
- Full-screen countdown with circular progress ring
- Color transitions: accent → orange (30s) → red (10s)
- Large timer text (48px)
- "Time's Up!" overlay with pulse animation
- Alarm sound (SystemSound fallback) + vibration loop
- "Done!" button awards points + toggles player
- "Cancel" button exits without points
- Back button blocked during countdown (PopScope)

### Drawer (Right Side)
- **Categories:** Vertical list with icon + short name + checkmark
- **Tier:** Vertical list with "Select one or more" hint, multi-select
- **Profiles:** Player 1 & Player 2 with avatar + nickname editor
- Custom snackbar at bottom

### Design System
- Dark-only theme (#1A1A2E background)
- AppColors constants class (`lib/theme/app_colors.dart`)
- Custom snackbar widget (`lib/widgets/custom_snackbar.dart`)
- Inter font throughout
- Category-specific colors (from `category_colors.dart`)

### Tasks
- 7 categories: domestic, dirty_truth, spicy_dare, roleplay, sensation, wildcard, two_player
- 3 tiers per category: soft, kink, entertainment
- 12-15 tasks per tier
- New tasks added: "Clean house in thong/heels", "Partner picks outfit", "Write 'I belong to you' in lipstick", "Dance seductively", "Foot massage 5min", "Butt plug 1 hour"

### Other
- Haptic ticks during spin (one per card pass)
- Semantics on main interactive elements
- Hive persistence for scores, nicknames, avatars, selected categories, tiers

---

## What's Remaining 📋

### HIGH Priority
1. **Onboarding intro screen** — 3-slide "How to Play" before first spin
2. **Shop system** — Spend points on items (skip cards, bonus rolls, themes)
3. **Skills system** — Unlockable abilities earned through milestones

### MEDIUM Priority
4. **History screen** — View past completed/skipped tasks
5. **Sound effects toggle** — Currently removed from drawer, needs to be re-added properly
6. **Haptic feedback toggle** — Same as above

### LOW Priority
7. **Custom alarm sound** — Add `assets/sounds/alarm.mp3` for richer alarm
8. **Pause/resume timer** — For tasks where timer can be stopped temporarily
9. **Timer history** — Log completed/cancelled timers to Hive

---

## File Structure

```
lib/
├── main.dart                    # App entry, Hive init
├── theme/
│   └── app_colors.dart          # AppColors constants
├── models/
│   ├── challenge_category.dart  # Category model + HeartState
│   └── challenge_segment.dart   # Task model (id, text, points, timerSeconds)
├── data/
│   ├── category_colors.dart     # CategoryColors class
│   └── task_loader.dart         # Loads task.json with retry
├── screens/
│   ├── spin_screen.dart         # Main screen (wheel + players)
│   └── timer_screen.dart        # Countdown timer screen
├── widgets/
│   ├── category_card_wheel.dart # Wheel + TaskCard widget
│   ├── category_chip_selector.dart # TierChipSelector
│   ├── app_drawer.dart          # Right-side drawer
│   ├── custom_snackbar.dart     # AppSnackBar widget
│   ├── spin_button.dart         # CustomButton3D spin button
│   ├── score_bar.dart           # (unused, kept for reference)
│   └── wheel_pointer.dart       # Arrow pointer
task.json                        # All tasks (7 categories × 3 tiers)
memories.md                      # Future features (shop, skills)
```

---

## Git Log

```
b421b58 Batch 1+2+3: Rename, AppColors, Hive fix, Skip penalty, Haptic ticks, Timer screen, Semantics
2613fe9 Move menu button to right side of player bar
1a04c9f Move menu button into player toggle bar, no overlap
fb3ba34 2-player system, settings, new tasks, profile editor
84d8e07 Categories as vertical list with descriptions
cc41956 Category descriptions in drawer, remove tier descriptions
35d1c0e Custom snackbar widget + tier descriptions
40629f4 Restore menu button top-right for drawer
96ce345 Change tier selector to vertical list with checkmarks
90805f3 Add 400ms delay before bottom sheet pops up after spin
c164c73 Card refinements: points badge, taller card, category bg, center emphasis
725d8bf Wider category section (1/4), wrap task text
0504199 Card: vertical category section, remove clickability, shuffle task pool
d5c42c2 Redesign TaskCard with premium Row-based layout and left color accent bar
```

---

## How to Resume Tomorrow

1. Open project: `C:\src\project\handicap`
2. Branch is `feature/task-cards-on-wheel`
3. Run `flutter pub get` to install audioplayers
4. Run `flutter run` to launch on emulator
5. Start with onboarding screen (Fix #1 from audit)

---

## Notes

- App was renamed from "Handicap" to "Risk Roulette"
- Shop/skills system is planned but not started — see `memories.md`
- No sharing feature (user decision)
- Session end is flexible — no fixed rounds
- User plays with wife — keep it fun and casual
