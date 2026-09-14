# Card Stack v2 — Layout Spec

## Card Positioning (Vertical Stack)

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

## Transform Rules

| Position | Scale | Opacity | Y Offset | Z Rotation |
|----------|-------|---------|----------|------------|
| -2 | 0.7 | 0.4 | -80px | -4deg |
| -1 | 0.85 | 0.7 | -40px | -2deg |
| 0 | 1.0 | 1.0 | 0px | 0deg |
| 1 | 0.85 | 0.7 | +40px | +2deg |
| 2 | 0.7 | 0.4 | +80px | +4deg |

## Spin Behavior
- Cards cycle upward: card 0 moves to position -2, card 1 moves to 0, etc.
- New card enters from bottom (position 2)
- Rapid cycling → deceleration → land on target
- Target card always ends at position 0 (center)
