# Risk Roulette

A couples' challenge roulette app built with Flutter.

## How It Works

1. **Spin** — Tap the gold button to spin the wheel of tasks
2. **Reveal** — A task appears with its category, points, and optional timer
3. **Accept or Skip** — Accept to earn points (and switch player), skip to lose points (and roll again)
4. **Timer** — Timed tasks open a full-screen countdown with alarm
5. **Score** — Players take turns; scores persist between sessions

## Categories

| Icon | Name | Description |
|------|------|-------------|
| 🏠 | Domestic | Home chores with a twist |
| 💬 | Dirty Truth | Confession questions |
| 🔥 | Spicy Dare | Action challenges |
| 🎭 | Roleplay | Scenario prompts |
| 👅 | Sensation | Touch/sensory tasks |
| 🌀 | Wildcard | Mixed wildcards |
| 👫 | 2 Player | Both players together |

Each category has 3 tiers: **Soft** (easy), **Kink** (medium), **Entertainment** (intense).

## Getting Started

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # Entry point, Hive init
├── theme/app_colors.dart        # Color constants
├── models/                      # Data models
├── data/                        # Task loader, category colors
├── screens/                     # SpinScreen, TimerScreen
└── widgets/                     # Wheel, drawer, buttons, snackbar
```

## Docs

Full project documentation lives in `docs/`:
- `docs/project-memory.md` — Architecture, decisions, persistence
- `docs/CHANGELOG.md` — Version history
- `docs/progress.md` — Current status and next steps
