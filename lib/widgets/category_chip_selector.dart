import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge_category.dart';
import '../data/category_colors.dart';

/// Horizontal row of tappable category chips at top of screen.
/// Each chip shows category emoji icon + short name.
/// Tap to toggle selection. At least 1 must stay selected.
class CategoryChipSelector extends StatelessWidget {
  final List<ChallengeCategory> categories;
  final List<String> selectedCategoryIds;
  final ValueChanged<List<String>> onSelectionChanged;

  const CategoryChipSelector({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
  });

  /// Short display names for each category
  static const Map<String, String> shortNames = {
    'domestic': 'Dom',
    'dirty_truth': 'Tru',
    'spicy_dare': 'Dare',
    'roleplay': 'Rol',
    'sensation': 'Sen',
    'wildcard': 'Wil',
  };

  void _toggleCategory(String categoryId) {
    final newSelection = List<String>.from(selectedCategoryIds);

    if (newSelection.contains(categoryId)) {
      // Don't allow deselecting the last one
      if (newSelection.length <= 1) return;
      newSelection.remove(categoryId);
    } else {
      newSelection.add(categoryId);
    }

    onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, index2) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategoryIds.contains(cat.id);
          final color = CategoryColors.get(cat.id);
          final shortName = shortNames[cat.id] ?? cat.name.substring(0, 3);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _toggleCategory(cat.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? color
                      : Colors.white.withValues(alpha: 0.12),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji icon
                  Text(
                    cat.icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  // Short name
                  Text(
                    shortName,
                    style: GoogleFonts.inter(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  // Checkmark when selected
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 14,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Tier selection chips (Soft, Kink, Entertainment)
class TierChipSelector extends StatelessWidget {
  final String selectedTier;
  final ValueChanged<String> onTierChanged;

  const TierChipSelector({
    super.key,
    required this.selectedTier,
    required this.onTierChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTierChip('Soft', 'soft'),
          const SizedBox(width: 8),
          _buildTierChip('Kink', 'kink'),
          const SizedBox(width: 8),
          _buildTierChip('Entertainment', 'entertainment'),
        ],
      ),
    );
  }

  Widget _buildTierChip(String label, String tier) {
    final selected = selectedTier == tier;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTierChanged(tier);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4ECDC4).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF4ECDC4)
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white38,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
