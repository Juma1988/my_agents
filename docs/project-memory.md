# Risk Roulette — Project Memory

> Last updated: 2026-09-16

## What Is This

A couples' challenge roulette app built in Flutter. Two players take turns spinning a wheel of tasks across 7 categories and 3 intensity tiers. Points are earned for accepting, lost for skipping. Timed tasks get a full-screen countdown. Has a shop system, save-for-later mechanic, and 20 achievements.

## Tech Stack

- **Flutter** (SDK ^3.13.1)
- **Hive** — local persistence (scores, settings, profiles, history, shop, achievements)
- **google_fonts** — Inter font
- **flutter_animate** — animations
- **audioplayers** — declared but alarm uses SystemSound fallback

## Architecture

```
lib/
├── main.dart                    # App entry, Hive init, RestartWidget, isDebug flag
├── theme/app_colors.dart        # Color constants
├── models/
│   ├── challenge_category.dart  # Category + HeartState + tier logic
│   └── challenge_segment.dart   # Task (id, text, points, timerSeconds, hasTimer)
├── data/
│   ├── category_colors.dart     # Per-category color map
│   ├── task_loader.dart         # Loads task.json with retry
│   ├── sound_service.dart       # Sound engine (tick, celebration, whoosh, denied, double beep)
│   ├── history_service.dart     # History CRUD, favorites, max 200 entries
│   ├── progression_service.dart # Tier unlocks, totalCompleted, TierProgress
│   ├── shop_service.dart        # Coins, inventory, skills, cosmetics, purchase flow
│   └── achievement_service.dart # 20 achievements, unlock logic, Hive persistence
├── screens/
│   ├── spin_screen.dart         # Main game screen (wheel, players, skip/save/bookmark)
│   ├── timer_screen.dart        # Full-screen countdown (double beep at 30s, triple at 10s)
│   ├── onboarding_screen.dart   # 3-slide onboarding (first launch)
│   ├── history_screen.dart      # History with filters, favorites, delete
│   ├── settings_screen.dart     # Profiles, categories, tiers, progression summary
│   └── shop_screen.dart         # Shop with 4 tabs (Consumables/Skills/Power-ups/Cosmetics)
└── widgets/
    ├── category_card_wheel.dart # ListWheelScrollView, jumpToItem after animation
    ├── app_drawer.dart          # Right-side drawer (categories, tiers, achievements, nav)
    ├── spin_button.dart         # 3D gold spin button
    ├── wheel_pointer.dart       # Triangle indicator
    ├── custom_snackbar.dart     # Styled snackbar (auto-closes drawer)
    ├── custom_button_3d.dart    # 3D push-button base widget
    ├── confetti_overlay.dart    # Full-screen confetti on accept
    ├── dev_overlay.dart         # Always-visible restart + copy-path buttons (isDebug only)
    └── achievement_unlock_popup.dart  # Animated gold popup on achievement unlock
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
| Save for Later (Bookmark skill): max 3 saved, 5-round cooldown, own queue | Locked |
| Session score: green/red delta, resets on full app close | Locked |
| Sound: tick-tick-tick + celebration + whoosh + denied + double/triple beep | Done |
| Confetti on accept | Done |
| Coins = points (1:1 ratio), earned on accept | Done |
| Dev overlay: always visible restart + copy-path buttons (isDebug only) | Done |
| Achievements replace milestones (20 achievements, not 4 milestones) | Done |
| Milestone class still exists in progression_service.dart but unused by UI | Superseded |

## Roadmap

See `docs/strategy/roadmap.md` for full phased plan (8 phases).

### Completed Phases

- **Phase 1** — Core Polish: Onboarding, SoundService, ConfettiOverlay, session score delta
- **Phase 2** — History & Settings: HistoryScreen, SettingsScreen, HistoryService, Drawer nav, done tracking
- **Phase 3** — Skip Cooldown: 10-round cooldown per-player, persists in Hive, button shows countdown
- **Phase 4** — Sound & Vibration: Variable tick intensity, double/triple beeps, celebration haptic, task reveal whoosh
- **Phase 5** — Progression: Tier unlocking at 25/50 tasks, milestones (now replaced by achievements), progress bar in drawer
- **Phase 6** — Save for Later: Bookmark skill, save queue (max 3), 5-round cooldown, saved tasks sheet at turn start
- **Phase 7** — Shop System: ShopService, ShopScreen, coins, Quick Skip, Double Points, Task Shield, Bookmark, shop button in drawer, coin display

### Not Started

- **Phase 8** — Polish & Production: Final QA, dead-code removal, release prep

## Data

- `task.json` — 7 categories, 3 tiers each, 10-17 tasks per tier
- Categories: Domestic, Dirty Truth, Spicy Dare, Roleplay, Sensation, Wildcard, 2 Player
- Tiers: soft (1-3 pts), kink (4-5 pts), entertainment (6-8 pts)

## Persistence (Hive box: 'settings')

### Player Data
- `current_player` — int (1 or 2)
- `player1_score`, `player2_score` — int
- `player1_nickname`, `player2_nickname` — String
- `player1_avatar`, `player2_avatar` — String (emoji)
- `player1_skip_cooldown`, `player2_skip_cooldown` — int
- `player1_save_cooldown`, `player2_save_cooldown` — int
- `player1_saved_tasks`, `player2_saved_tasks` — List<Map> (serialized task data)

### Shop Data
- `player1_coins`, `player2_coins` — int
- `player1_inventory`, `player2_inventory` — List<String> (item IDs)
- `player1_skills`, `player2_skills` — List<String> (skill IDs)
- `player1_cosmetics`, `player2_cosmetics` — List<String> (cosmetic IDs)

### Achievement Data
- `player1_achievements`, `player2_achievements` — List<String> (achievement IDs)
- `player1_stat_*` — int (per-player stats: tasks_completed, skips, cat_soft, cat_kink, cat_entertainment, timed_completed, shields_used, accept_streak, double_points_used, bookmarks_used)
- `global_stat_total_purchases` — int

### Settings
- `selectedCategoryIds` — List<String>
- `selectedTiers` — List<String>

### History (separate Hive box: 'history')
- Max 200 entries, FIFO
- Each entry: taskId, categoryId, categoryName, categoryIcon, tier, taskText, points, accepted, player, playerName, timestamp
- Favorites stored separately

## Shop Items

### Consumables (one-time use)
| Item | Price | Effect |
|------|-------|--------|
| Extra Spin | 3 | Spin again without waiting |
| Double Points | 5 | Next task gives 2x points |
| Task Shield | 4 | One free skip with no cooldown |

### Skills (permanent)
| Item | Price | Effect |
|------|-------|--------|
| Quick Skip | 15 | Skip cooldown 10 → 3 rounds |
| Bookmark | 20 | Save task for later (max 3, 5-round cooldown) |
| Favorite | 10 | Mark tasks to always appear |

### Power-ups
| Item | Price | Effect |
|------|-------|--------|
| Forced Task | 8 | Opponent must do a specific category next spin |
| Tier Lock | 6 | Force opponent into a specific tier next spin |
| Score Steal | 10 | Steal 3 points from opponent |

### Cosmetics
| Item | Price | Effect |
|------|-------|--------|
| Custom Wheel | 5 | Custom wheel colors |
| Premium Avatars | 3 | Custom avatars beyond defaults |
| Spin Themes | 7 | Animated spin button themes |

## Achievements (20)

### Task Completion (6)
| ID | Name | Threshold |
|----|------|-----------|
| first_steps | First Steps | 1 task |
| getting_warmed_up | Getting Warmed Up | 5 tasks |
| on_a_roll | On a Roll | 10 tasks |
| half_century | Half Century | 25 tasks |
| century | Century | 50 tasks |
| legend | Legend | 100 tasks |

### Category Mastery (3)
| ID | Name | Threshold |
|----|------|-----------|
| soft_touch | Soft Touch | 5 soft tasks |
| kink_explorer | Kink Explorer | 5 kink tasks |
| entertainment_buff | Entertainment Buff | 5 entertainment tasks |

### Challenge Types (3)
| ID | Name | Threshold |
|----|------|-----------|
| speed_demon | Speed Demon | 5 timed tasks |
| brave_heart | Brave Heart | 10 skips |
| shield_bearer | Shield Bearer | 5 Task Shield uses |

### Streak & Pattern (2)
| ID | Name | Threshold |
|----|------|-----------|
| unstoppable | Unstoppable | 10 accepts in a row |
| double_down | Double Down | 5 Double Points uses |

### Shop (3)
| ID | Name | Threshold |
|----|------|-----------|
| shopper | Shopper | 5 shop purchases |
| skill_collector | Skill Collector | 3 skills owned |
| full_arsenal | Full Arsenal | All 3 skills owned |

### Social (2)
| ID | Name | Threshold |
|----|------|-----------|
| team_players | Team Players | Both players complete 10 each |
| perfect_game | Perfect Game | Both players complete 25 each |

### Special (1)
| ID | Name | Threshold |
|----|------|-----------|
| bookmark_master | Bookmark Master | 5 Bookmark saves |

## Known Risks

- `audioplayers` package is in pubspec but unused — alarm uses `SystemSound.play`
- `flutter_lints` is deprecated (not blocking)
- `isDebug = true` in main.dart — must set to false before production release
- Achievement popup uses `AnimatedBuilder` which may need testing on older Flutter versions

## Git

- Repo: `https://github.com/Juma1988/my_agents.git`
- Branch: `feature/task-cards-on-wheel`
- Latest commit: `9a8b93b` — Achievements system + restart button fix
