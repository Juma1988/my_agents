import 'package:hive/hive.dart';

/// Shop service — manages coins, purchases, and unlocks per player.
class ShopService {
  ShopService._();

  static Box get _box => Hive.box('settings');

  // ── Coins ──

  static int getCoins(int player) =>
      _box.get('player${player}_coins', defaultValue: 0);

  static void addCoins(int player, int amount) {
    _box.put('player${player}_coins', getCoins(player) + amount);
  }

  static bool spendCoins(int player, int amount) {
    final current = getCoins(player);
    if (current < amount) return false;
    _box.put('player${player}_coins', current - amount);
    return true;
  }

  // ── Purchases (consumables) ──

  static List<String> getInventory(int player) {
    final list = _box.get('player${player}_inventory', defaultValue: <String>[]);
    return List<String>.from(list);
  }

  static void addToInventory(int player, String itemId) {
    final inv = getInventory(player);
    inv.add(itemId);
    _box.put('player${player}_inventory', inv);
  }

  static bool consumeItem(int player, String itemId) {
    final inv = getInventory(player);
    final idx = inv.indexOf(itemId);
    if (idx == -1) return false;
    inv.removeAt(idx);
    _box.put('player${player}_inventory', inv);
    return true;
  }

  static bool hasItem(int player, String itemId) =>
      getInventory(player).contains(itemId);

  // ── Skills (permanent unlocks) ──

  static List<String> getSkills(int player) {
    final list = _box.get('player${player}_skills', defaultValue: <String>[]);
    return List<String>.from(list);
  }

  static void unlockSkill(int player, String skillId) {
    final skills = getSkills(player);
    if (!skills.contains(skillId)) {
      skills.add(skillId);
      _box.put('player${player}_skills', skills);
    }
  }

  static bool hasSkill(int player, String skillId) =>
      getSkills(player).contains(skillId);

  // ── Cosmetics (visual unlocks) ──

  static List<String> getCosmetics(int player) {
    final list = _box.get('player${player}_cosmetics', defaultValue: <String>[]);
    return List<String>.from(list);
  }

  static void unlockCosmetic(int player, String cosmeticId) {
    final cosmetics = getCosmetics(player);
    if (!cosmetics.contains(cosmeticId)) {
      cosmetics.add(cosmeticId);
      _box.put('player${player}_cosmetics', cosmetics);
    }
  }

  static bool hasCosmetic(int player, String cosmeticId) =>
      getCosmetics(player).contains(cosmeticId);

  // ── Purchase Flow ──

  /// Attempt to purchase an item. Returns true if successful.
  static bool purchase(int player, ShopItem item) {
    // Check if already owned (skills/cosmetics)
    if (item.type == ShopItemType.skill && hasSkill(player, item.id)) return false;
    if (item.type == ShopItemType.cosmetic && hasCosmetic(player, item.id)) return false;

    // Spend coins
    if (!spendCoins(player, item.price)) return false;

    // Grant item
    switch (item.type) {
      case ShopItemType.consumable:
        addToInventory(player, item.id);
        break;
      case ShopItemType.skill:
        unlockSkill(player, item.id);
        break;
      case ShopItemType.powerup:
        addToInventory(player, item.id);
        break;
      case ShopItemType.cosmetic:
        unlockCosmetic(player, item.id);
        break;
    }
    return true;
  }
}

enum ShopItemType { consumable, skill, powerup, cosmetic }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int price;
  final ShopItemType type;
  final bool Function(int player)? isAvailable;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    required this.type,
    this.isAvailable,
  });
}

/// All shop items.
class ShopCatalog {
  ShopCatalog._();

  static const List<ShopItem> consumables = [
    ShopItem(
      id: 'extra_spin',
      name: 'Extra Spin',
      description: 'Spin again without waiting',
      icon: '🎰',
      price: 3,
      type: ShopItemType.consumable,
    ),
    ShopItem(
      id: 'double_points',
      name: 'Double Points',
      description: 'Next task gives 2x points',
      icon: '✨',
      price: 5,
      type: ShopItemType.consumable,
    ),
    ShopItem(
      id: 'task_shield',
      name: 'Task Shield',
      description: 'One free skip with no cooldown',
      icon: '🛡️',
      price: 4,
      type: ShopItemType.consumable,
    ),
  ];

  static const List<ShopItem> skills = [
    ShopItem(
      id: 'quick_skip',
      name: 'Quick Skip',
      description: 'Skip cooldown 10 → 3 rounds',
      icon: '⚡',
      price: 15,
      type: ShopItemType.skill,
    ),
    ShopItem(
      id: 'bookmark',
      name: 'Bookmark',
      description: 'Save task for later',
      icon: '🔖',
      price: 20,
      type: ShopItemType.skill,
    ),
    ShopItem(
      id: 'favorite',
      name: 'Favorite',
      description: 'Mark tasks to always appear',
      icon: '⭐',
      price: 10,
      type: ShopItemType.skill,
    ),
  ];

  static const List<ShopItem> powerups = [
    ShopItem(
      id: 'forced_task',
      name: 'Forced Task',
      description: 'Opponent must do a specific category next spin',
      icon: '🎯',
      price: 8,
      type: ShopItemType.powerup,
    ),
    ShopItem(
      id: 'tier_lock',
      name: 'Tier Lock',
      description: 'Force opponent into a specific tier next spin',
      icon: '🔒',
      price: 6,
      type: ShopItemType.powerup,
    ),
    ShopItem(
      id: 'score_steal',
      name: 'Score Steal',
      description: 'Steal 3 points from opponent',
      icon: '💸',
      price: 10,
      type: ShopItemType.powerup,
    ),
  ];

  static const List<ShopItem> cosmetics = [
    ShopItem(
      id: 'custom_wheel',
      name: 'Custom Wheel',
      description: 'Custom wheel colors',
      icon: '🎨',
      price: 5,
      type: ShopItemType.cosmetic,
    ),
    ShopItem(
      id: 'premium_avatars',
      name: 'Premium Avatars',
      description: 'Custom avatars beyond defaults',
      icon: '👑',
      price: 3,
      type: ShopItemType.cosmetic,
    ),
    ShopItem(
      id: 'spin_themes',
      name: 'Spin Themes',
      description: 'Animated spin button themes',
      icon: '💫',
      price: 7,
      type: ShopItemType.cosmetic,
    ),
  ];

  static List<ShopItem> get all =>
      [...consumables, ...skills, ...powerups, ...cosmetics];

  static ShopItem? findById(String id) {
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
