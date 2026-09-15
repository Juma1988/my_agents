import 'package:hive/hive.dart';

/// Tracks progression: completed tasks, tier unlocks, milestones.
class ProgressionService {
  ProgressionService._();

  static Box get _box => Hive.box('settings');

  // ── Tier Unlock Thresholds ──
  static const int tier2UnlockAt = 25;
  static const int tier3UnlockAt = 50;

  // ── Milestone Thresholds ──
  static const List<Milestone> milestones = [
    Milestone(name: 'Getting Started', threshold: 10, icon: '🌱'),
    Milestone(name: 'Adventurous', threshold: 25, icon: '🔥'),
    Milestone(name: 'Daring', threshold: 50, icon: '⚡'),
    Milestone(name: 'Legends', threshold: 100, icon: '👑'),
  ];

  /// Total tasks completed across all sessions (both players combined).
  static int get totalCompleted => _box.get('total_completed_tasks', defaultValue: 0);

  /// Record one completed (accepted) task.
  static void recordCompletion() {
    _box.put('total_completed_tasks', totalCompleted + 1);
  }

  /// Whether a given tier is currently unlocked.
  static bool isTierUnlocked(String tier) {
    switch (tier) {
      case 'soft':
        return true; // always unlocked
      case 'kink':
        return totalCompleted >= tier2UnlockAt;
      case 'entertainment':
        return totalCompleted >= tier3UnlockAt;
      default:
        return false;
    }
  }

  /// All unlocked tiers.
  static List<String> get unlockedTiers {
    final tiers = <String>['soft'];
    if (totalCompleted >= tier2UnlockAt) tiers.add('kink');
    if (totalCompleted >= tier3UnlockAt) tiers.add('entertainment');
    return tiers;
  }

  /// Progress toward the next tier unlock.
  /// Returns a [TierProgress] with current progress and target.
  static TierProgress get nextTierUnlock {
    if (totalCompleted < tier2UnlockAt) {
      return TierProgress(
        current: totalCompleted,
        target: tier2UnlockAt,
        tierName: 'Kink',
      );
    } else if (totalCompleted < tier3UnlockAt) {
      return TierProgress(
        current: totalCompleted - tier2UnlockAt,
        target: tier3UnlockAt - tier2UnlockAt,
        tierName: 'Entertainment',
      );
    }
    // All tiers unlocked
    return TierProgress(
      current: 1,
      target: 1,
      tierName: 'All Unlocked',
      isComplete: true,
    );
  }

  /// All milestones the player has earned.
  static List<Milestone> get earnedMilestones {
    return milestones.where((m) => totalCompleted >= m.threshold).toList();
  }

  /// The next milestone not yet earned.
  static Milestone? get nextMilestone {
    try {
      return milestones.firstWhere((m) => totalCompleted < m.threshold);
    } catch (_) {
      return null;
    }
  }
}

/// Represents a tier unlock progress.
class TierProgress {
  final int current;
  final int target;
  final String tierName;
  final bool isComplete;

  const TierProgress({
    required this.current,
    required this.target,
    required this.tierName,
    this.isComplete = false,
  });

  double get fraction => isComplete ? 1.0 : (current / target).clamp(0.0, 1.0);
}

/// Represents a milestone.
class Milestone {
  final String name;
  final int threshold;
  final String icon;

  const Milestone({
    required this.name,
    required this.threshold,
    required this.icon,
  });
}
