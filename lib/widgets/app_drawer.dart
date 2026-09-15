import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge_category.dart';
import '../data/category_colors.dart';
import '../data/sound_service.dart';
import '../data/progression_service.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shop_screen.dart';
import '../theme/app_colors.dart';
import 'custom_snackbar.dart';

/// Drawer panel containing category selection, tier selection, and profiles.
class AppDrawer extends StatelessWidget {
  final List<ChallengeCategory> categories;
  final List<String> selectedCategoryIds;
  final ValueChanged<List<String>> onSelectionChanged;
  final List<String> selectedTiers;
  final ValueChanged<List<String>> onTierChanged;

  const AppDrawer({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
    required this.selectedTiers,
    required this.onTierChanged,
  });

  /// Short display names for each category
  static const Map<String, String> shortNames = {
    'domestic': 'Dom',
    'dirty_truth': 'Tru',
    'spicy_dare': 'Dare',
    'roleplay': 'Rol',
    'sensation': 'Sen',
    'wildcard': 'Wil',
    'two_player': '2Ply',
  };

  /// Available avatars for player profiles
  static const List<String> avatarEmojis = [
    '😈', '👿', '😎', '🥵', '😈', '🦊', '🐱', '🐶',
    '👸', '🤴', '💃', '🕺', '👻', '💀', '🔥', '💎',
    '🎭', '🦋', '🌙', '⭐', '🎵', '🎮', '🏆', '👑',
  ];

  void _toggleCategory(String categoryId, BuildContext context) {
    final newSelection = List<String>.from(selectedCategoryIds);

    if (newSelection.contains(categoryId)) {
      // Don't allow deselecting the last one
      if (newSelection.length <= 1) {
        AppSnackBar.show(context, 'At least one category must stay selected');
        return;
      }
      newSelection.remove(categoryId);
    } else {
      newSelection.add(categoryId);
    }

    onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceAlt,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),

            const Divider(color: Colors.white12, height: 1),

            // ── Scrollable content ──
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 16),

                  // Categories section
                  _buildSectionLabel('CATEGORIES'),
                  const SizedBox(height: 10),
                  _buildCategoryGrid(context),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 20),

                  // Tier section
                  _buildSectionLabel('TIER'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Select one or more',
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTierRow(context),
                  const SizedBox(height: 8),
                  _buildTierProgress(),

                  const SizedBox(height: 24),

                  // ── Bottom buttons ──
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 12),
                  _buildDrawerButton(
                    context,
                    icon: Icons.store,
                    label: 'Shop',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ShopScreen(player: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildDrawerButton(
                    context,
                    icon: Icons.history,
                    label: 'History',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildDrawerButton(
                    context,
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16162A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎰', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(
                'Risk Roulette',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Challenge Roulette',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white54,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: categories.map((cat) {
          final isSelected = selectedCategoryIds.contains(cat.id);
          final color = CategoryColors.get(cat.id);
          final shortName = shortNames[cat.id] ?? cat.name.substring(0, 3);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              label: 'Select ${cat.name}',
              toggled: isSelected,
              child: GestureDetector(
                onTap: () {
                  SoundService.select();
                  _toggleCategory(cat.id, context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? color.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Text(cat.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      // Short name
                      Expanded(
                        child: Text(
                          shortName,
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      // Checkmark
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: color.withValues(alpha: 0.9),
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTierRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildTierChip('Soft', 'soft', context),
          const SizedBox(height: 8),
          _buildTierChip('Kink', 'kink', context),
          const SizedBox(height: 8),
          _buildTierChip('Entertainment', 'entertainment', context),
        ],
      ),
    );
  }

  Widget _buildTierChip(String label, String tier, BuildContext context) {
    final selected = selectedTiers.contains(tier);
    final unlocked = ProgressionService.isTierUnlocked(tier);
    return Semantics(
      label: unlocked ? 'Select $label tier' : '$label tier locked',
      toggled: selected,
      child: GestureDetector(
        onTap: unlocked
            ? () {
                SoundService.select();
                final newTiers = List<String>.from(selectedTiers);
                if (newTiers.contains(tier)) {
                  // Don't allow deselecting the last tier
                  if (newTiers.length <= 1) {
                    AppSnackBar.show(context, 'At least one tier must stay selected');
                    return;
                  }
                  newTiers.remove(tier);
                } else {
                  newTiers.add(tier);
                }
                onTierChanged(newTiers);
              }
            : () {
                SoundService.denied();
                final next = ProgressionService.nextTierUnlock;
                AppSnackBar.show(context, '${next.tierName} unlocks at ${ProgressionService.tier2UnlockAt} tasks');
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: !unlocked
                ? Colors.white.withValues(alpha: 0.03)
                : selected
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !unlocked
                  ? Colors.white.withValues(alpha: 0.08)
                  : selected
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: !unlocked
                      ? Colors.white24
                      : selected
                          ? Colors.white
                          : Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (!unlocked)
                Icon(
                  Icons.lock_outline,
                  color: Colors.white24,
                  size: 14,
                )
              else if (selected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.accent,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tier Progress ──

  Widget _buildTierProgress() {
    final progress = ProgressionService.nextTierUnlock;
    final total = ProgressionService.totalCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          if (!progress.isComplete) ...[
            Row(
              children: [
                Text(
                  '${progress.current}/${progress.target}',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'tasks to unlock ${progress.tierName}',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress.fraction,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accent.withValues(alpha: 0.6),
                ),
                minHeight: 4,
              ),
            ),
          ] else ...[
            Text(
              'All tiers unlocked! ($total tasks completed)',
              style: GoogleFonts.inter(
                color: AppColors.accent.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Milestones
          const SizedBox(height: 12),
          _buildMilestones(),
        ],
      ),
    );
  }

  Widget _buildMilestones() {
    final earned = ProgressionService.earnedMilestones;
    final next = ProgressionService.nextMilestone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MILESTONES',
          style: GoogleFonts.inter(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final m in ProgressionService.milestones)
              _buildMilestoneBadge(m, isEarned: earned.contains(m)),
            if (next != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Next: ${next.icon} ${next.name} at ${next.threshold} tasks',
                  style: GoogleFonts.inter(
                    color: Colors.white24,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestoneBadge(Milestone milestone, {required bool isEarned}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEarned
            ? AppColors.accent.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEarned
              ? AppColors.accent.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            milestone.icon,
            style: TextStyle(fontSize: 12, color: isEarned ? null : Colors.white24),
          ),
          const SizedBox(width: 4),
          Text(
            milestone.name,
            style: GoogleFonts.inter(
              color: isEarned ? Colors.white70 : Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          SoundService.tap();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white54, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.white24,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
