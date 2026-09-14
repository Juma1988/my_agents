import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge_category.dart';
import '../data/category_colors.dart';
import 'custom_snackbar.dart';

/// Drawer panel containing category selection, tier selection, and settings.
class AppDrawer extends StatelessWidget {
  final List<ChallengeCategory> categories;
  final List<String> selectedCategoryIds;
  final ValueChanged<List<String>> onSelectionChanged;
  final List<String> selectedTiers;
  final ValueChanged<List<String>> onTierChanged;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const AppDrawer({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
    required this.selectedTiers,
    required this.onTierChanged,
    required this.isDarkMode,
    required this.onDarkModeChanged,
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

  /// Descriptions for each category
  static const Map<String, String> categoryDescriptions = {
    'domestic': 'House chores with a twist',
    'dirty_truth': 'Dare to tell the truth',
    'spicy_dare': 'Bold dares, no backing down',
    'roleplay': 'Pretend, pretend, enjoy',
    'sensation': 'Touch, feel, lose control',
    'wildcard': 'Surprise, anything goes',
    'two_player': 'Couple tasks, double the fun',
  };

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
      backgroundColor: const Color(0xFF16162A),
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
                  const SizedBox(height: 10),
                  _buildTierRow(context),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 20),

                  // Settings section
                  _buildSectionLabel('SETTINGS'),
                  const SizedBox(height: 10),
                  _buildDarkModeToggle(),

                  const SizedBox(height: 24),
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
                'Handicap',
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
          final description = categoryDescriptions[cat.id] ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _toggleCategory(cat.id, context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    // Name + description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
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
                          Text(
                            description,
                            style: GoogleFonts.inter(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
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
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4ECDC4).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF4ECDC4)
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white38,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4ECDC4),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            const Text('🌙', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dark Mode',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: isDarkMode,
              onChanged: onDarkModeChanged,
              activeThumbColor: const Color(0xFF4ECDC4),
              activeTrackColor: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
              inactiveThumbColor: Colors.white54,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }
}
