# Plan A v2: Screen 1 — The Spin (Updated Implementation Plan)

> **Goal:** Build home screen with icon-based roulette wheel, weighted category system, long-press settings dialog
> **Owner:** Developer Agent (Yuna)
> **Design Spec:** See `MIKA_SCREEN1_THE_SPIN.md`

---

## Key Changes from v1

1. **Wheel segments = CATEGORY ICONS** (not text)
2. **Weighted slices** — number of slices per category = its value (1-3)
3. **Slices spread randomly** — no two same-category slices adjacent
4. **4-state heart toggle** — 🤍(1) → ❤️(2) → 🔥(3) → 💔(0) → 🤍(1)
5. **Anti-abuse rule** — if all categories equal value, reset all to 1
6. **Tier selection** — user picks soft/kink/entertainment per category
7. **Long-press dialog** — category settings with heart toggle + tier checkboxes

---

## Step 1: Data Models

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
  final String icon; // emoji character
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

---

## Step 2: Load task.json

Create `lib/data/task_loader.dart`:

- Load `assets/task.json` using `rootBundle`
- Parse JSON into `List<ChallengeCategory>`
- Handle version field
- Each category has id, name, icon, soft[], kink[], entertainment[]

**Add to pubspec.yaml:**
```yaml
flutter:
  assets:
    - task.json
```

---

## Step 3: Wheel Slice Builder

Create `lib/data/wheel_builder.dart`:

**Purpose:** Given the 6 categories (with their current heart states), build the list of slices for the wheel.

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
  final String color; // hex color assigned to category
}
```

**Anti-abuse check:**
```dart
bool allSameValue(List<ChallengeCategory> categories) {
  final values = categories.where((c) => c.isEnabled).map((c) => c.value).toSet();
  return values.length <= 1;
}
// If true → reset all to HeartState.off, show snackbar
```

---

## Step 4: Category Colors

Assign consistent colors to each category:

| Category | Color | Hex |
|----------|-------|-----|
| 🏠 Domestic | Coral Red | #FF6B6B |
| 💬 Dirty Truth | Sky Blue | #45B7D1 |
| 🔥 Spicy Dare | Burnt Orange | #FF8C42 |
| 🎭 Roleplay | Vivid Purple | #A855F7 |
| 👅 Sensation | Electric Yellow | #FFE66D |
| 🌀 Wildcard | Teal | #4ECDC4 |

---

## Step 5: Update RouletteWheelPainter

Modify `lib/widgets/roulette_wheel_painter.dart`:

**Instead of text, draw:**
- Colored arc segments (equal angle, based on total slice count)
- Category icon (emoji) centered in each segment
- White border between segments

**Icon rendering approach:**
- Use `TextPainter` with the emoji character as text
- Emoji renders natively on both iOS/Android
- Font size ~20-24px for readability on spinning wheel
- Center icon in segment using `Canvas.save()` + `Canvas.rotate()` + `Canvas.translate()`

**Key change:** `RouletteWheelPainter` now takes `List<WheelSlice>` instead of `List<ChallengeSegment>`

---

## Step 6: Update RouletteWheel

Modify `lib/widgets/roulette_wheel.dart`:

- Accept `List<WheelSlice>` and `List<ChallengeCategory>`
- Spin selects a random slice from the wheel
- On complete: find the category for that slice, pick random task from selected tier
- Callback: `onSpinComplete(ChallengeCategory category, ChallengeSegment task)`

---

## Step 7: Settings Dialog (Long-Press)

Create `lib/widgets/category_settings_dialog.dart`:

**Trigger:** Long-press on wheel

**Layout:**
- Title: "CHALLENGE SETTINGS"
- For each category (6 rows):
  - Category icon (emoji)
  - Heart toggle button (tap to cycle 🤍→❤️→🔥→💔→🤍)
  - Chance percentage (calculated live)
  - Tier checkboxes (Soft / Kink / Entertainment)
- Bottom: Cancel + Save buttons
- If all same value after change → show snackbar, reset to off

**State management:**
- Local state in dialog (copy of category heart states)
- On Save: apply to main state, rebuild wheel
- On Cancel: discard changes

---

## Step 8: Update SpinScreen

Modify `lib/screens/spin_screen.dart`:

**New state:**
- `List<ChallengeCategory> _categories` — loaded from task.json
- `String _selectedTier` — 'soft', 'kink', or 'entertainment' (from settings)
- `List<WheelSlice> _wheelSlices` — rebuilt when categories change

**New interactions:**
- Long-press on wheel → open settings dialog
- Dialog save → rebuild wheel slices → update UI
- Spin result → show task from selected tier of landed category

---

## Step 9: Result Card Update

Modify `lib/widgets/result_card.dart`:

- Show category icon + name
- Show task text
- Show points
- Show timer if applicable
- Accept + Skip buttons

---

## Step 10: Wire & Test

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

---

## File Structure

```
lib/
├── main.dart
├── models/
│   ├── challenge_segment.dart
│   └── challenge_category.dart
├── data/
│   ├── task_loader.dart
│   ├── wheel_builder.dart
│   └── category_colors.dart
├── screens/
│   └── spin_screen.dart
└── widgets/
    ├── roulette_wheel_painter.dart
    ├── roulette_wheel.dart
    ├── score_bar.dart
    ├── spin_button.dart
    ├── wheel_pointer.dart
    ├── result_card.dart
    └── category_settings_dialog.dart
```

---

## Acceptance Criteria

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
