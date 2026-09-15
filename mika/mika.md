# Risk Roulette — Mika (Brainstorming & Design)

> Last updated: 2026-09-15

---

## Screen 1: The Spin — Design Spec

### Overview
The home screen. The "pull the lever" moment. The user lands here, sees the wheel, feels the urge, and taps SPIN.

### Visual Layout

```
┌─────────────────────────────────┐
│  SCORE: 42 pts        [≡ menu] │  ← ScoreBar
│                                 │
│          ╔═══════════╗          │
│         ╱  TASK +     ╲         │
│        ╱  HANDICAP     ╲        │
│       ╱   SEGMENTS      ╲       │  ← Wheel (60% screen height)
│      ╱   (text on each   ╲      │
│     ╱     colored slice)   ╲     │
│    ╱                         ╲   │
│   ╲                         ╱   │
│    ╲                       ╱    │
│     ╲                     ╱     │
│      ╲                   ╱      │
│       ╲                 ╱       │
│        ╲               ╱        │
│         ╲─────────────╱         │
│               ▼                 │  ← Pointer (fixed triangle)
│     ┌───────────────────┐       │
│     │    ✦  S P I N  ✦  │       │  ← Spin Button
│     └───────────────────┘       │
└─────────────────────────────────┘
```

### Color Philosophy

- **Background:** Deep charcoal `#1A1A2E` — not pure black, slightly warm. Feels premium, not depressing.
- **Wheel Segments:** Alternating neon-adjacent colors for max contrast:
  - `#FF6B6B` (coral red)
  - `#4ECDC4` (teal)
  - `#FFE66D` (electric yellow)
  - `#A855F7` (vivid purple)
  - `#FF8C42` (burnt orange)
  - `#45B7D1` (sky blue)
- **Segment Text:** White `#FFFFFF` with subtle shadow for readability on bright colors.
- **Spin Button:** Gold gradient `#FFD700` → `#FFA500` with a subtle pulsing glow animation.
- **Pointer:** White triangle with a small drop shadow, fixed at the 6 o'clock position.

### Widget Hierarchy

```
Scaffold (dark bg)
└── SafeArea
    └── Stack
        ├── Column (main content)
        │   ├── ScoreBar (row: score left, menu icon right)
        │   ├── Spacer
        │   ├── WheelWidget (centered, ~300-350px diameter)
        │   │   └── CustomPaint (draws wheel + text)
        │   ├── SizedBox (gap)
        │   ├── SpinButton (pulsing gold, disabled during spin)
        │   └── Spacer
        │
        └── Positioned (centered over wheel bottom)
            └── Pointer (triangle indicator)
```

### The Wheel — Technical Details

**Drawing (CustomPainter)**
- 8 segments (good visual density, readable text)
- Each segment: arc slice with task+handicap text curved along the arc OR straight text rotated to segment center
- Text approach: **rotated straight text** — simpler to implement, more readable on mobile than curved text

**Spin Animation**
- **Engine:** `AnimationController` with `CurvedAnimation(curve: Curves.easeOutExpo)`
- **Duration:** 3–4 seconds
- **Total rotation:** Random between 3–6 full rotations + offset to land on target segment
- **Deceleration:** `easeOutExpo` gives a natural "wheel slowing down" feel
- **Sound sync (optional):** Tick sound at each segment boundary during deceleration phase

**Target Selection**
- Pre-select random target BEFORE animation starts
- Calculate final rotation angle to land on that segment
- Pointer is at 6 o'clock — final angle = `(segmentIndex * segmentAngle) + offset`

### Spin Button Behavior

| State | Appearance | Behavior |
|-------|-----------|----------|
| **Ready** | Gold gradient, pulsing glow, "SPIN" text | Tappable. Starts spin. |
| **Spinning** | Grayed out, "Spinning..." text | Disabled. No interaction. |
| **Result** | Hidden / morphs into result card | Transition to result reveal. |

