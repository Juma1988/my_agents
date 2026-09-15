import 'package:hive/hive.dart';
import 'shop_service.dart';
import 'progression_service.dart';

/// 20 achievements with unlock conditions.
class AchievementService {
  AchievementService._();

  static Box get _box => Hive.box('settings');

  // ── Achievement Definitions ──

  static const List<Achievement> achievements = [
    // Task Completion (6)
    Achievement(
      id: 'first_steps',
      name: 'First Steps',
      description: 'Complete your first task',
      icon: '🌱',
      category: AchievementCategory.completion,
      threshold: 1,
    ),
    Achievement(
      id: 'getting_warmed_up',
      name: 'Getting Warmed Up',
      description: 'Complete 5 tasks',
      icon: '🔥',
      category: AchievementCategory.completion,
      threshold: 5,
    ),
    Achievement(
      id: 'on_a_roll',
      name: 'On a Roll',
      description: 'Complete 10 tasks',
      icon: '🎳',
      category: AchievementCategory.completion,
      threshold: 10,
    ),
    Achievement(
      id: 'half_century',
      name: 'Half Century',
      description: 'Complete 25 tasks',
      icon: '⚡',
      category: AchievementCategory.completion,
      threshold: 25,
    ),
    Achievement(
      id: 'century',
      name: 'Century',
      description: 'Complete 50 tasks',
      icon: '💯',
      category: AchievementCategory.completion,
      threshold: 50,
    ),
    Achievement(
      id: 'legend',
      name: 'Legend',
      description: 'Complete 100 tasks',
      icon: '👑',
      category: AchievementCategory.completion,
      threshold: 100,
    ),

    // Category Mastery (3)
    Achievement(
      id: 'soft_touch',
      name: 'Soft Touch',
      description: 'Complete 5 soft tasks',
      icon: '🫧',
      category: AchievementCategory.category,
      targetCategory: 'soft',
      threshold: 5,
    ),
    Achievement(
      id: 'kink_explorer',
      name: 'Kink Explorer',
      description: 'Complete 5 kink tasks',
      icon: '🔗',
      category: AchievementCategory.category,
      targetCategory: 'kink',
      threshold: 5,
    ),
    Achievement(
      id: 'entertainment_buff',
      name: 'Entertainment Buff',
      description: 'Complete 5 entertainment tasks',
      icon: '🎭',
      category: AchievementCategory.category,
      targetCategory: 'entertainment',
      threshold: 5,
    ),

    // Challenge Types (3)
    Achievement(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Complete 5 timed tasks',
      icon: '⏱️',
      category: AchievementCategory.timed,
      threshold: 5,
    ),
    Achievement(
      id: 'brave_heart',
      name: 'Brave Heart',
      description: 'Skip 10 tasks',
      icon: '🛡️',
      category: AchievementCategory.skip,
      threshold: 10,
    ),
    Achievement(
      id: 'shield_bearer',
      name: 'Shield Bearer',
      description: 'Use Task Shield 5 times',
      icon: '🛡️',
      category: AchievementCategory.shield,
      threshold: 5,
    ),

    // Streak & Pattern (2)
    Achievement(
      id: 'unstoppable',
      name: 'Unstoppable',
      description: 'Accept 10 tasks in a row without skipping',
      icon: '💪',
      category: AchievementCategory.streak,
      threshold: 10,
    ),
    Achievement(
      id: 'double_down',
      name: 'Double Down',
      description: 'Use Double Points 5 times',
      icon: '✨',
      category: AchievementCategory.doublePoints,
      threshold: 5,
    ),

    // Shop (3)
    Achievement(
      id: 'shopper',
      name: 'Shopper',
      description: 'Buy 5 items from the shop',
      icon: '🛒',
      category: AchievementCategory.shop,
      threshold: 5,
    ),
    Achievement(
      id: 'skill_collector',
      name: 'Skill Collector',
      description: 'Own 3 different skills',
      icon: '📚',
      category: AchievementCategory.skills,
      threshold: 3,
    ),
    Achievement(
      id: 'full_arsenal',
      name: 'Full Arsenal',
      description: 'Own all skills',
      icon: '🏆',
      category: AchievementCategory.allSkills,
      threshold: 1,
    ),

    // Social (2)
    Achievement(
      id: 'team_players',
      name: 'Team Players',
      description: 'Both players complete 10 tasks each',
      icon: '🤝',
      category: AchievementCategory.team,
      threshold: 10,
    ),
    Achievement(
      id: 'perfect_game',
      name: 'Perfect Game',
      description: 'Both players complete 25 tasks each',
      icon: '💎',
      category: AchievementCategory.team,
      threshold: 25,
    ),

    // Special (1)
    Achievement(
      id: 'bookmark_master',
      name: 'Bookmark Master',
      description: 'Save a task for later 5 times',
      icon: '🔖',
      category: AchievementCategory.bookmark,
      threshold: 5,
    ),
  ];

  // ── Persistence ──

  static List<String> getUnlocked(int player) {
    final list = _box.get('player${player}_achievements', defaultValue: <String>[]);
    return List<String>.from(list);
  }

