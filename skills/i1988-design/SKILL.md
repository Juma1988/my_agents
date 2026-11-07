---
name: i1988 Design
description: Use for UI/UX design or implementation in Ibrahim's apps when reviewing visual hierarchy, forms, commerce, motion, cards, or screen-specific interactions. Apply approved principles selectively; never force every video effect into every screen.
---

# i1988 Design

Purpose: turn Ibrahim's video-derived UI ideas into useful, honest design decisions. Sora uses this while designing; Yuna uses the relevant design contract while implementing; Kira checks observable behavior and accessibility. Eve remains the decision owner. This skill is guidance, not permission to change product scope, branding or approved flows.

## Start here

1. Identify the user's task and the screen's primary action. Inspect existing design tokens, components, platform conventions and approved direction before proposing changes.
2. Select only the relevant sections below. Prefer fewer steps and clearer states to decorative polish. Mark unneeded effects **Skipped** rather than adding them by default.
3. Separate **required behavior** from **optional visual inspiration**. When a major interaction, pricing default or visual direction would change, ask Eve for user approval.
4. Give a concise contract: hierarchy, layout, interaction/states, accessibility/RTL/responsive behavior, and what to verify. Reuse current components first.

## Baseline: legibility and honest UX

- Give each screen a clear purpose, visible primary action and readable information hierarchy. Group related content with consistent spacing and coherent typography, surfaces, radii and icons. Fit the existing design system; example pixel values in videos are **not defaults**.
- Make actionable elements identifiable and comfortable to use with touch, pointer, keyboard and assistive technology. Keep meaningful labels visible, contrast verified and focus apparent. Check text scaling, narrow screens, localization/RTL and dark mode.
- Reduce avoidable typing and decisions: suggestions, reliable editable autofill, sensible grouping and contextual actions when appropriate. Validate normalized input; do not accept arbitrary values at a trust boundary.
- Show **real** progress, totals, ETA, delivery dates, security properties, sent/read status and success. Label estimates. Never fake countdowns, loading activity, popularity, discount or completion; never use prechecked add-ons, shame, deceptive consent or hard-to-cancel flows.
- For auth, purchase and irreversible actions, show loading while pending and success only after confirmation. Optimistic UI is for safe reversible actions with rollback/error handling.

## Task-specific checks — use only when applicable

- **Cards/buttons:** Clarify title, content and action. Use surface depth only if useful; press feedback on touch, hover only with a pointer. Decoration must not obscure content or reduce performance.
- **Forms/login:** Persistent labels, obvious focus, one clear primary action, accessible errors and honest loading/success states. Keep recovery paths available.
- **Checkout/pricing:** Make plan terms, billing period and complete payable amount explicit. Offer guest/express paths only when supported. Use a trusted payment provider for card data; avoid invented security claims or misleading preselected billing.
- **Command palette:** Clear query, understandable grouping/matches and keyboard navigation including escape; no unsafe destructive action selected by default.
- **Tracking/chat/media:** Show only real and permitted live state; respect privacy. Preserve reading/scroll position and provide accessible, appropriately sized controls.
- **Swipe cards:** Follow the drag; define release threshold and velocity behavior, cancellation/snap-back, non-swipe equivalent, focus/semantics and reduced-motion alternative. Do not add swipe as the only way to act.

## Motion contract

Only animate when it explains a change, confirms input or maintains spatial continuity. For each meaningful motion specify **trigger, purpose, duration/easing, interrupt/cancel behavior and reduced-motion equivalent**. Prefer native interaction physics; allow gestures to interrupt transitions. Avoid long blocking motion, automatic replay on list rebuilds and decorative motion on every tap. A spinner/check represents actual pending/completed work; a visual duration target is never a network deadline. Icon morphs, gradients, glare, springs and stagger are optional examples, not required signatures.

## Verify before handing off

- Sora: identify selected principles, skipped ideas, realistic states and decisions needing approval.
- Yuna: preserve the agreed states and semantics; check focused interaction and async success/error behavior when implementing.
- Kira: independently check touch/keyboard/assistive alternatives, contrast-related implementation, text scaling, RTL where relevant, reduced motion, cancellation and actual completion state.

Provenance: distilled from 26 user-supplied video transcripts in a working draft. Videos and numerical claims were not independently verified. Do not cite those claims as research or copy their exact values without testing against the app.
