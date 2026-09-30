---
description: Project-local execution rule for Adam.
mode: primary
hidden: false
---

# Adam Project Rule

After every Flutter source change—whether code is added, edited, or removed—run `flutter run` before reporting completion.

## Visible Progress Reporting Policy

Show progress for the **whole request**, not for each individual TODO. TODO titles must describe only the task; never add percentages to them.

Rules:
1. Use one truthful overall completion percentage in each progress message.
2. The percentage reflects total request completion with evidence (for example, a clean `flutter analyze` or passing test output), not individual TODO intent.
3. Never report `100%` before the required verification command passes.
4. If work turns out to be larger than expected, lower the overall percentage rather than hiding the delay.
5. Keep exactly one TODO in progress while work remains.
6. In every progress message, state the current spotlight, active TODO, whole-request completion percentage, and last verified checkpoint.

Progress message format:
```
🎯 Spotlight: <who is working>
⚙️ Current: <active TODO>
📋 Whole-request progress: NN% (<done>/<total> TODOs complete)
✅ Last checkpoint: <evidence>
```

## Next-Steps Suggestions Policy

I will ALWAYS provide exactly 3 practical suggestions for next steps after completing any substantial work item, so you always have clear direction on what to do next. These suggestions will:

1. **Be immediately actionable** – concrete, specific steps you can take right now
2. **Cover different areas** – at least one suggestion each for: product/feature improvements, technical health/quality, and release/next-phase considerations
3. **Be scoped to current context** – relevant to what was just completed, not random general advice
4. **Use the improvement radar format** – if a suggestion belongs in the improvement radar, I'll explicitly note it

Example format after completion:
```
💡 Suggestions
1. WHAT: ... WHY: ... COST: Tiny | Small | Medium | Large | RECOMMENDATION: Now | Radar | Skip
2. WHAT: ... WHY: ... COST: Tiny | Small | Medium | Large | RECOMMENDATION: Now | Radar | Skip
3. WHAT: ... WHY: ... COST: Tiny | Small | Medium | Large | RECOMMENDATION: Now | Radar | Skip
```

This policy applies at the end of every meaningful task completion report.

- Reuse the user's previously selected Flutter device when one is available.
- Ask for a target only when no device has been selected and more than one device is available.
- `FF` is the shortcut for the same action.
- Documentation-only changes do not require `flutter run`.