  static bool isUnlocked(int player, String id) =>
      getUnlocked(player).contains(id);

  static void unlock(int player, String id) {
    final list = getUnlocked(player);
    if (!list.contains(id)) {
      list.add(id);
      _box.put('player${player}_achievements', list);
    }
  }

  static int unlockedCount(int player) => getUnlocked(player).length;

  // ── Stats (per-player) ──

  static int getStat(int player, String key) =>
      _box.get('player${player}_stat_$key', defaultValue: 0);

  static void incrementStat(int player, String key) {
    _box.put('player${player}_stat_$key', getStat(player, key) + 1);
  }

  // ── Global stats (both players) ──

  static int getGlobalStat(String key) =>
      _box.get('global_stat_$key', defaultValue: 0);

  static void incrementGlobalStat(String key) {
    _box.put('global_stat_$key', getGlobalStat(key) + 1);
  }

  // ── Streak tracking ──

  static int getAcceptStreak(int player) => getStat(player, 'accept_streak');

  static void recordAccept(int player) {
    incrementStat(player, 'accept_streak');
    // Reset other player's streak
    final other = player == 1 ? 2 : 1;
    _box.put('player${other}_stat_accept_streak', 0);
  }

  static void recordSkip(int player) {
    _box.put('player${player}_stat_accept_streak', 0);
  }

  // ── Check & Unlock ──

  /// Check all achievements for a player after an event. Returns newly unlocked.
  static List<Achievement> check(int player) {
    final newlyUnlocked = <Achievement>[];

    for (final a in achievements) {
      if (isUnlocked(player, a.id)) continue;

      bool condition = false;

      switch (a.category) {
        case AchievementCategory.completion:
          final total = ProgressionService.totalCompleted;
          condition = total >= a.threshold;
          break;

        case AchievementCategory.category:
          final count = getStat(player, 'cat_${a.targetCategory}');
          condition = count >= a.threshold;
          break;

        case AchievementCategory.timed:
          final count = getStat(player, 'timed_completed');
          condition = count >= a.threshold;
          break;

        case AchievementCategory.skip:
          final count = getStat(player, 'skips');
          condition = count >= a.threshold;
          break;

        case AchievementCategory.shield:
          final count = getStat(player, 'shields_used');
          condition = count >= a.threshold;
          break;

        case AchievementCategory.streak:
          final streak = getAcceptStreak(player);
          condition = streak >= a.threshold;
          break;

        case AchievementCategory.doublePoints:
          final count = getStat(player, 'double_points_used');
          condition = count >= a.threshold;
          break;

        case AchievementCategory.shop:
          final count = getGlobalStat('total_purchases');
          condition = count >= a.threshold;
          break;

        case AchievementCategory.skills:
          final count = ShopService.getSkills(player).length;
          condition = count >= a.threshold;
          break;

        case AchievementCategory.allSkills:
          final skills = ShopService.getSkills(player);
          condition = skills.length >= 3; // quick_skip, bookmark, favorite
          break;

        case AchievementCategory.team:
          final p1 = getStat(1, 'tasks_completed');
          final p2 = getStat(2, 'tasks_completed');
          condition = p1 >= a.threshold && p2 >= a.threshold;
          break;

        case AchievementCategory.bookmark:
          final count = getStat(player, 'bookmarks_used');
          condition = count >= a.threshold;
          break;
      }

      if (condition) {
        unlock(player, a.id);
        newlyUnlocked.add(a);
      }
    }

    return newlyUnlocked;
  }

  // ── Convenience: record events and check ──

  /// Call after a task is accepted.
  static List<Achievement> recordAcceptance(int player, {
    required String categoryId,
    required bool isTimed,
  }) {
    incrementStat(player, 'tasks_completed');
    recordAccept(player);
    incrementStat(player, 'cat_$categoryId');
    if (isTimed) incrementStat(player, 'timed_completed');
    return check(player);
  }

  /// Call after a task is skipped.
  static List<Achievement> recordSkipEvent(int player) {
    incrementStat(player, 'skips');
    recordSkip(player);
    return check(player);
  }

  /// Call after Task Shield is used.
  static List<Achievement> recordShieldUse(int player) {
    incrementStat(player, 'shields_used');
    return check(player);
  }

  /// Call after Double Points is used.
  static List<Achievement> recordDoublePointsUse(int player) {
    incrementStat(player, 'double_points_used');
    return check(player);
  }

  /// Call after a shop purchase.
  static List<Achievement> recordPurchase(int player) {
    incrementGlobalStat('total_purchases');
    return check(player);
  }

  /// Call after Bookmark save.
  static List<Achievement> recordBookmark(int player) {
    incrementStat(player, 'bookmarks_used');
    return check(player);
  }
}

enum AchievementCategory {
  completion,
  category,
  timed,
  skip,
  shield,
  streak,
  doublePoints,
  shop,
  skills,
  allSkills,
  team,
  bookmark,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int threshold;
  final String? targetCategory;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.threshold,
    this.targetCategory,
  });
}