### Interaction Flow (Screen 1 → Screen 2)

1. User lands on screen. Sees wheel, score, glowing SPIN button.
2. User taps SPIN → Button disable + text change, Wheel begins rotation animation, Haptic feedback
3. Wheel spins for 3–4 seconds, decelerates naturally.
4. Wheel stops. Brief pause (0.5s) — tension moment.
5. Result reveal: card/modal slides up, shows Task name + Handicap name, two buttons: "Accept Challenge" or "Skip (−1 pt)"
6. On "Accept Challenge": Navigate to Screen 2 (The Challenge)

### Micro-Interactions & Polish

- **Wheel glow:** Subtle animated ring around the wheel that pulses when idle, intensifies during spin
- **Segment highlight:** When wheel stops, the winning segment gets a brief brightness flash
- **Score counter:** Animated number roll when score changes
- **Background particles:** Very subtle floating dots/stars — adds depth without distraction

---

## Card Stack v2 — Layout Spec

### Card Positioning (Vertical Stack)

```
        ┌───────────┐
       ╱  card -2   ╲  ← back farther (smallest, most transparent)
      ╱   (above)    ╲
     ┌───────────┐
    ╱   card -1   ╲   ← back far (smaller, transparent)
   ╱    (above)    ╲
  ┌───────────────┐
 │    card 0      │  ← CENTER / SELECTED (full size, full opacity)
 │   (focused)    │
  └───────────────┘
   ╲    (below)    ╱
    ╲   card 1    ╱   ← front far (smaller, transparent)
     └───────────┘
      ╲   (below) ╱
       ╲ card 2  ╱    ← front farther (smallest, most transparent)
        └───────┘
```

### Transform Rules

| Position | Scale | Opacity | Y Offset | Z Rotation |
|----------|-------|---------|----------|------------|
| -2 | 0.7 | 0.4 | -80px | -4deg |
| -1 | 0.85 | 0.7 | -40px | -2deg |
| 0 | 1.0 | 1.0 | 0px | 0deg |
| 1 | 0.85 | 0.7 | +40px | +2deg |
| 2 | 0.7 | 0.4 | +80px | +4deg |

### Spin Behavior
- Cards cycle upward: card 0 moves to position -2, card 1 moves to 0, etc.
- New card enters from bottom (position 2)
- Rapid cycling → deceleration → land on target
- Target card always ends at position 0 (center)

---

## Card Stack Spin v2 — Design Spec

### Concept
Vertical card stack that spins like a 3D Rolodex. User selects MULTIPLE categories at the top. Spin picks a random task from the combined pool of all selected categories.

### New Flow

1. **Top bar:** Multi-select category chips (tap to toggle)
2. **Center:** Card stack with all categories
3. **Spin:** Cycles through cards rapidly, decelerates
4. **Lands on:** The card (category) the task belongs to
5. **Task picked:** Random task from that category's selected tier
6. **Result card:** Shows category + task + points + timer

### Top Bar — Multi-Select Chips

```
┌─────────────────────────────────────────────┐
│  🏠  🔥  💬  🎭  👅  🌀                    │
│  [✓] [✓] [ ] [✓] [ ] [ ]                   │
│  Dom Dare Tru Rol Sen Wil                    │
└─────────────────────────────────────────────┘
```

