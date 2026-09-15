import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../data/history_service.dart';
import '../data/sound_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_snackbar.dart';

/// Settings page accessible from the drawer.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _box;

  // Settings values
  String _hideCompleted = 'disable'; // always_ask, keep_favorite, enable, disable
  bool _hapticEnabled = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('settings');
    _hideCompleted = _box.get('hide_completed', defaultValue: 'disable');
    _hapticEnabled = _box.get('haptic_enabled', defaultValue: true);
    _soundEnabled = _box.get('sound_enabled', defaultValue: true);
  }

  void _saveSetting(String key, dynamic value) {
    _box.put(key, value);
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
          'Settings',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── Completed Tasks Section ──
          _buildSectionLabel('COMPLETED TASKS'),
          const SizedBox(height: 8),
          _buildHideCompletedOption(),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 24),

          // ── Feedback Section ──
          _buildSectionLabel('FEEDBACK'),
          const SizedBox(height: 8),
          _buildToggle(
            'Haptic Feedback',
            'Vibration on taps and spins',
            _hapticEnabled,
            (val) {
              setState(() => _hapticEnabled = val);
              _saveSetting('haptic_enabled', val);
            },
          ),
          _buildToggle(
            'Sound Effects',
            'Audio cues for actions',
            _soundEnabled,
            (val) {
              setState(() => _soundEnabled = val);
              _saveSetting('sound_enabled', val);
            },
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 24),

          // ── Data Section ──
          _buildSectionLabel('DATA'),
          const SizedBox(height: 8),
          _buildDangerButton(
            'Reset Scores',
            'Set both players back to 0',
            Icons.refresh,
            _showResetScoresDialog,
          ),
          const SizedBox(height: 10),
          _buildDangerButton(
            'Clear History',
            'Remove all task history',
            Icons.delete_outline,
            _showClearHistoryDialog,
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 24),

          // ── About Section ──
          _buildSectionLabel('ABOUT'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Risk Roulette v1.0.0',
              style: GoogleFonts.inter(
                color: Colors.white24,
                fontSize: 13,
              ),
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

  Widget _buildHideCompletedOption() {
    final options = {
      'disable': 'Disable — Show everything',
      'always_ask': 'Always Ask — Confirm if done before',
      'keep_favorite': 'Keep Favorite — Hide done, keep favorited',
      'enable': 'Enable — Always hide completed',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hide Completed Tasks',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Control how previously completed tasks appear',
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            ...options.entries.map((entry) {
              final isSelected = _hideCompleted == entry.key;
              return GestureDetector(
                onTap: () {
                  SoundService.select();
                  setState(() => _hideCompleted = entry.key);
                  _saveSetting('hide_completed', entry.key);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? AppColors.accent : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: (val) {
                SoundService.tap();
                onChanged(val);
              },
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.white38,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.timerWarning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.timerWarning.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.timerWarning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: AppColors.timerWarning,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.timerWarning.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetScoresDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252542),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Scores?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Both players will go back to 0 points. This cannot be undone.',
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              _box.put('player1_score', 0);
              _box.put('player2_score', 0);
              Navigator.of(ctx).pop();
              AppSnackBar.show(context, 'Scores reset to 0');
            },
            child: Text('Reset', style: TextStyle(color: AppColors.timerWarning)),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252542),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear History?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will remove all task history. Favorites will be kept.',
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              HistoryService.clearAll();
              Navigator.of(ctx).pop();
              AppSnackBar.show(context, 'History cleared');
            },
            child: Text('Clear', style: TextStyle(color: AppColors.timerWarning)),
          ),
        ],
      ),
    );
  }
}
