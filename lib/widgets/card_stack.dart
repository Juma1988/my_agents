import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge_category.dart';
import '../data/category_colors.dart';

/// A vertical card stack that cycles through categories.
/// Shows 5 cards in a vertical fan layout: 2 above, center, 2 below.
/// Spin method animates through cards rapidly, decelerates, lands on target.
class CardStack extends StatefulWidget {
  final List<ChallengeCategory> categories;
  final List<String> selectedCategoryIds;
  final ValueChanged<ChallengeCategory> onSpinComplete;

  const CardStack({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onSpinComplete,
  });

  @override
  State<CardStack> createState() => CardStackState();
}

class CardStackState extends State<CardStack>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spinAnimation;
  bool _isSpinning = false;
  double _currentPosition = 0;
  double _targetPosition = 0;

  // Idle bob animation
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;

  // Glow pulse
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  bool get isSpinning => _isSpinning;

  // Spec transform tables for positions -2, -1, 0, +1, +2
  // Index 0 = position -2 (back farther), index 4 = position +2 (front farther)
  static const List<double> _yOffsets = [-80, -40, 0, 40, 80];
  static const List<double> _scales = [0.7, 0.85, 1.0, 0.85, 0.7];
  static const List<double> _opacities = [0.4, 0.7, 1.0, 0.7, 0.4];
  static const List<double> _rotationsDeg = [-4, -2, 0, 2, 4];

  /// Maps a position (-2..+2) to a lookup-table index (0..4).
  static int _ti(int position) => position + 2;

  @override
  void initState() {
    super.initState();

    // Spin animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );

    _spinAnimation.addListener(_onSpinTick);
    _spinAnimation.addStatusListener(_onSpinStatus);

    // Idle bob animation
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _bobAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
    _bobController.repeat(reverse: true);

    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bobController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onSpinTick() {
    setState(() {
      _currentPosition = _spinAnimation.value * _targetPosition;
    });
  }

  void _onSpinStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _isSpinning = false;
      _bobController.repeat(reverse: true);
      _glowController.repeat(reverse: true);

      // The center card index equals _currentPosition (mod total).
      final totalCards = widget.categories.length;
      final index = _currentPosition.round() % totalCards;

      if (index >= 0 && index < widget.categories.length) {
        HapticFeedback.mediumImpact();
        widget.onSpinComplete(widget.categories[index]);
      }
    }
  }

  /// Spin the card stack to land on a specific category.
  /// Cards cycle upward; target lands at position 0 (center).
  void spinToCategory(ChallengeCategory targetCategory) {
    if (_isSpinning) return;

    final targetIndex = widget.categories.indexOf(targetCategory);
    if (targetIndex == -1) return;

    _isSpinning = true;
    _bobController.stop();
    _glowController.stop();

    // Calculate total distance: several full deck cycles + offset to target.
    final totalCards = widget.categories.length;
    final currentNormalized = _currentPosition % totalCards;
    final fullCycles = 3 + Random().nextInt(3); // 3-5 full cycles

    final cyclesNeeded = fullCycles * totalCards;
    final offset = targetIndex.toDouble();
    _targetPosition =
        _currentPosition - currentNormalized + cyclesNeeded + offset;

    // Reset and animate
    _controller.reset();
    _spinAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );

    _spinAnimation.addListener(_onSpinTick);
    _spinAnimation.addStatusListener(_onSpinStatus);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories available',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final totalCards = widget.categories.length;

    return SizedBox(
      width: 240,
      height: 300,
      child: AnimatedBuilder(
        animation: _isSpinning
            ? _spinAnimation
            : Listenable.merge([_bobAnimation, _glowAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(5, (i) {
              return _buildCard(i, totalCards);
            }),
          );
        },
      ),
    );
  }

  Widget _buildCard(int stackIndex, int totalCards) {
    // Position: -2 (back farther) → 0 (center) → +2 (front farther)
    final position = stackIndex - 2;

    // Category at this position.
    // Increasing _currentPosition cycles cards upward through center.
    final categoryIndex =
        (_currentPosition.round() + position) % totalCards;
    final adjustedIndex =
        categoryIndex < 0 ? categoryIndex + totalCards : categoryIndex;
    final category = widget.categories[adjustedIndex % totalCards];

    final color = CategoryColors.get(category.id);
    final isSelected = widget.selectedCategoryIds.contains(category.id);
    final ti = _ti(position);
    final isCenter = position == 0;

    return Positioned(
      top: 0,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          // ignore: deprecated_member_use
          ..translate(
            0.0,
            _yOffsets[ti] + (_isSpinning ? 0 : _bobAnimation.value),
            0.0,
          )
          ..rotateZ(_rotationsDeg[ti] * pi / 180) // depth tilt
          // ignore: deprecated_member_use
          ..scale(_scales[ti]),
        child: Opacity(
          opacity: _opacities[ti],
          child: Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.9)
                  : color.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
                width: isCenter ? 2 : 1,
              ),
              boxShadow: isCenter
                  ? [
                      BoxShadow(
                        color: color.withValues(
                          alpha: _isSpinning
                              ? 0.4
                              : _glowAnimation.value * 0.4,
                        ),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Category icon
                Text(
                  category.icon,
                  style: TextStyle(
                    fontSize: isCenter ? 40 : 32,
                  ),
                ),
                const SizedBox(height: 8),
                // Category name
                Text(
                  category.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isCenter ? 14 : 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