- Horizontal row of category chips
- Each chip: icon + short name
- Tap to select/deselect (toggle)
- Selected: full color, checkmark
- Deselected: grayed out
- At least ONE must stay selected (can't deselect all)
- Chip colors match category colors

### Card Stack — Visual
- Shows ALL categories (not just selected)
- Selected cards: full color, prominent
- Deselected cards: grayscale, pushed to back, smaller
- Front card always a selected category during spin

### Spin Logic
1. Build task pool from ALL selected categories + selected tier
2. Pick random task from pool
3. Determine which category that task belongs to
4. Spin card stack to land on that category's card
5. Show result

### Anti-Abuse Update
- If only 1 category selected → all tasks from that category
- If all 6 selected → full pool (original behavior)
- No need for weighted slices anymore — selection IS the weighting

### Widget Changes

**Remove:**
- Weighted wheel slices
- Heart toggle (replaced by chip selector)
- Settings dialog (replaced by top bar chips)

**Add:**
- CategoryChipSelector widget (top bar)
- CardStack widget (replaces RouletteWheel)
- CardStackPainter or CardStackWidget (3D perspective cards)

**Keep:**
- Result card (with countdown timer)
- Score bar
- Spin button
- Hive persistence (save selected categories)

---

## Plan A v2: Screen 1 — Implementation Plan

### Key Changes from v1

1. Wheel segments = CATEGORY ICONS (not text)
2. Weighted slices — number of slices per category = its value (1-3)
3. Slices spread randomly — no two same-category slices adjacent
4. 4-state heart toggle — 🤍(1) → ❤️(2) → 🔥(3) → 💔(0) → 🤍(1)
5. Anti-abuse rule — if all categories equal value, reset all to 1
6. Tier selection — user picks soft/kink/entertainment per category
7. Long-press dialog — category settings with heart toggle + tier checkboxes

### Step 1: Data Models

Update `lib/models/challenge_segment.dart`:
```dart
class ChallengeSegment {
  final String id;
  final String text;
  final int points;
  final int? timerSeconds;

  const ChallengeSegment({
    required this.id,
    required this.text,
    required this.points,
    this.timerSeconds,
  });
}
```

Create `lib/models/challenge_category.dart`:
```dart
enum HeartState { off, liked, loved, disabled }

class ChallengeCategory {
  final String id;
  final String name;
  final String icon;
  final List<ChallengeSegment> soft;
  final List<ChallengeSegment> kink;
  final List<ChallengeSegment> entertainment;
  HeartState heartState;

  ChallengeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.soft,
    required this.kink,
    required this.entertainment,
    this.heartState = HeartState.off,
  });

  int get value {
    switch (heartState) {
      case HeartState.off: return 1;
      case HeartState.liked: return 2;
      case HeartState.loved: return 3;
      case HeartState.disabled: return 0;
    }
  }

  bool get isEnabled => heartState != HeartState.disabled;

  void cycleHeart() {
    switch (heartState) {
      case HeartState.off: heartState = HeartState.liked; break;
      case HeartState.liked: heartState = HeartState.loved; break;
      case HeartState.loved: heartState = HeartState.disabled; break;
      case HeartState.disabled: heartState = HeartState.off; break;
    }
  }
}
```

### Step 2: Load task.json

Create `lib/data/task_loader.dart`:
- Load `assets/task.json` using `rootBundle`
- Parse JSON into `List<ChallengeCategory>`
- Handle version field
- Each category has id, name, icon, soft[], kink[], entertainment[]

Add to pubspec.yaml:
```yaml
flutter:
  assets:
    - task.json
```

### Step 3: Wheel Slice Builder

Create `lib/data/wheel_builder.dart`:
```dart
List<WheelSlice> buildWheelSlices(List<ChallengeCategory> categories) {
  // 1. Collect all enabled categories with their values
  // 2. For each category, add `value` number of WheelSlice entries
  // 3. Shuffle the list
  // 4. Verify no two adjacent slices are same category
  // 5. If adjacent, re-shuffle (max 10 attempts, then accept)
  // 6. Return final list
}

class WheelSlice {
  final String categoryId;
  final String icon;
  final String color;
}
```

Anti-abuse check:
```dart
bool allSameValue(List<ChallengeCategory> categories) {
  final values = categories.where((c) => c.isEnabled).map((c) => c.value).toSet();
  return values.length <= 1;
}
// If true → reset all to HeartState.off, show snackbar
```

### Step 4: Category Colors

| Category | Color | Hex |
|----------|-------|-----|
| 🏠 Domestic | Coral Red | #FF6B6B |
| 💬 Dirty Truth | Sky Blue | #45B7D1 |
| 🔥 Spicy Dare | Burnt Orange | #FF8C42 |
| 🎭 Roleplay | Vivid Purple | #A855F7 |
| 👅 Sensation | Electric Yellow | #FFE66D |
| 🌀 Wildcard | Teal | #4ECDC4 |

### Step 5: Update RouletteWheelPainter

- Colored arc segments (equal angle, based on total slice count)
- Category icon (emoji) centered in each segment
- White border between segments
- Use `TextPainter` with the emoji character as text
- Font size ~20-24px for readability on spinning wheel
- Center icon in segment using `Canvas.save()` + `Canvas.rotate()` + `Canvas.translate()`

### Step 6: Update RouletteWheel

- Accept `List<WheelSlice>` and `List<ChallengeCategory>`
- Spin selects a random slice from the wheel
- On complete: find the category for that slice, pick random task from selected tier
- Callback: `onSpinComplete(ChallengeCategory category, ChallengeSegment task)`

### Step 7: Settings Dialog (Long-Press)

**Trigger:** Long-press on wheel

**Layout:**
- Title: "CHALLENGE SETTINGS"
- For each category (6 rows): Category icon, Heart toggle, Chance percentage, Tier checkboxes
- Bottom: Cancel + Save buttons
- If all same value after change → show snackbar, reset to off

### Step 8: Update SpinScreen

**New state:**
- `List<ChallengeCategory> _categories` — loaded from task.json
- `String _selectedTier` — 'soft', 'kink', or 'entertainment'
- `List<WheelSlice> _wheelSlices` — rebuilt when categories change

**New interactions:**
- Long-press on wheel → open settings dialog
- Dialog save → rebuild wheel slices → update UI
- Spin result → show task from selected tier of landed category

### Step 9: Result Card Update

- Show category icon + name
- Show task text, points, timer if applicable
- Accept + Skip buttons

### Step 10: Wire & Test

- [ ] task.json loads correctly
- [ ] 6 categories render with correct icons and colors
- [ ] Heart toggle cycles through all 4 states
- [ ] Wheel slices rebuild correctly (value = slice count)
- [ ] No adjacent same-category slices
- [ ] Anti-abuse reset works when all values equal
- [ ] Long-press opens settings dialog
- [ ] Tier selection filters tasks correctly
- [ ] Spin lands on category, reveals task from correct tier
- [ ] 60fps animation on wheel spin
- [ ] Works on iOS and Android

### Acceptance Criteria

1. App launches → wheel shows 6 category icons (emoji) on colored segments
2. Wheel has correct number of slices per category based on heart states
3. No two same-category slices are adjacent on the wheel
4. Long-press on wheel → settings dialog opens
5. Heart toggle cycles: 🤍→❤️→🔥→💔→🤍 with correct values
6. Chance percentages calculate correctly
7. Tier checkboxes filter which tasks can appear
8. Anti-abuse: if all values equal, reset to 1 + show snackbar
9. Spin lands on category → task revealed from selected tier
10. 60fps animation, no crashes on both platforms

---

## Future Features

### Shop System
- Users spend points in a shop
- Items: skip cards, bonus rolls, custom tasks, avatar unlocks, themes
- Categories: "Consumables", "Cosmetics", "Power-ups"

### Skills System
- Unlockable skills/abilities
- Could be earned through milestones
- Examples: "Double Points", "Task Shield" (one free skip), "Wild Card" (any category)

### Sharing
- NO sharing feature — user decision

### Session End
- Keep it flexible — no fixed rounds
- Let users decide when to stop
- Could add optional "Best of X" mode later

---

## Open Questions

- How many unique Task+Handicap combinations do we seed with? (Recommend: 20-30 minimum)
- Should the user be able to customize/add their own segments?
- Is there a cooldown between spins? (Stamina system? Time-gate?)
- Does the wheel shuffle segments after each spin, or stay fixed?
