---
name: sora-design-system
description: >
  Sora's design-system skill for tokens, reusable components, consistency, component APIs, visual primitives, and avoiding design-system drift in Flutter projects.
---


# Sora Design System

Use when a task affects shared visual language or repeated UI patterns.

## Goals
- consistency before novelty;
- semantic tokens over magic values;
- reuse before invention;
- small component APIs;
- controlled variation;
- platform-aware product identity.

## Token Review
Review semantic:
- color roles;
- typography;
- spacing;
- radius;
- elevation/shadow;
- icon size;
- motion;
- component dimensions.

A repeated number is not automatically a token.
A token represents a design decision.

## Component Ladder
1. existing system component;
2. existing custom widget;
3. clean extension;
4. compose primitives;
5. new reusable component;
6. one-off only when genuinely unique.

## 3+ Rule
Three or more meaningful repetitions require extraction review.
Extract only when callers share a reason to change.

Avoid mega-components with many boolean mode flags.

## Drift
Flag:
- nearly-identical components;
- direct colors bypassing semantic roles;
- repeated one-off spacing;
- inconsistent states;
- icon-family mixing;
- typography variants invented locally.

## Output
Return system impact, reuse candidate, token candidate, and smallest consistency correction.
