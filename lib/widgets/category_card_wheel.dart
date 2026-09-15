import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/challenge_category.dart';
import '../models/challenge_segment.dart';
import '../data/category_colors.dart';
import '../data/sound_service.dart';
import '../theme/app_colors.dart';

/// A flat item combining a task with its parent category for the wheel.
class TaskCardItem {
  final ChallengeCategory category;
  final ChallengeSegment task;
  final String tier;

  const TaskCardItem({
    required this.category,
    required this.task,
    required this.tier,
  });
}

/// A vertical card wheel that shows actual TASKS from selected categories.
/// Shows 3 cards with the centre card scaled up.
/// Uses ListWheelScrollView.useDelegate so only visible cards are built.
/// Scrolling wraps around in both directions (infinite loop).
class CategoryCardWheel extends StatefulWidget {
  const CategoryCardWheel({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.selectedTiers,
    this.initialIndex = 0,
    this.onCenterChanged,
  });

  final List<ChallengeCategory> categories;
  final List<String> selectedCategoryIds;
  final List<String> selectedTiers;
  final int initialIndex;
  final ValueChanged<int>? onCenterChanged;

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
  int _lastTickedIndex = -1;

  static const int _multiplier = 10000;

  /// Build the flat task pool from selected categories + selected tiers.
  List<TaskCardItem> get _taskPool {
    final pool = <TaskCardItem>[];
    for (final cat in widget.categories) {
      if (!widget.selectedCategoryIds.contains(cat.id)) continue;
      for (final tier in widget.selectedTiers) {
        final tasks = cat.tasksForTier(tier);
        for (final task in tasks) {
          pool.add(TaskCardItem(
            category: cat,
            task: task,
            tier: tier,
          ));
        }
      }
    }
    // Fallback: if selected tiers yield nothing, use all enabled tiers
    if (pool.isEmpty) {
      for (final cat in widget.categories) {
        if (!widget.selectedCategoryIds.contains(cat.id)) continue;
        for (final task in cat.soft) {
          pool.add(TaskCardItem(category: cat, task: task, tier: 'soft'));
        }
        for (final task in cat.kink) {
          pool.add(TaskCardItem(category: cat, task: task, tier: 'kink'));
        }
        for (final task in cat.entertainment) {
          pool.add(TaskCardItem(
              category: cat, task: task, tier: 'entertainment'));
        }
      }
    }
    pool.shuffle(math.Random());
    return pool;
  }

  int get _virtualChildCount => _taskPool.length * _multiplier;
  int _realIndex(int virtualIndex) => virtualIndex % _taskPool.length;

  /// Roll the wheel to a random task with a short animated spin.
  /// Returns the selected [TaskCardItem] when the spin completes.
  Future<TaskCardItem?> rollToRandom() async {
    final pool = _taskPool;
    final len = pool.length;
    if (len <= 1 || _rolling || !_controller.hasClients) {
      return len == 1 ? pool.first : null;
    }

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
      return pool[targetReal];
    }

    _rolling = true;
    final startOffset = _controller.offset;

    // Add listener for haptic ticks during spin
    // Intensity increases as wheel decelerates (early = light, late = heavy)
    void tickListener() {
      final pool = _taskPool;
      if (pool.isEmpty) return;
      final currentCenter = (_controller.offset / (TaskCard.cardHeight + 16)).round();
      final currentReal = _realIndex(currentCenter);
      if (currentReal != _lastTickedIndex && _lastTickedIndex != -1) {
        _lastTickedIndex = currentReal;
        // Calculate progress: 0 = start, 1 = end
        final totalDistance = (landingVirtual - startOffset).abs();
        final currentDistance = (_controller.offset - startOffset).abs();
        final progress = totalDistance > 0
            ? (currentDistance / totalDistance).clamp(0.0, 1.0)
            : 0.5;
        SoundService.wheelTick(intensity: progress);
      }
      _lastTickedIndex = currentReal;
    }

    _controller.addListener(tickListener);
    _lastTickedIndex = _realIndex(_controller.selectedItem);

