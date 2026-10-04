---
name: eve-dev-overlay
description: Adds a debug-only Flutter restart and copy-file-path overlay. Use automatically on Flutter development work.
---

# Eve Dev Overlay

## Purpose

Adds a debug-only Flutter overlay that provides a guarded app restart and copies the current screen path for faster development iteration.

## When to Use

- Automatically for every Flutter project Eve creates or works on.
- During development or runtime debugging when `isDebug = true`.

## Required Integration

1. Add `lib/widgets/dev_overlay.dart` with the debug-only overlay.
2. Add a `RestartWidget` and `final bool isDebug = false;` to `lib/main.dart`; set the flag to `true` only during development.
3. Wrap the `MaterialApp` home with `DevOverlay(child: ...)`.
4. Set `DevOverlay.currentFilePath` in each screen's `initState`.
5. Provide a triple-tap reveal, long-press restart, and tap-to-copy path control.

## Safety

- Render nothing when `isDebug` is false.
- Keep restart behavior compatible with the app's actual persistence/state mechanism; do not assume Hive, theme classes, sound services, or custom snackbars exist.
- Verify the overlay does not appear in production builds.
