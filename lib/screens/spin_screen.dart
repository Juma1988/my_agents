import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge_category.dart';
import '../models/challenge_segment.dart';
import '../data/task_loader.dart';
import '../data/category_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_card_wheel.dart';

import '../widgets/spin_button.dart';
import '../widgets/wheel_pointer.dart';

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
  bool _isDarkMode = true;

  // Settings
  bool _soundEffects = true;
  bool _hapticFeedback = true;

  // 2-Player state
  int _currentPlayer = 1;
  Map<int, int> _scores = {1: 0, 2: 0};
  Map<int, String> _nicknames = {1: 'Player 1', 2: 'Player 2'};
  Map<int, String> _avatars = {1: '😈', 2: '👿'};

  // State
  List<ChallengeCategory> _categories = [];
  List<String> _selectedCategoryIds = [];
  List<String> _selectedTiers = ['soft']; // default tiers

  // Hive box reference
  late Box _settingsBox;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await TaskLoader.loadCategories();

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
    // Validate all tiers exist
    _selectedTiers = _selectedTiers
        .where((t) => ['soft', 'kink', 'entertainment'].contains(t))
        .toList();
    if (_selectedTiers.isEmpty) {
      _selectedTiers = ['soft'];
    }

    // Load dark mode preference
    final savedDarkMode = _settingsBox.get('isDarkMode', defaultValue: true);
    if (savedDarkMode is bool) {
      _isDarkMode = savedDarkMode;
    }

    // Load sound effects preference
    final savedSoundEffects = _settingsBox.get('soundEffects', defaultValue: true);
    if (savedSoundEffects is bool) {
      _soundEffects = savedSoundEffects;
    }

    // Load haptic feedback preference
    final savedHapticFeedback = _settingsBox.get('hapticFeedback', defaultValue: true);
    if (savedHapticFeedback is bool) {
      _hapticFeedback = savedHapticFeedback;
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

    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  /// Save all settings to Hive
  void _saveSettings() {
    _settingsBox.put('selectedCategoryIds', _selectedCategoryIds);
    _settingsBox.put('selectedTiers', _selectedTiers);
    _settingsBox.put('isDarkMode', _isDarkMode);
    _settingsBox.put('soundEffects', _soundEffects);
    _settingsBox.put('hapticFeedback', _hapticFeedback);
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

  void _onDarkModeChanged(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _saveSettings();
  }

  void _onSoundEffectsChanged(bool value) {
    setState(() {
      _soundEffects = value;
    });
    _saveSettings();
  }

  void _onHapticFeedbackChanged(bool value) {
    setState(() {
      _hapticFeedback = value;
    });
    _saveSettings();
  }

  void _onPlayer1NicknameChanged(String value) {
    setState(() {
      _nicknames[1] = value;
    });
    _savePlayerData();
  }

  void _onPlayer2NicknameChanged(String value) {
    setState(() {
      _nicknames[2] = value;
    });
    _savePlayerData();
  }

  void _onPlayer1AvatarChanged(String value) {
    setState(() {
      _avatars[1] = value;
    });
    _savePlayerData();
  }

  void _onPlayer2AvatarChanged(String value) {
    setState(() {
      _avatars[2] = value;
    });
    _savePlayerData();
  }

  /// Toggle to the other player
  void _togglePlayer() {
    setState(() {
      _currentPlayer = _currentPlayer == 1 ? 2 : 1;
    });
    _savePlayerData();
  }

  void _handleSpin() {
    final activeCategories = _categories
        .where((c) => _selectedCategoryIds.contains(c.id))
        .toList();
    if (activeCategories.isEmpty) return;

    if (_hapticFeedback) {
      HapticFeedback.lightImpact();
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

      // Small delay so the final card settles before the sheet pops up
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
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
        onAccept: () {
          if (_hapticFeedback) {
            HapticFeedback.mediumImpact();
          }
          // Add points to current player
          setState(() {
            _scores[_currentPlayer] = (_scores[_currentPlayer] ?? 0) + task.points;
          });
          _savePlayerData();
          // Toggle to other player
          _togglePlayer();
          Navigator.of(context).pop();
        },
        onSkip: () {
          if (_hapticFeedback) {
            HapticFeedback.lightImpact();
          }
          // Toggle to other player
          _togglePlayer();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      endDrawer: AppDrawer(
        categories: _categories,
        selectedCategoryIds: _selectedCategoryIds,
        onSelectionChanged: _onCategorySelectionChanged,
        selectedTiers: _selectedTiers,
        onTierChanged: _onTierChanged,
        isDarkMode: _isDarkMode,
        onDarkModeChanged: _onDarkModeChanged,
        soundEffects: _soundEffects,
        onSoundEffectsChanged: _onSoundEffectsChanged,
        hapticFeedback: _hapticFeedback,
        onHapticFeedbackChanged: _onHapticFeedbackChanged,
        player1Nickname: _nicknames[1]!,
        player2Nickname: _nicknames[2]!,
        player1Avatar: _avatars[1]!,
        player2Avatar: _avatars[2]!,
        onPlayer1NicknameChanged: _onPlayer1NicknameChanged,
        onPlayer2NicknameChanged: _onPlayer2NicknameChanged,
        onPlayer1AvatarChanged: _onPlayer1AvatarChanged,
        onPlayer2AvatarChanged: _onPlayer2AvatarChanged,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: _isDarkMode
                      ? const Color(0xFF4ECDC4)
                      : const Color(0xFF2AB7AD),
                ),
              )
            : _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    final textColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.92)
        : const Color(0xFF1A1A2E);

    return Stack(
      children: [
        Column(
          children: [
            // Player toggle bar
            _buildPlayerToggle(),

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
                    onCenterChanged: (index) {
                      // Task changed in center
                    },
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
        ),

        // Menu button (top-right)
        Positioned(
          top: 8,
          right: 8,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: textColor,
                  size: 26,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
                splashRadius: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Player toggle bar at top of screen
  Widget _buildPlayerToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Player 1
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_currentPlayer != 1) {
                  if (_hapticFeedback) {
                    HapticFeedback.selectionClick();
                  }
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

          // VS separator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
            child: GestureDetector(
              onTap: () {
                if (_currentPlayer != 2) {
                  if (_hapticFeedback) {
                    HapticFeedback.selectionClick();
                  }
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
        ],
      ),
    );
  }

  Widget _buildPlayerCard({required int player, required bool isCurrent}) {
    final avatar = _avatars[player] ?? (player == 1 ? '😈' : '👿');
    final nickname = _nicknames[player] ?? 'Player $player';
    final score = _scores[player] ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFF4ECDC4).withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF4ECDC4).withValues(alpha: 0.6)
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
          Text(
            'Score: $score',
            style: GoogleFonts.inter(
              color: isCurrent
                  ? const Color(0xFF4ECDC4)
                  : Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
    required this.onAccept,
    required this.onSkip,
  });

  final ChallengeCategory category;
  final ChallengeSegment task;
  final VoidCallback onAccept;
  final VoidCallback onSkip;

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
                backgroundColor: const Color(0xFF4ECDC4),
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

          // Skip button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                _timer?.cancel();
                widget.onSkip();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Skip (-1 pt)',
                style: GoogleFonts.inter(
                  fontSize: 14,
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
