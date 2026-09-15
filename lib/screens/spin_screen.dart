import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge_category.dart';
import '../models/challenge_segment.dart';
import '../data/task_loader.dart';
import '../data/category_colors.dart';
import '../data/sound_service.dart';
import '../data/history_service.dart';
import '../data/progression_service.dart';
import '../data/shop_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_card_wheel.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/dev_overlay.dart';
import '../theme/app_colors.dart';

import '../widgets/spin_button.dart';
import '../widgets/wheel_pointer.dart';
import 'onboarding_screen.dart';
import 'timer_screen.dart';

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<CategoryCardWheelState> _wheelKey = GlobalKey();
  bool _isSpinning = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // Settings
  final bool _hapticFeedback = true;

  // 2-Player state
  int _currentPlayer = 1;
  Map<int, int> _scores = {1: 0, 2: 0};
  Map<int, String> _nicknames = {1: 'Player 1', 2: 'Player 2'};
  Map<int, String> _avatars = {1: '😈', 2: '👿'};

  // Skip cooldown (per-player, persists in Hive)
  static const int _skipCooldownMax = 10;
  static const int _skipCooldownQuickSkip = 3;
  Map<int, int> _skipCooldowns = {1: 0, 2: 0};

  // Save for Later (Bookmark skill, per-player, persists in Hive)
  static const int _saveCooldownMax = 5;
  static const int _saveMaxQueued = 3;
  Map<int, int> _saveCooldowns = {1: 0, 2: 0};
  Map<int, List<Map<String, dynamic>>> _savedTasks = {1: [], 2: []};

  // Session tracking (resets on full app close)
  late Map<int, int> _sessionStartScores;

  // State
  List<ChallengeCategory> _categories = [];
  List<String> _selectedCategoryIds = [];
  List<String> _selectedTiers = ['soft']; // default tiers

  // Hive box reference
  late Box _settingsBox;

  @override
  void initState() {
    super.initState();
    DevOverlay.currentFilePath = 'lib/screens/spin_screen.dart';
    _settingsBox = Hive.box('settings');
    _loadCategories();
    _checkOnboarding();
  }

  void _checkOnboarding() async {
    if (await OnboardingScreen.shouldShow()) {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const OnboardingScreen(),
        ),
      );
    }
  }

  Future<void> _loadCategories() async {
    final result = await TaskLoader.loadCategoriesWithRetry();

    if (!result.isSuccess) {
      setState(() {
        _hasError = true;
        _errorMessage = result.errorMessage;
        _isLoading = false;
      });
      return;
    }

    final categories = result.categories;

    // Load saved selected category IDs from Hive
    final savedIds = _settingsBox.get('selectedCategoryIds', defaultValue: null);
    if (savedIds != null && savedIds is List) {
      _selectedCategoryIds = List<String>.from(savedIds.cast<String>());
    } else {
      // Default: select all categories
      _selectedCategoryIds = categories.map((c) => c.id).toList();
    }

    // Ensure at least 1 category is selected
    if (_selectedCategoryIds.isEmpty && categories.isNotEmpty) {
      _selectedCategoryIds = [categories.first.id];
    }

    // Load saved tiers from Hive
    final savedTiers = _settingsBox.get('selectedTiers', defaultValue: null);
    if (savedTiers != null && savedTiers is List) {
      _selectedTiers = List<String>.from(savedTiers.cast<String>());
    }
    // Ensure at least 1 tier is selected
    if (_selectedTiers.isEmpty) {
      _selectedTiers = ['soft'];
    }
    // Validate all tiers exist and are unlocked
    _selectedTiers = _selectedTiers
        .where((t) => ['soft', 'kink', 'entertainment'].contains(t) && ProgressionService.isTierUnlocked(t))
        .toList();
    if (_selectedTiers.isEmpty) {
      _selectedTiers = ['soft'];
    }

    // Load player data from Hive
    _currentPlayer = _settingsBox.get('current_player', defaultValue: 1) as int;
    _scores = {
      1: _settingsBox.get('player1_score', defaultValue: 0) as int,
      2: _settingsBox.get('player2_score', defaultValue: 0) as int,
    };
    _nicknames = {
      1: _settingsBox.get('player1_nickname', defaultValue: 'Player 1') as String,
      2: _settingsBox.get('player2_nickname', defaultValue: 'Player 2') as String,
    };
    _avatars = {
      1: _settingsBox.get('player1_avatar', defaultValue: '😈') as String,
      2: _settingsBox.get('player2_avatar', defaultValue: '👿') as String,
    };

    // Load skip cooldowns from Hive
    _skipCooldowns = {
      1: _settingsBox.get('player1_skip_cooldown', defaultValue: 0) as int,
      2: _settingsBox.get('player2_skip_cooldown', defaultValue: 0) as int,
    };

    // Load saved tasks from Hive
    for (final p in [1, 2]) {
      final raw = _settingsBox.get('player${p}_saved_tasks', defaultValue: null);
      if (raw != null && raw is List) {
        _savedTasks[p] = List<Map<String, dynamic>>.from(
          raw.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      } else {
        _savedTasks[p] = [];
      }
    }
    _saveCooldowns = {
      1: _settingsBox.get('player1_save_cooldown', defaultValue: 0) as int,
      2: _settingsBox.get('player2_save_cooldown', defaultValue: 0) as int,
    };

    setState(() {
      _categories = categories;
      _isLoading = false;
      // Snapshot scores at session start for delta calculation
      _sessionStartScores = Map<int, int>.from(_scores);
    });
  }

  /// Save all settings to Hive
  void _saveSettings() {
    _settingsBox.put('selectedCategoryIds', _selectedCategoryIds);
    _settingsBox.put('selectedTiers', _selectedTiers);
    _savePlayerData();
  }

  void _savePlayerData() {
    _settingsBox.put('current_player', _currentPlayer);
    _settingsBox.put('player1_score', _scores[1]);
    _settingsBox.put('player2_score', _scores[2]);
    _settingsBox.put('player1_nickname', _nicknames[1]);
    _settingsBox.put('player2_nickname', _nicknames[2]);
    _settingsBox.put('player1_avatar', _avatars[1]);
    _settingsBox.put('player2_avatar', _avatars[2]);
    _settingsBox.put('player1_skip_cooldown', _skipCooldowns[1]);
    _settingsBox.put('player2_skip_cooldown', _skipCooldowns[2]);
    _settingsBox.put('player1_saved_tasks', _savedTasks[1]);
    _settingsBox.put('player2_saved_tasks', _savedTasks[2]);
    _settingsBox.put('player1_save_cooldown', _saveCooldowns[1]);
    _settingsBox.put('player2_save_cooldown', _saveCooldowns[2]);
  }

  void _onCategorySelectionChanged(List<String> newSelection) {
    setState(() {
      _selectedCategoryIds = newSelection;
    });
    _saveSettings();
  }

  void _onTierChanged(List<String> tiers) {
    setState(() {
      _selectedTiers = tiers;
    });
    _saveSettings();
  }

  /// Save current task for later (Bookmark skill)
  void _saveTaskForLater(ChallengeCategory category, ChallengeSegment task) {
    final player = _currentPlayer;
    final queue = _savedTasks[player] ?? [];

    // Check: Bookmark skill owned?
    if (!ShopService.hasSkill(player, 'bookmark')) return;
    // Check: cooldown active?
    if ((_saveCooldowns[player] ?? 0) > 0) return;
    // Check: queue full?
    if (queue.length >= _saveMaxQueued) return;

    queue.add({
      'categoryId': category.id,
      'categoryName': category.name,
      'categoryIcon': category.icon,
      'taskId': task.id,
      'taskText': task.text,
      'taskPoints': task.points,
      'hasTimer': task.hasTimer,
      'timerSeconds': task.timerSeconds,
      'tier': _selectedTiers.first,
    });

    setState(() {
      _savedTasks[player] = queue;
      _saveCooldowns[player] = _saveCooldownMax;
    });
    _savePlayerData();
  }

  /// Check if player has saved tasks pending
  bool _hasSavedTasks() {
    return (_savedTasks[_currentPlayer]?.isNotEmpty ?? false);
  }

  /// Show saved tasks queue before spinning
  void _showSavedTasksQueue() {
    final queue = _savedTasks[_currentPlayer] ?? [];
    if (queue.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SavedTasksSheet(
        savedTasks: queue,
        playerName: _nicknames[_currentPlayer]!,
        onAcceptAll: () {
          Navigator.of(context).pop();
          _startNextSavedTask();
        },
        onSkipAll: () {
          Navigator.of(context).pop();
          _skipAllSavedTasks();
        },
      ),
    );
  }

  /// Start the first saved task in the queue
  void _startNextSavedTask() {
    final queue = _savedTasks[_currentPlayer] ?? [];
    if (queue.isEmpty) {
      // No saved tasks, proceed to spin
      _handleSpin();
      return;
    }

    final saved = queue.removeAt(0);
    setState(() {
      _savedTasks[_currentPlayer] = queue;
    });
    _savePlayerData();

    // Find the category to show the task
    final category = _categories.firstWhere(
      (c) => c.id == saved['categoryId'],
      orElse: () => _categories.first,
    );
    final task = ChallengeSegment(
      id: saved['taskId'],
      text: saved['taskText'],
      points: saved['taskPoints'],
      timerSeconds: saved['timerSeconds'],
    );

    _showTaskBottomSheet(category, task);
  }

  /// Skip all saved tasks (counts as multiple skips on cooldown)
  void _skipAllSavedTasks() {
    final queue = _savedTasks[_currentPlayer] ?? [];
    if (queue.isEmpty) return;

    final player = _currentPlayer;
    final playerName = _nicknames[player]!;

    // Each skipped saved task is a penalty + history entry
    int totalPenalty = 0;
    for (final saved in queue) {
      final points = saved['taskPoints'] as int;
      totalPenalty += points;

      HistoryService.record(
        taskId: saved['taskId'],
        categoryId: saved['categoryId'],
        categoryName: saved['categoryName'],
        categoryIcon: saved['categoryIcon'],
        tier: saved['tier'],
        taskText: saved['taskText'],
        points: points,
        accepted: false,
        player: player,
        playerName: playerName,
      );
    }

    setState(() {
      _scores[player] = (_scores[player] ?? 0) - totalPenalty;
      _savedTasks[player] = [];
      // Skip cooldown applies (multiple skips = one cooldown)
      final hasQuickSkip = ShopService.hasSkill(player, 'quick_skip');
      _skipCooldowns[player] = hasQuickSkip ? _skipCooldownQuickSkip : _skipCooldownMax;
    });
    _savePlayerData();
    _showFloatingScore(totalPenalty, isAccept: false);
  }

  /// Toggle to the other player
  void _togglePlayer() {
    // Decrement cooldowns for the player whose turn just ended
    final endingPlayer = _currentPlayer;
    if ((_skipCooldowns[endingPlayer] ?? 0) > 0) {
      _skipCooldowns[endingPlayer] = _skipCooldowns[endingPlayer]! - 1;
    }
    if ((_saveCooldowns[endingPlayer] ?? 0) > 0) {
      _saveCooldowns[endingPlayer] = _saveCooldowns[endingPlayer]! - 1;
    }
    setState(() {
      _currentPlayer = _currentPlayer == 1 ? 2 : 1;
    });
    _savePlayerData();
  }

  void _handleSpin() {
    // Check for saved tasks first
    if (_hasSavedTasks()) {
      _showSavedTasksQueue();
      return;
    }

    final activeCategories = _categories
        .where((c) => _selectedCategoryIds.contains(c.id))
        .toList();
    if (activeCategories.isEmpty) return;

    if (_hapticFeedback) {
      SoundService.tap();
    }
    setState(() {
      _isSpinning = true;
    });

    // Spin wheel — it returns the exact task when it stops
    _wheelKey.currentState?.rollToRandom().then((taskItem) {
      if (!mounted || taskItem == null) {
        setState(() {
          _isSpinning = false;
        });
        return;
      }

      setState(() {
        _isSpinning = false;
      });
      SoundService.wheelLand();

      // Small delay so the final card settles before the sheet pops up
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        SoundService.taskRevealed();
        _showTaskBottomSheet(taskItem.category, taskItem.task);
      });
    });
  }

  /// Show a bottom sheet with the full task details, accept/skip buttons, and timer.
  void _showTaskBottomSheet(
      ChallengeCategory category, ChallengeSegment task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskDetailSheet(
        category: category,
        task: task,
        skipCooldown: _skipCooldowns[_currentPlayer] ?? 0,
        canSave: ShopService.hasSkill(_currentPlayer, 'bookmark'),
        saveCooldown: _saveCooldowns[_currentPlayer] ?? 0,
        onSave: () {
          SoundService.tap();
          Navigator.of(context).pop();
          _saveTaskForLater(category, task);
          // Player spins again immediately
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _handleSpin();
          });
        },
        onAccept: () {
          SoundService.accept();
          // Close the bottom sheet first
          Navigator.of(context).pop();

          // Check for Double Points consumable
          final hasDoublePoints = ShopService.hasItem(_currentPlayer, 'double_points');
          final effectivePoints = hasDoublePoints ? task.points * 2 : task.points;
          if (hasDoublePoints) {
            ShopService.consumeItem(_currentPlayer, 'double_points');
          }

          if (task.hasTimer) {
            // Navigate to the full-screen timer for timed tasks
            Navigator.of(context)
                .push<TimerResult>(
              MaterialPageRoute(
                builder: (_) => TimerScreen(
                  taskText: task.text,
                  timerSeconds: task.timerSeconds!,
                  points: task.points,
                  categoryName: category.name,
                  categoryIcon: category.icon,
                ),
              ),
            )
                .then((result) {
              if (!mounted) return;
              if (result != null && result.completed) {
                // User completed the task — award points and toggle
                setState(() {
                  _scores[_currentPlayer] =
                      (_scores[_currentPlayer] ?? 0) + effectivePoints;
                });
                _savePlayerData();
                _showFloatingScore(effectivePoints, isAccept: true);
                ShopService.addCoins(_currentPlayer, effectivePoints);
                _togglePlayer();
                // Record history
                HistoryService.record(
                  taskId: task.id,
                  categoryId: category.id,
                  categoryName: category.name,
                  categoryIcon: category.icon,
                  tier: _selectedTiers.first,
                  taskText: task.text,
                  points: effectivePoints,
                  accepted: true,
                  player: _currentPlayer == 1 ? 2 : 1, // toggled already
                  playerName: _nicknames[_currentPlayer == 1 ? 2 : 1]!,
                );
                ProgressionService.recordCompletion();
                // Confetti celebration
                if (mounted) {
                  SoundService.celebration();
                  ConfettiOverlay.show(context);
                }
              }
              // Cancel: no points, no toggle
            });
          } else {
            // Non-timed task: award points immediately
            setState(() {
              _scores[_currentPlayer] =
                  (_scores[_currentPlayer] ?? 0) + effectivePoints;
            });
            _savePlayerData();
            _showFloatingScore(effectivePoints, isAccept: true);
            // Record history (before toggle)
            final completedBy = _currentPlayer;
            final completedByName = _nicknames[_currentPlayer]!;
            ShopService.addCoins(_currentPlayer, effectivePoints);
            _togglePlayer();
            HistoryService.record(
              taskId: task.id,
              categoryId: category.id,
              categoryName: category.name,
              categoryIcon: category.icon,
              tier: _selectedTiers.first,
              taskText: task.text,
              points: task.points,
              accepted: true,
              player: completedBy,
              playerName: completedByName,
            );
            ProgressionService.recordCompletion();
            // Confetti celebration
            if (mounted) {
              SoundService.celebration();
              ConfettiOverlay.show(context);
            }
          }
        },
        onSkip: () {
          SoundService.skip();
          // Penalty = task.points, same player rolls again (no toggle)
          final skippedBy = _currentPlayer;
          final skippedByName = _nicknames[_currentPlayer]!;

          // Check for Task Shield — free skip, no cooldown
          final hasShield = ShopService.hasItem(skippedBy, 'task_shield');
          if (hasShield) {
            ShopService.consumeItem(skippedBy, 'task_shield');
          }

          setState(() {
            if (!hasShield) {
              _scores[_currentPlayer] = (_scores[_currentPlayer] ?? 0) - task.points;
            }
            // Set skip cooldown — Quick Skip skill reduces from 10 to 3
            final hasQuickSkip = ShopService.hasSkill(skippedBy, 'quick_skip');
            _skipCooldowns[skippedBy] = hasQuickSkip ? _skipCooldownQuickSkip : _skipCooldownMax;
          });
          _savePlayerData();
          // Record history
          HistoryService.record(
            taskId: task.id,
            categoryId: category.id,
            categoryName: category.name,
            categoryIcon: category.icon,
            tier: _selectedTiers.first,
            taskText: task.text,
            points: task.points,
            accepted: false,
            player: skippedBy,
            playerName: skippedByName,
          );
          // Show skip animation
          _showFloatingScore(task.points, isAccept: false);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Show floating score animation (+X or -X)
  void _showFloatingScore(int points, {required bool isAccept}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: 0,
        right: 0,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: -60),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) {
              return Opacity(
                opacity: (1.0 + value / 60).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, value),
                  child: Text(
                    '${isAccept ? "+" : "-"}$points',
                    style: TextStyle(
                      color: isAccept ? AppColors.accent : AppColors.timerWarning,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 900), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: AppDrawer(
        categories: _categories,
        selectedCategoryIds: _selectedCategoryIds,
        onSelectionChanged: _onCategorySelectionChanged,
        selectedTiers: _selectedTiers,
        onTierChanged: _onTierChanged,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              )
            : _hasError
                ? _buildErrorState()
                : _buildMainContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white24,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load tasks',
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _errorMessage = null;
                });
                _loadCategories();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final textColor = Colors.white.withValues(alpha: 0.92);

    return Column(
      children: [
        // Player toggle bar (includes menu button)
        _buildPlayerToggle(textColor),

        // Card stack with pointer
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Task wheel
              CategoryCardWheel(
                key: _wheelKey,
                categories: _categories,
                selectedCategoryIds: _selectedCategoryIds,
                selectedTiers: _selectedTiers,
                onCenterChanged: (text) {},
              ),
              // Pointer at bottom
              Positioned(
                bottom: 20,
                child: Transform.rotate(
                  angle: 0,
                  child: const WheelPointer(),
                ),
              ),
            ],
          ),
        ),

        // Spin button
        SpinButton(
          isSpinning: _isSpinning,
          onPressed: _handleSpin,
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  /// Player toggle bar at top of screen (includes menu button)
  Widget _buildPlayerToggle(Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Player 1
            Expanded(
              child: Semantics(
                label: 'Player 1, ${_nicknames[1]}, ${_scores[1]} points',
                button: true,
                child: GestureDetector(
                  onTap: () {
                    if (_currentPlayer != 1) {
                      SoundService.select();
                      setState(() {
                        _currentPlayer = 1;
                      });
                      _savePlayerData();
                    }
                  },
                  child: _buildPlayerCard(
                    player: 1,
                    isCurrent: _currentPlayer == 1,
                  ),
                ),
              ),
            ),

            // VS separator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'VS',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Player 2
            Expanded(
              child: Semantics(
                label: 'Player 2, ${_nicknames[2]}, ${_scores[2]} points',
                button: true,
                child: GestureDetector(
                  onTap: () {
                    if (_currentPlayer != 2) {
                      SoundService.select();
                      setState(() {
                        _currentPlayer = 2;
                      });
                      _savePlayerData();
                    }
                  },
                  child: _buildPlayerCard(
                    player: 2,
                    isCurrent: _currentPlayer == 2,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Menu button (right side)
            Semantics(
              label: 'Open menu',
              button: true,
              child: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: textColor,
                  size: 24,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
                splashRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard({required int player, required bool isCurrent}) {
    final avatar = _avatars[player] ?? (player == 1 ? '😈' : '👿');
    final nickname = _nicknames[player] ?? 'Player $player';
    final score = _scores[player] ?? 0;
    final coins = ShopService.getCoins(player);
    final sessionStart = _sessionStartScores[player] ?? 0;
    final delta = score - sessionStart;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.accent.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? AppColors.accent.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.1),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(avatar, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  nickname,
                  style: GoogleFonts.inter(
                    color: isCurrent
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: GoogleFonts.inter(
                  color: isCurrent
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (delta != 0) ...[
                const SizedBox(width: 4),
                Text(
                  '(${delta > 0 ? '+' : ''}$delta)',
                  style: GoogleFonts.inter(
                    color: delta > 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🪙 $coins',
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet shown when a task is selected from the wheel.
class _TaskDetailSheet extends StatefulWidget {
  const _TaskDetailSheet({
    required this.category,
    required this.task,
    required this.skipCooldown,
    required this.onAccept,
    required this.onSkip,
    this.onSave,
    this.saveCooldown = 0,
    this.canSave = false,
  });

  final ChallengeCategory category;
  final ChallengeSegment task;
  final int skipCooldown;
  final VoidCallback onAccept;
  final VoidCallback onSkip;
  final VoidCallback? onSave;
  final int saveCooldown;
  final bool canSave;

  @override
  State<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _timerExpired = false;
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();
    if (widget.task.hasTimer) {
      _remainingSeconds = widget.task.timerSeconds!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!widget.task.hasTimer || _timerStarted) return;
    _timerStarted = true;
    _remainingSeconds = widget.task.timerSeconds!;
    _timerExpired = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _timerExpired = true;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = CategoryColors.get(widget.category.id);
    final totalSeconds = widget.task.timerSeconds ?? 0;
    final progress = totalSeconds > 0 && _timerStarted
        ? _remainingSeconds / totalSeconds
        : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF252542),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Category icon + name with color accent
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.category.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.category.name.toUpperCase(),
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // TASK label
          Text(
            'TASK',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),

          // Task text (full, not truncated)
          Text(
            widget.task.text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Timer display (if task has timer)
          if (widget.task.hasTimer) ...[
            const SizedBox(height: 8),
            _timerStarted
                ? Column(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _timerExpired
                                      ? Colors.redAccent
                                      : const Color(0xFFFF8C42),
                                ),
                              ),
                            ),
                            Text(
                              _timerExpired
                                  ? "Time's up!"
                                  : _formatTime(_remainingSeconds),
                              style: GoogleFonts.inter(
                                color: _timerExpired
                                    ? Colors.redAccent
                                    : Colors.white,
                                fontSize: _timerExpired ? 12 : 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: _startTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C42).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF8C42),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Color(0xFFFF8C42),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Start Timer: ${_formatTime(totalSeconds)}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFF8C42),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
          ],

          // Points row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat(
                  'Points', '+${widget.task.points} pts', Colors.greenAccent),
              if (widget.task.hasTimer && !_timerStarted) ...[
                const SizedBox(width: 32),
                _buildStat(
                  'Timer',
                  _formatTime(widget.task.timerSeconds!),
                  Colors.orangeAccent,
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),

          // Accept button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                widget.onAccept();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                'Accept Challenge',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Save for Later button (Bookmark skill)
          if (widget.canSave) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: widget.saveCooldown > 0
                    ? null
                    : () {
                        _timer?.cancel();
                        widget.onSave?.call();
                      },
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: Text(
                  widget.saveCooldown > 0
                      ? 'Save for Later (${widget.saveCooldown} rounds)'
                      : 'Save for Later',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.saveCooldown > 0
                      ? Colors.white24
                      : const Color(0xFFFFB300),
                  side: BorderSide(
                    color: widget.saveCooldown > 0
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFFFB300).withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Skip button
          Builder(
            builder: (context) {
              final cooldown = widget.skipCooldown;
              final onCooldown = cooldown > 0;
              final skipLabel = onCooldown
                  ? 'Skip ($cooldown round${cooldown == 1 ? '' : 's'} left)'
                  : 'Skip (-${widget.task.points} pt${widget.task.points == 1 ? '' : 's'})';

              return SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: onCooldown
                      ? null
                      : () {
                          _timer?.cancel();
                          widget.onSkip();
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: onCooldown ? Colors.white24 : Colors.white70,
                    side: BorderSide(
                      color: onCooldown
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    skipLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet showing saved tasks queue.
class _SavedTasksSheet extends StatelessWidget {
  const _SavedTasksSheet({
    required this.savedTasks,
    required this.playerName,
    required this.onAcceptAll,
    required this.onSkipAll,
  });

  final List<Map<String, dynamic>> savedTasks;
  final String playerName;
  final VoidCallback onAcceptAll;
  final VoidCallback onSkipAll;

  @override
  Widget build(BuildContext context) {
    final totalPoints = savedTasks.fold<int>(
        0, (sum, t) => sum + (t['taskPoints'] as int));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF252542),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Text(
            '🔖 $playerName\'s Saved Tasks',
            style: GoogleFonts.inter(
              color: const Color(0xFFFFB300),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${savedTasks.length} task${savedTasks.length == 1 ? '' : 's'} · $totalPoints pts total',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Task list
          ...savedTasks.map((task) {
            final pts = task['taskPoints'] as int;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${task['categoryIcon']}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['taskText'] as String,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+$pts pts',
                          style: GoogleFonts.inter(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Accept all button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onAcceptAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                'Complete Saved Tasks',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Skip all button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onSkipAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white54,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Skip All (−$totalPoints pts + cooldown)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