    await _controller
        .animateToItem(
          landingVirtual,
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
      _controller.removeListener(tickListener);
      _rolling = false;
      if (!mounted) return;
      SoundService.wheelLand();
      _pulseRealIndex = targetReal;
      _pulseTick.value++;
    });

    return pool[targetReal];
  }

  @override
  void initState() {
    super.initState();
    final pool = _taskPool;
    final midOffset = pool.length * (_multiplier ~/ 2);
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
    final pool = _taskPool;
    if (pool.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.casino_outlined,
              color: Colors.white24,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Select categories to play',
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      label: 'Task wheel',
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: TaskCard.cardHeight + 16, // card height + margin
        physics: const FixedExtentScrollPhysics(),
        diameterRatio: 2.5,
        perspective: 0.004,
        squeeze: 1.1,
        clipBehavior: Clip.none,
        onSelectedItemChanged: (virtualIndex) {
          _selectedIndex.value = virtualIndex;
          widget.onCenterChanged?.call(_realIndex(virtualIndex));
          SoundService.wheelTick();
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: _virtualChildCount,
          builder: (context, index) {
            final realIdx = _realIndex(index);
            final item = pool[realIdx];
            return _ScaledChild(
              controller: _controller,
              index: index,
              itemExtent: TaskCard.cardHeight + 16,
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndex,
                builder: (context, selected, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _pulseTick,
                    builder: (context, pulseTick, _) {
                      final isPulseTarget = pulseTick > 0 &&
                          _pulseRealIndex == realIdx &&
                          index == selected;
                      return TaskCard(
                        item: item,
                        isCenter: index == selected,
                        pulse: isPulseTarget,
                        pulseKey: isPulseTarget ? '$pulseTick' : null,
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

/// A single task card shown inside the wheel.
///
/// Premium Row-based layout:
/// ```
/// ┌─────────────────────────────────────┐
/// ┃                        🏠    +2    │
/// ┃  Do the dishes while               │
/// ┃  completely naked and              │
/// ┃  humming a dirty song.             │
/// ┃                                    │
/// ┃  DOMESTIC          ⏱ 3:00          │
/// └─────────────────────────────────────┘
/// ```
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.item,
    this.isCenter = false,
    this.pulse = false,
    this.pulseKey,
  });

  final TaskCardItem item;
  final bool isCenter;
  final bool pulse;
  final String? pulseKey;

  static const double cardHeight = 140.0;

  Color get _categoryColor => CategoryColors.get(item.category.id);

  String _tierLabel(String tier) {
    switch (tier) {
      case 'soft':
        return 'Soft';
      case 'kink':
        return 'Kink';
      case 'entertainment':
        return 'Entertainment';
      default:
        return tier;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;

    // Background gradient
    final fillDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.surface.withValues(alpha: 0.95),
          AppColors.surfaceAlt.withValues(alpha: 0.98),
        ],
      ),
      border: Border.all(
        color: isCenter
            ? color.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.08),
        width: isCenter ? 1.5 : 1,
      ),
    );

    // Shadow
    final shadowDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isCenter ? 0.5 : 0.2),
          blurRadius: isCenter ? 24 : 12,
          offset: const Offset(0, 8),
        ),
        if (isCenter)
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
      ],
    );

    final content = Stack(
      children: [
        // Main row layout
        Row(
          children: [
            // Left accent bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.9),
                    color.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),

            // Category section (~1/4 width)
            Container(
              width: 76,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.category.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Vertical divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 1,
                color: color.withValues(alpha: 0.2),
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task text (wraps naturally)
                    Expanded(
                      child: Text(
                        item.task.text,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 14,
                          fontWeight: isCenter ? FontWeight.w600 : FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ),

                    // Bottom row: tier pill (left) + points badge + timer (right)
                    Row(
                      children: [
                        // Tier pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _tierLabel(item.tier).toUpperCase(),
                            style: GoogleFonts.inter(
                              color: color.withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // Points badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: color.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '+${item.task.points}',
                            style: GoogleFonts.inter(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Timer pill (if applicable)
                        if (item.task.hasTimer)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8C42).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: Color(0xFFFF8C42),
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTimerShort(item.task.timerSeconds!),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFF8C42),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Pulse ring overlay
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
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: fillDecoration,
            child: content,
          ),
        ),
      ),
    );
  }

  String _formatTimerShort(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0 && s > 0) return '${m}m ${s}s';
    if (m > 0) return '${m}m';
    return '${s}s';
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
                borderRadius: BorderRadius.circular(16),
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
