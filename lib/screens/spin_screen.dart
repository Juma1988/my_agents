import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/challenge_category.dart';
import '../models/challenge_segment.dart';
import '../data/task_loader.dart';
import '../widgets/category_card_wheel.dart';
import '../widgets/category_chip_selector.dart';
import '../widgets/score_bar.dart';
import '../widgets/spin_button.dart';
import '../widgets/wheel_pointer.dart';
import '../widgets/result_card.dart';

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

  // Result
  ChallengeCategory? _resultCategory;
  ChallengeSegment? _resultTask;
  bool _showResult = false;

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

  /// Get categories that are currently selected
  List<ChallengeCategory> get _activeCategories {
    return _categories
        .where((c) => _selectedCategoryIds.contains(c.id))
        .toList();
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
    final activeCategories = _activeCategories;
    if (activeCategories.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isSpinning = true;
      _showResult = false;
      _resultCategory = null;
      _resultTask = null;
    });

    // Build task pool: all tasks from selected categories at selected tier
    final taskPool = <MapEntry<ChallengeCategory, ChallengeSegment>>[];
    for (final cat in activeCategories) {
      final tasks = cat.tasksForTier(_selectedTier);
      for (final task in tasks) {
        taskPool.add(MapEntry(cat, task));
      }
    }

    if (taskPool.isEmpty) {
      // No tasks available, pick any task from any tier
      for (final cat in activeCategories) {
        final allTasks = cat.enabledTiers;
        for (final task in allTasks) {
          taskPool.add(MapEntry(cat, task));
        }
      }
    }

    if (taskPool.isEmpty) {
      setState(() {
        _isSpinning = false;
      });
      return;
    }

    // Pick random task from pool BEFORE spinning
    final randomEntry = taskPool[Random().nextInt(taskPool.length)];
    final targetCategory = randomEntry.key;
    final targetTask = randomEntry.value;

    // Store result for later display
    setState(() {
      _resultCategory = targetCategory;
      _resultTask = targetTask;
    });

    // Spin wheel to random category
    _wheelKey.currentState?.rollToRandom();

    // Show result after wheel stops (1100ms spin + 500ms pause)
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted && _isSpinning) {
        setState(() {
          _isSpinning = false;
          _showResult = true;
        });
      }
    });
  }

  void _handleAccept() {
    HapticFeedback.mediumImpact();
    setState(() {
      _score += _resultTask?.points ?? 0;
      _showResult = false;
      _resultCategory = null;
      _resultTask = null;
    });
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    setState(() {
      _score -= 1;
      _showResult = false;
      _resultCategory = null;
      _resultTask = null;
    });
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

  /// Main content with category chips, card stack, spin button, and result card
  Widget _buildMainContent() {
    return Stack(
      children: [
        // Main content
        Column(
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
                  // Card wheel
                  CategoryCardWheel(
                    key: _wheelKey,
                    categories: _categories,
                    selectedCategoryIds: _selectedCategoryIds,
                    onCenterChanged: (index) {
                      // Category changed in center
                    },
                    onCategoryTap: (category) {
                      // Could open category details
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

        // Result card overlay
        if (_showResult && _resultCategory != null && _resultTask != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ResultCard(
              category: _resultCategory!,
              task: _resultTask!,
              onAccept: _handleAccept,
              onSkip: _handleSkip,
            ),
          ),
      ],
    );
  }
}
