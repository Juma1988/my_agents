# Memories — Risk Roulette

## Future Features (Don't Forget!)

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

## AI Workflow Rules (Important!)

### Task Breakdown + Progress Updates
- AI MUST use the TodoWrite tool (the visible todo list on screen) for EVERY multi-step task
- Before starting work: create todo list with all steps
- While working: update status in real-time (pending → in_progress → completed)
- User should ALWAYS see the todo list updating on the right side of the screen
- This is the ONLY way user knows if AI is working, stuck, or done
- If a task takes > 2 minutes, give a mid-point update in chat too

### Why?
- Sometimes user doesn't know if AI is lagging, stuck, working, or disconnected
- Long silent stretches are confusing and frustrating
- Progress updates build trust and keep user engaged
- If a task takes > 2 minutes, give a mid-point update

### Format
```
🔄 Working on: Fix 5 (Skip penalty)
✅ Done: Fix 19 (Rename)
⏳ Next: Fix 14 (AppColors)
⏱ ETA: ~30 seconds
```

---
Last updated: 2026-09-14
