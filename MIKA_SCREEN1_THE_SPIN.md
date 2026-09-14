# Screen 1: The Spin — Design Spec

## Overview
The home screen. The "pull the lever" moment. The user lands here, sees the wheel, feels the urge, and taps SPIN.

---

## Visual Layout (Top to Bottom)

```
┌─────────────────────────────────┐
│  SCORE: 42 pts        [≡ menu] │  ← ScoreBar
│                                 │
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
│                                 │
│     ┌───────────────────┐       │
│     │    ✦  S P I N  ✦  │       │  ← Spin Button
│     └───────────────────┘       │
│                                 │
└─────────────────────────────────┘
```

---

## Color Philosophy

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

---

## Widget Hierarchy (Conceptual)

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

---

## The Wheel — Technical Details

### Drawing (CustomPainter)
- 8 segments (good visual density, readable text)
- Each segment: arc slice with task+handicap text curved along the arc OR straight text rotated to segment center
- Text approach: **rotated straight text** — simpler to implement, more readable on mobile than curved text
- Segment labels example:
  - "Clean kitchen\n+ blindfolded"
  - "Cook dinner\n+ no music"
  - "Do 20 pushups\n+ while singing"
  - "Text your crush\n+ using emojis only"
  - "Clean bathroom\n+ non-dominant hand"
  - "Make bed\n+ eyes closed"
  - "Organize desk\n+ timed 2min"
  - "Walk the dog\n+ backwards"

### Spin Animation
- **Engine:** `AnimationController` with `CurvedAnimation(curve: Curves.easeOutExpo)`
- **Duration:** 3–4 seconds
- **Total rotation:** Random between 3–6 full rotations + offset to land on target segment
- **Deceleration:** `easeOutExpo` gives a natural "wheel slowing down" feel
- **Sound sync (optional):** Tick sound at each segment boundary during deceleration phase

### Target Selection
- Pre-select random target BEFORE animation starts
- Calculate final rotation angle to land on that segment
- Pointer is at 6 o'clock — final angle = `(segmentIndex * segmentAngle) + offset`

---

## Spin Button Behavior

| State | Appearance | Behavior |
|-------|-----------|----------|
| **Ready** | Gold gradient, pulsing glow, "SPIN" text | Tappable. Starts spin. |
| **Spinning** | Grayed out, "Spinning..." text | Disabled. No interaction. |
| **Result** | Hidden / morphs into result card | Transition to result reveal. |

---

## Interaction Flow (Screen 1 → Screen 2)

1. **User lands on screen.** Sees wheel, score, glowing SPIN button.
2. **User taps SPIN.**
   - Button: disable + text change
   - Wheel: begins rotation animation
   - Haptic feedback: light tap on press
3. **Wheel spins for 3–4 seconds**, decelerates naturally.
4. **Wheel stops.** Brief pause (0.5s) — tension moment.
5. **Result reveal:**
   - A card/modal slides up from bottom (or fades in over the wheel)
   - Shows: Task name + Handicap name in bold, readable text
   - Two buttons: "Accept Challenge" or "Skip (−1 pt)"
6. **On "Accept Challenge":** Navigate to Screen 2 (The Challenge)

---

## Micro-Interactions & Polish

- **Wheel glow:** Subtle animated ring around the wheel that pulses when idle, intensifies during spin
- **Segment highlight:** When wheel stops, the winning segment gets a brief brightness flash
- **Score counter:** Animated number roll when score changes (not on this screen, but future-proof the widget)
- **Background particles:** Very subtle floating dots/stars — adds depth without distraction

---

## Open Questions for Next Iteration

- How many unique Task+Handicap combinations do we seed with? (Recommend: 20-30 minimum)
- Should the user be able to customize/add their own segments?
- Is there a cooldown between spins? (Stamina system? Time-gate?)
- Does the wheel shuffle segments after each spin, or stay fixed?
