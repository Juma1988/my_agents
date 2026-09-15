# Risk Roulette — Roadmap

> Last updated: 2026-09-15
> Status: Active planning

---

## Phase 1: Core Polish (Next)

### 1.1 Onboarding Screen
- 3-slide "How to Play" before first spin
- Shown only on first launch (persist flag in Hive)
- Slides: (1) Spin & reveal, (2) Accept vs Skip, (3) Scoring & players
- Skip button available

### 1.2 Sound Design
- Wheel spin: tick-tick-tick sound that slows down with deceleration
- Wheel landing: satisfying thud/click on final position
- Task accepted: success chime
- Task skipped: subtle buzz
- Timer alarm: already exists, keep as-is

### 1.3 Visual Celebration
- Confetti burst on task accept
- Score "+X" animation (already exists, enhance with particle effect)
- Streak indicator: "3 in a row!" after 3 consecutive accepts

### 1.4 Session Score Display
- Player bar shows: `Player1 18(-3)` style
- Green text if session net positive, red if negative
- Format: `Total (±session delta)`
- Resets on full app relaunch (not just background)
- Session delta = points earned - points lost in current session

---

## Phase 2: History & Settings

### 2.1 Task History Screen
- Accessible via button in drawer
- Shows list of past completed/skipped tasks
- Each entry: category icon, task text, points, accept/skip, timestamp
- Filter by: All, Accepted, Skipped, by Category
- Stored in Hive (new box: 'history')
- Max history: last 200 tasks (FIFO)

### 2.2 Settings Page
- Accessible via button in drawer
- Settings:
  - **Hide completed tasks** — dropdown:
    - `Always Ask` — show confirmation if task was done before
    - `Keep Favorite` — hide completed unless marked favorite
    - `Enable` — always hide completed tasks
    - `Disable` — never hide (show everything)
  - **Haptic feedback** — toggle (currently hardcoded true)
  - **Sound effects** — toggle
  - **Player reset** — reset scores to 0
  - **Clear history** — wipe task history

### 2.3 Done/Repeat Tracking
- Each task gets a `completedBy` field in Hive (which player completed it)
- Tasks marked as done can be filtered based on settings
- Favorite toggle per task (heart icon in history)

---

## Phase 3: Skip System

### 3.1 Skip Cooldown
- Each player gets 10 "rounds" between skips
- A round = one full turn (their spin + result)
- Skip button shows cooldown: "Skip (5 rounds left)"
- When cooldown active, skip button disabled with visual countdown
- Cooldown resets after it reaches 0

### 3.2 Shop: Skip Cooldown Shortener
- Skill in shop: "Quick Skip"
- Reduces cooldown from 10 rounds → 3 rounds
- One-time purchase per player
- Persisted in Hive per player

---

## Phase 4: Sound & Vibration

### 4.1 Wheel Sound Engine
- Pre-load short audio clips (or use synthesizer)
- Tick sound: plays at each card boundary during spin
- Frequency decreases as wheel decelerates
- Final landing sound: heavier, bassy thud

### 4.2 UI Sounds
- Button taps: subtle click
- Category select: soft pop
- Task revealed: whoosh/slide-in sound
- Timer warning (30s): double beep

---

## Phase 5: Progression System

### 5.1 Tier Unlocking
- **Tier 1 (Soft):** Unlocked from start
- **Tier 2 (Kink):** Unlocks after 25 total tasks completed
- **Tier 3 (Entertainment):** Unlocks after 50 total tasks completed
- Progress shown in drawer: "25/50 tasks to unlock Kink"
- Locked tiers shown grayed out with lock icon
- Once unlocked, stays unlocked permanently

### 5.2 Milestones
- 10 tasks completed: "Getting Started" badge
- 25 tasks: "Adventurous" badge
- 50 tasks: "Daring" badge
- 100 tasks: "Legends" badge
- Shown in profile section of drawer

---

## Phase 6: Save for Later (Skill)

### 6.1 Mechanic
- Skill in shop: "Bookmark"
- When unlocked, shows **"Save for Later"** button during player's turn
- Button only visible to the player who bought the skill
- Using it:
  - Saves current task to a personal "saved" queue (max 3 saved)
  - Player spins again immediately
  - On next turn, player has 2 tasks: the new spin + the saved task
  - Player must do BOTH or skip both (skip counts as 2 skips on cooldown)

### 6.2 Cooldown
- Save for Later has its own cooldown: 5 player rounds
- Displayed similarly to skip cooldown
- Both cooldowns (skip + save) can run in parallel

### 6.3 Smart Skip Variant
- If player saves a task then skips the new spin:
  - Saved task carries over to next turn
  - Player gets 2 tasks next time
- If player saves a task then accepts the new spin:
  - Saved task still pending
  - Next turn: just the saved task (1 task)

---

## Phase 7: Shop System

### 7.1 Currency
- Points earned from tasks = shop currency
- 1 point = 1 coin in shop

### 7.2 Shop Categories

**Consumables (one-time use)**
- Extra Spin: spin again without waiting (3 coins)
- Double Points: next task gives 2x points (5 coins)
- Task Shield: one free skip with no cooldown (4 coins)

**Skills (permanent unlock)**
- Quick Skip: skip cooldown 10 → 3 rounds (15 coins)
- Bookmark: save task for later (20 coins)
- Favorite: mark tasks to always appear (10 coins)

**Power-ups (affect opponent)**
- Forced Task: opponent must do a specific category next spin (8 coins)
- Tier Lock: force opponent into a specific tier next spin (6 coins)
- Score Steal: steal 3 points from opponent (10 coins)

**Cosmetics (visual only)**
- Custom wheel colors (5 coins)
- Custom avatars beyond defaults (3 coins)
- Animated spin button themes (7 coins)

### 7.3 Skill Tree (Per Player)
- Each player has their own skill tree
- Some skills require prerequisites (e.g., Bookmark requires Favorite)
- Skill tree shown in profile section
- Unlocked skills shown as active, locked shown grayed

---

## Phase 8: Future Ideas (Backlog)

- **Forced tasks:** Buy in shop to force opponent into a specific category
- **Custom tasks:** User adds their own tasks to the pool
- **Achievements:** Unlock titles/badges for milestones
- **Night mode toggle:** Some users might want lighter theme
- **Export session:** Share session summary (if sharing feature re-enabled)
- **Multiple game modes:** "Best of X", "First to 50", "Speed round"

---

## Decisions Log

| # | Decision | Date |
|---|----------|------|
| D1 | No sharing feature | 2026-09-14 |
| D2 | Session end: flexible, no fixed rounds | 2026-09-14 |
| D3 | Skip cooldown: 10 rounds, skill reduces to 3 | 2026-09-15 |
| D4 | Tier unlock: Soft (start), Kink (25 done), Entertainment (50 done) | 2026-09-15 |
| D5 | Save for Later: max 3 saved, 2 tasks on next turn, own cooldown | 2026-09-15 |
| D6 | Session score: green/red delta, resets on full app close | 2026-09-15 |
| D7 | Settings: hide completed tasks dropdown (Always Ask/Keep Favorite/Enable/Disable) | 2026-09-15 |
| D8 | Sound design: tick-tick-tick + landing thud | 2026-09-15 |
| D9 | Visual celebration: confetti on accept | 2026-09-15 |
