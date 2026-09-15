import 'package:hive/hive.dart';

/// Stores task history (accept/skip events) in a dedicated Hive box.
/// Max 200 entries (FIFO — oldest removed when limit reached).
class HistoryService {
  HistoryService._();

  static const String _boxName = 'history';
  static const String _favoritesKey = 'favorites';
  static const int _maxEntries = 200;

  static Box get _box => Hive.box(_boxName);

  /// Open the history box. Call once at app startup.
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  // ── History entries ──

  /// Record a task event (accept or skip).
  static void record({
    required String taskId,
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    required String tier,
    required String taskText,
    required int points,
    required bool accepted, // true = accept, false = skip
    required int player, // 1 or 2
    required String playerName,
  }) {
    final entry = {
      'taskId': taskId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'tier': tier,
      'taskText': taskText,
      'points': points,
      'accepted': accepted,
      'player': player,
      'playerName': playerName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final entries = getEntries();
    entries.insert(0, entry); // newest first

    // FIFO: trim to max
    if (entries.length > _maxEntries) {
      entries.removeRange(_maxEntries, entries.length);
    }

    _box.put('entries', entries);
  }

  /// Get all history entries (newest first).
  static List<Map<String, dynamic>> getEntries() {
    final raw = _box.get('entries', defaultValue: []);
    return List<Map<String, dynamic>>.from(
      (raw as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  /// Get entries filtered by type.
  static List<Map<String, dynamic>> getFiltered({
    String? filter, // 'accepted', 'skipped', or null for all
    String? categoryId,
  }) {
    var entries = getEntries();

    if (filter == 'accepted') {
      entries = entries.where((e) => e['accepted'] == true).toList();
    } else if (filter == 'skipped') {
      entries = entries.where((e) => e['accepted'] == false).toList();
    }

    if (categoryId != null) {
      entries = entries.where((e) => e['categoryId'] == categoryId).toList();
    }

    return entries;
  }

  /// Clear all history.
  static void clearAll() {
    _box.delete('entries');
  }

  // ── Favorites ──

  /// Get set of favorited task IDs.
  static Set<String> getFavorites() {
    final raw = _box.get(_favoritesKey, defaultValue: []);
    return Set<String>.from((raw as List).cast<String>());
  }

  /// Toggle favorite status for a task.
  static bool toggleFavorite(String taskId) {
    final favorites = getFavorites();
    if (favorites.contains(taskId)) {
      favorites.remove(taskId);
    } else {
      favorites.add(taskId);
    }
    _box.put(_favoritesKey, favorites.toList());
    return favorites.contains(taskId);
  }

  /// Check if a task is favorited.
  static bool isFavorite(String taskId) {
    return getFavorites().contains(taskId);
  }

  /// Check if a task has been completed (accepted) by any player.
  static bool isCompleted(String taskId) {
    final entries = getEntries();
    return entries.any((e) => e['taskId'] == taskId && e['accepted'] == true);
  }

  /// Check if a task has been seen (accepted or skipped).
  static bool isSeen(String taskId) {
    final entries = getEntries();
    return entries.any((e) => e['taskId'] == taskId);
  }

  /// Get completion count for a task.
  static int completionCount(String taskId) {
    final entries = getEntries();
    return entries.where((e) => e['taskId'] == taskId && e['accepted'] == true).length;
  }
}
