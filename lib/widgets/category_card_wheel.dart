import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/challenge_category.dart';
import '../data/category_colors.dart';

/// A vertical card wheel that shows categories using ListWheelScrollView.
/// Shows 3 cards with the centre card scaled up.
/// Uses ListWheelScrollView.useDelegate so only visible cards are built.
/// Scrolling wraps around in both directions (infinite loop).
class CategoryCardWheel extends StatefulWidget {
  const CategoryCardWheel({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    this.initialIndex = 0,
    this.onCenterChanged,
    this.onCategoryTap,
  });

  final List<ChallengeCategory> categories;
  final List<String> selectedCategoryIds;
  final int initialIndex;
  final ValueChanged<int>? onCenterChanged;
  final ValueChanged<ChallengeCategory>? onCategoryTap;

  @override
  State<CategoryCardWheel> createState() => CategoryCardWheelState();
}

class CategoryCardWheelState extends State<CategoryCardWheel> {
  late final FixedExtentScrollController _controller;
  late final ValueNotifier<int> _selectedIndex;
  bool _rolling = false;
  final ValueNotifier<int> _pulseTick = ValueNotifier<int>(0);
  int _pulseRealIndex = -1;
  final math.Random _random = math.Random();

  static const int _multiplier = 10000;
  static const double _itemExtent = 140.0 + 16; // card height + margin

  int get _virtualChildCount => widget.categories.length * _multiplier;
  int _realIndex(int virtualIndex) => virtualIndex % widget.categories.length;

  /// Roll the wheel to a random category with a short animated spin.
  void rollToRandom() {
    final len = widget.categories.length;
    if (len <= 1 || _rolling || !_controller.hasClients) return;

    final currentReal = _realIndex(_controller.selectedItem);

    int targetReal;
    do {
      targetReal = _random.nextInt(len);
    } while (targetReal == currentReal);

    final cycles = 1 + _random.nextInt(3);
    final advance = cycles * len + ((targetReal - currentReal + len) % len);
    final landingVirtual = _controller.selectedItem + advance;

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToItem(landingVirtual);
      _selectedIndex.value = landingVirtual;
      _pulseRealIndex = targetReal;
      _pulseTick.value++;
      return;
    }

    _rolling = true;
    _controller
        .animateToItem(
          landingVirtual,
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
      _rolling = false;
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _pulseRealIndex = targetReal;
      _pulseTick.value++;
    });
  }

  @override
  void initState() {
    super.initState();
    final len = widget.categories.length;
    final midOffset = len * (_multiplier ~/ 2);
    _controller = FixedExtentScrollController(
      initialItem: widget.initialIndex + midOffset,
    );
    _selectedIndex = ValueNotifier(widget.initialIndex + midOffset);
  }

  @override
  void dispose() {
    _controller.dispose();
    _selectedIndex.dispose();
    _pulseTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return Center(
        child: Text(
          'No categories enabled',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 16,
          ),
        ),
      );
    }

    return Semantics(
      label: 'Category wheel',
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: _itemExtent,
        physics: const FixedExtentScrollPhysics(),
        diameterRatio: 2.5,
        perspective: 0.004,
        squeeze: 1.1,
        clipBehavior: Clip.none,
        onSelectedItemChanged: (virtualIndex) {
          _selectedIndex.value = virtualIndex;
          widget.onCenterChanged?.call(_realIndex(virtualIndex));
          HapticFeedback.selectionClick();
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: _virtualChildCount,
          builder: (context, index) {
            final realIdx = _realIndex(index);
            return _ScaledChild(
              controller: _controller,
              index: index,
              itemExtent: _itemExtent,
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndex,
                builder: (context, selected, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _pulseTick,
                    builder: (context, pulseTick, _) {
                      final isPulseTarget = pulseTick > 0 &&
                          _pulseRealIndex == realIdx &&
                          index == selected;
                      return CategoryCard(
                        category: widget.categories[realIdx],
                        isSelected:
                            widget.selectedCategoryIds
                                .contains(widget.categories[realIdx].id),
                        isCenter: index == selected,
                        pulse: isPulseTarget,
                        pulseKey: isPulseTarget ? '$pulseTick' : null,
                        onTap: index == selected
                            ? () => widget.onCategoryTap
                                ?.call(widget.categories[realIdx])
                            : null,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Wraps each child with a scroll-aware scale transform.
class _ScaledChild extends StatelessWidget {
  const _ScaledChild({
    required this.controller,
    required this.index,
    required this.itemExtent,
    required this.child,
  });

  final FixedExtentScrollController controller;
  final int index;
  final double itemExtent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final offset = controller.hasClients ? controller.offset : 0.0;
        final itemCenter = index * itemExtent;
        final distance = (itemCenter - offset).abs();
        final normalizedDist = (distance / itemExtent).clamp(0.0, 2.0);

        final scale = (1.02 - normalizedDist * 0.045).clamp(0.91, 1.02);
        final opacity = (1.0 - normalizedDist * 0.16).clamp(0.68, 1.0);

        final styledChild = Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );

        if (normalizedDist < 1.35) return styledChild;
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: styledChild,
        );
      },
    );
  }
}

/// A single category card shown inside the wheel.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = true,
    this.isCenter = false,
    this.pulse = false,
    this.pulseKey,
    this.onTap,
  });

  final ChallengeCategory category;
  final bool isSelected;
  final bool isCenter;
  final bool pulse;
  final String? pulseKey;
  final VoidCallback? onTap;

  static const double cardHeight = 140.0;

  Color get _categoryColor => CategoryColors.get(category.id);

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;

    final fillDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: isCenter
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.4),
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.3),
              ],
            )
          : null,
      color: isCenter ? null : color.withValues(alpha: 0.2),
      border: Border.all(
        color: isCenter
            ? color.withValues(alpha: 0.8)
            : color.withValues(alpha: 0.3),
        width: isCenter ? 2 : 1,
      ),
    );

    final shadowDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isCenter ? 0.45 : 0.2),
          blurRadius: isCenter ? 24 : 12,
          offset: const Offset(0, 8),
        ),
        if (isCenter)
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 18,
            spreadRadius: 1,
          ),
      ],
    );

    final content = Stack(
      children: [
        // Category icon (large emoji)
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                category.name.toUpperCase(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              if (!isSelected) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DISABLED',
                    style: GoogleFonts.inter(
                      color: Colors.red.shade300,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Pulse ring
        if (isCenter && pulse && pulseKey != null)
          _PulseRing(pulseKey: pulseKey!, color: color),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        height: cardHeight,
        decoration: shadowDecoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: fillDecoration,
            child: onTap != null
                ? InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onTap: onTap,
                    child: content,
                  )
                : content,
          ),
        ),
      ),
    );
  }
}

/// Animated pulse ring effect.
class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.pulseKey, required this.color});
  final String pulseKey;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey<String>(pulseKey),
          tween: Tween<double>(begin: 1, end: 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, t, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.9 * t),
                  width: 2.5,
                ),
                color: color.withValues(alpha: 0.10 * t),
              ),
            );
          },
        ),
      ),
    );
  }
}
