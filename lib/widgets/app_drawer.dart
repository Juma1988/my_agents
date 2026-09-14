import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge_category.dart';
import '../data/category_colors.dart';
import '../theme/app_colors.dart';
import 'custom_snackbar.dart';

/// Drawer panel containing category selection, tier selection, and profiles.
class AppDrawer extends StatelessWidget {
  final List<ChallengeCategory> categories;
  final List<String> selectedCategoryIds;
  final ValueChanged<List<String>> onSelectionChanged;
  final List<String> selectedTiers;
  final ValueChanged<List<String>> onTierChanged;

  // Player profiles
  final String player1Nickname;
  final String player2Nickname;
  final String player1Avatar;
  final String player2Avatar;
  final ValueChanged<String> onPlayer1NicknameChanged;
  final ValueChanged<String> onPlayer2NicknameChanged;
  final ValueChanged<String> onPlayer1AvatarChanged;
  final ValueChanged<String> onPlayer2AvatarChanged;

  const AppDrawer({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
    required this.selectedTiers,
    required this.onTierChanged,
    this.player1Nickname = 'Player 1',
    this.player2Nickname = 'Player 2',
    this.player1Avatar = '😈',
    this.player2Avatar = '👿',
    required this.onPlayer1NicknameChanged,
    required this.onPlayer2NicknameChanged,
    required this.onPlayer1AvatarChanged,
    required this.onPlayer2AvatarChanged,
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

  void _showNicknameDialog(
      BuildContext context, String title, String current, ValueChanged<String> onChanged) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252542),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter nickname',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent),
            ),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              onChanged(value.trim());
            }
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onChanged(controller.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: Text('Save', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(
      BuildContext context, String title, String current, ValueChanged<String> onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF252542),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: avatarEmojis.length,
              itemBuilder: (ctx, i) {
                final emoji = avatarEmojis[i];
                final isSelected = emoji == current;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(emoji);
                    Navigator.of(ctx).pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
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

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 20),

                  // Profiles section
                  _buildSectionLabel('PROFILES'),
                  const SizedBox(height: 10),
                  _buildPlayerProfile(
                    context,
                    label: 'Player 1',
                    nickname: player1Nickname,
                    avatar: player1Avatar,
                    onNicknameChanged: onPlayer1NicknameChanged,
                    onAvatarChanged: onPlayer1AvatarChanged,
                  ),
                  const SizedBox(height: 8),
                  _buildPlayerProfile(
                    context,
                    label: 'Player 2',
                    nickname: player2Nickname,
                    avatar: player2Avatar,
                    onNicknameChanged: onPlayer2NicknameChanged,
                    onAvatarChanged: onPlayer2AvatarChanged,
                  ),

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
                  HapticFeedback.selectionClick();
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
    return Semantics(
      label: 'Select $label tier',
      toggled: selected,
      child: GestureDetector(
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
                ? AppColors.accent.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
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
                  color: selected ? Colors.white : Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (selected)
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

  // ── Profiles Section ──

  Widget _buildPlayerProfile(
    BuildContext context, {
    required String label,
    required String nickname,
    required String avatar,
    required ValueChanged<String> onNicknameChanged,
    required ValueChanged<String> onAvatarChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Avatar (tap to change)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _showAvatarPicker(context, '$label Avatar', avatar, onAvatarChanged);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(avatar, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            // Nickname + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _showNicknameDialog(
                          context, '$label Nickname', nickname, onNicknameChanged);
                    },
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            nickname,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Change avatar button
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _showAvatarPicker(context, '$label Avatar', avatar, onAvatarChanged);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Avatar',
                  style: GoogleFonts.inter(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
