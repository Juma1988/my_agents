# Card Stack Spin v2 — Updated Design Spec

## Concept
Vertical card stack that spins like a 3D Rolodex. User selects MULTIPLE categories at the top. Spin picks a random task from the combined pool of all selected categories.

---

## New Flow

1. **Top bar:** Multi-select category chips (tap to toggle)
2. **Center:** Card stack with all categories
3. **Spin:** Cycles through cards rapidly, decelerates
4. **Lands on:** The card (category) the task belongs to
5. **Task picked:** Random task from that category's selected tier
6. **Result card:** Shows category + task + points + timer

---

## Top Bar — Multi-Select Chips

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

---

## Card Stack — Visual

- Shows ALL categories (not just selected)
- Selected cards: full color, prominent
- Deselected cards: grayscale, pushed to back, smaller
- Front card always a selected category during spin

---

## Spin Logic

1. Build task pool from ALL selected categories + selected tier
2. Pick random task from pool
3. Determine which category that task belongs to
4. Spin card stack to land on that category's card
5. Show result

---

## Anti-Abuse Update

- If only 1 category selected → all tasks from that category
- If all 6 selected → full pool (original behavior)
- No need for weighted slices anymore — selection IS the weighting

---

## Widget Changes

### Remove
- Weighted wheel slices
- Heart toggle (replaced by chip selector)
- Settings dialog (replaced by top bar chips)

### Add
- CategoryChipSelector widget (top bar)
- CardStack widget (replaces RouletteWheel)
- CardStackPainter or CardStackWidget (3D perspective cards)

### Keep
- Result card (with countdown timer)
- Score bar
- Spin button
- Hive persistence (save selected categories)
