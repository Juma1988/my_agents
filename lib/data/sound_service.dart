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

  /// Tick sound during wheel spin — one per card pass.
  static void wheelTick() {
    if (!_hapticEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Heavy thud when wheel lands on final position.
  static void wheelLand() {
    if (!_hapticEnabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Success chime when player accepts a task.
  static void accept() {
    if (!_hapticEnabled) return;
    HapticFeedback.mediumImpact();
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

  /// Timer warning at 30s and 10s.
  static void timerWarning() {
    if (!_hapticEnabled) return;
    HapticFeedback.mediumImpact();
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
}
