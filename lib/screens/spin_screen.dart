import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge_category.dart';
import '../models/challenge_segment.dart';
import '../data/task_loader.dart';
import '../data/category_colors.dart';
import '../widgets/category_card_wheel.dart';
import '../widgets/category_chip_selector.dart';
import '../widgets/score_bar.dart';
import '../widgets/spin_button.dart';
import '../widgets/wheel_pointer.dart';

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> {
  final GlobalKey<CategoryCardWheelState> _wheelKey = GlobalKey();
  bool _isSpinning = false;
  bool _isLoading = true;

  // State
  List<ChallengeCategory> _categories = [];
  List<String> _selectedCategoryIds = [];
  String _selectedTier = 'soft'; // default tier

  int _score = 0;

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

    // Load saved tier from Hive
    final savedTier = _settingsBox.get('selectedTier', defaultValue: 'soft');
    if (savedTier is String &&
        ['soft', 'kink', 'entertainment'].contains(savedTier)) {
      _selectedTier = savedTier;
    }

    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  /// Save selected category IDs and tier to Hive
  void _saveSettings() {
    _settingsBox.put('selectedCategoryIds', _selectedCategoryIds);
    _settingsBox.put('selectedTier', _selectedTier);
  }

  void _onCategorySelectionChanged(List<String> newSelection) {
    setState(() {
      _selectedCategoryIds = newSelection;
    });
    _saveSettings();
  }

  void _onTierChanged(String tier) {
    setState(() {
      _selectedTier = tier;
    });
    _saveSettings();
  }

  void _handleSpin() {
    final activeCategories = _categories
        .where((c) => _selectedCategoryIds.contains(c.id))
        .toList();
    if (activeCategories.isEmpty) return;

    HapticFeedback.lightImpact();
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

      // Show the task detail bottom sheet
      _showTaskBottomSheet(taskItem.category, taskItem.task);
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
          HapticFeedback.mediumImpact();
          setState(() {
            _score += task.points;
          });
          Navigator.of(context).pop();
        },
        onSkip: () {
          HapticFeedback.lightImpact();
          setState(() {
            _score -= 1;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
              )
            : _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Score bar
        ScoreBar(score: _score),

        // Category chip selector (top bar)
        CategoryChipSelector(
          categories: _categories,
          selectedCategoryIds: _selectedCategoryIds,
          onSelectionChanged: _onCategorySelectionChanged,
        ),

        // Tier selector
        TierChipSelector(
          selectedTier: _selectedTier,
          onTierChanged: _onTierChanged,
        ),

        const SizedBox(height: 8),

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
                selectedTier: _selectedTier,
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
