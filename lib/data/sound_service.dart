import 'dart:async';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

/// Centralized sound & haptic service.
/// Uses HapticFeedback + SystemSound as placeholders.
/// Swap in real audio assets later by replacing the method bodies.
class SoundService {
  SoundService._();

  static bool get _enabled {
    final box = Hive.box('settings');
    return box.get('sound_enabled', defaultValue: true) == true;
  }

  static bool get _hapticEnabled {
    final box = Hive.box('settings');
    return box.get('haptic_enabled', defaultValue: true) == true;
  }

  // ── Wheel Sounds ──

  /// Tick sound during wheel spin — one per card pass.
  /// Use [intensity] to vary feel: 0 = light (early), 1 = heavy (late).
  static void wheelTick({double intensity = 0.5}) {
    if (!_hapticEnabled) return;
    if (intensity > 0.7) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  /// Heavy thud when wheel lands on final position.
  /// Double impact for satisfying "thunk".
  static void wheelLand() async {
    if (!_hapticEnabled) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.mediumImpact();
  }

  // ── Action Sounds ──

  /// Success chime when player accepts a task.
  /// Double tap for positive feel.
  static void accept() async {
    if (!_hapticEnabled) return;
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }

  /// Subtle buzz when player skips a task.
  static void skip() {
    if (!_hapticEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Button tap feedback.
  static void tap() {
    if (!_hapticEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Selection change feedback (category toggle, etc).
  static void select() {
    if (!_hapticEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Task revealed — whoosh feel.
  static void taskRevealed() async {
    if (!_hapticEnabled) return;
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.selectionClick();
  }

  // ── Timer Sounds ──

  /// Timer warning at 30s — double beep pattern.
  static void timerWarning30() async {
    if (!_hapticEnabled) return;
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.mediumImpact();
  }

  /// Timer warning at 10s — urgent triple beep.
  static void timerWarning10() async {
    if (!_hapticEnabled) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }

  /// Timer expired — alarm.
  static Future<void> timerAlarm() async {
    if (!_enabled) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      try {
        await HapticFeedback.vibrate();
      } catch (_) {}
    }
  }

  /// Timer expired vibration loop (~3 seconds).
  static void timerVibrateLoop() {
    if (!_hapticEnabled) return;
    int count = 0;
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      count++;
      if (count >= 6) {
        timer.cancel();
        return;
      }
      HapticFeedback.heavyImpact();
    });
  }

  // ── Celebration ──

  /// Confetti burst feel — rapid light taps.
  static void celebration() async {
    if (!_hapticEnabled) return;
    for (int i = 0; i < 3; i++) {
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 60));
    }
  }

  // ── Skip Cooldown ──

  /// Denied action — low buzz.
  static void denied() {
    if (!_hapticEnabled) return;
    HapticFeedback.heavyImpact();
  }
}
