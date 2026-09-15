import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/shop_service.dart';
import '../data/sound_service.dart';
import '../data/achievement_service.dart';
import '../widgets/achievement_unlock_popup.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/dev_overlay.dart';

/// Shop screen where players spend coins on consumables, skills, power-ups, cosmetics.
class ShopScreen extends StatefulWidget {
  final int player;
  const ShopScreen({super.key, required this.player});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    DevOverlay.currentFilePath = 'lib/screens/shop_screen.dart';
  }

  int get _coins => ShopService.getCoins(widget.player);

  List<ShopItem> get _currentItems {
    switch (_selectedTab) {
      case 0:
        return ShopCatalog.consumables;
      case 1:
        return ShopCatalog.skills;
      case 2:
        return ShopCatalog.powerups;
      case 3:
        return ShopCatalog.cosmetics;
      default:
        return ShopCatalog.consumables;
    }
  }

  bool _isOwned(ShopItem item) {
    switch (item.type) {
      case ShopItemType.consumable:
        return ShopService.hasItem(widget.player, item.id);
      case ShopItemType.skill:
        return ShopService.hasSkill(widget.player, item.id);
      case ShopItemType.powerup:
        return ShopService.hasItem(widget.player, item.id);
      case ShopItemType.cosmetic:
        return ShopService.hasCosmetic(widget.player, item.id);
    }
  }

  void _purchase(ShopItem item) {
    if (_isOwned(item) && (item.type == ShopItemType.skill || item.type == ShopItemType.cosmetic)) {
      AppSnackBar.show(context, 'Already owned');
      return;
    }
    if (_coins < item.price) {
      SoundService.denied();
      AppSnackBar.show(context, 'Not enough coins');
      return;
    }
    SoundService.tap();
    final success = ShopService.purchase(widget.player, item);
    if (success) {
      setState(() {});
      AppSnackBar.show(context, 'Purchased ${item.name}!');
      // Check achievements
      final newAchievements = AchievementService.recordPurchase(widget.player);
      for (final a in newAchievements) {
        if (mounted) {
          AchievementUnlockPopup.show(context, a);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Shop',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '$_coins',
                  style: GoogleFonts.inter(
                    color: AppColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          _buildTabBar(),
          // Items grid
          Expanded(
            child: _buildItemsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Consumables', 'Skills', 'Power-ups', 'Cosmetics'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                SoundService.select();
                setState(() => _selectedTab = i);
              },
              child: Container(
                margin: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItemsList() {
    final items = _currentItems;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildItemCard(items[i]),
    );
  }

  Widget _buildItemCard(ShopItem item) {
    final owned = _isOwned(item);
    final canAfford = _coins >= item.price;
    final isPermanent = item.type == ShopItemType.skill || item.type == ShopItemType.cosmetic;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _purchase(item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: owned && isPermanent
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: owned && isPermanent
                  ? Colors.white.withValues(alpha: 0.06)
                  : canAfford
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(item.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              // Name + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.inter(
                        color: owned && isPermanent ? Colors.white38 : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Price / owned
              if (owned && isPermanent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OWNED',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else ...[
                Text(
                  '🪙 ${item.price}',
                  style: GoogleFonts.inter(
                    color: canAfford ? AppColors.accent : Colors.white24,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (owned && !isPermanent) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'x${_countInInventory(item.id)}',
                      style: GoogleFonts.inter(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _countInInventory(String itemId) {
    final inv = ShopService.getInventory(widget.player);
    return inv.where((id) => id == itemId).length;
  }
}
