import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/history_service.dart';
import '../data/category_colors.dart';
import '../theme/app_colors.dart';

/// Screen showing task history with filters and favorites.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'all'; // all, accepted, skipped
  String? _activeCategoryId;
  late List<Map<String, dynamic>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = HistoryService.getFiltered(
      filter: _activeFilter == 'all' ? null : _activeFilter,
      categoryId: _activeCategoryId,
    );
  }

  void _refresh() {
    setState(() {
      _entries = HistoryService.getFiltered(
        filter: _activeFilter == 'all' ? null : _activeFilter,
        categoryId: _activeCategoryId,
      );
    });
  }

  String _formatTimestamp(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
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
          'History',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white38, size: 22),
              onPressed: _showClearDialog,
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterBar(),

          // Category filter
          _buildCategoryFilter(),

          // History list
          Expanded(
            child: _entries.isEmpty
                ? _buildEmptyState()
                : _buildEntryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Accepted', 'accepted'),
          const SizedBox(width: 8),
          _buildFilterChip('Skipped', 'skipped'),
          const Spacer(),
          Text(
            '${_entries.length} entries',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isActive = _activeFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _activeFilter = value);
        _refresh();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = <String, String>{
      'domestic': '🏠',
      'dirty_truth': '💬',
      'spicy_dare': '🔥',
      'roleplay': '🎭',
      'sensation': '👅',
      'wildcard': '🌀',
      'two_player': '👫',
    };

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _buildCategoryChip(null, '🎯', 'All'),
          const SizedBox(width: 6),
          ...categories.entries.map((e) =>
            _buildCategoryChip(e.key, e.value, ''),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? id, String icon, String label) {
    final isActive = _activeCategoryId == id;
    final color = id != null ? CategoryColors.get(id) : AppColors.accent;

    return GestureDetector(
      onTap: () {
        setState(() => _activeCategoryId = id);
        _refresh();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.white.withValues(alpha: 0.1),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(
          icon,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            color: Colors.white.withValues(alpha: 0.15),
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete or skip tasks to see them here',
            style: GoogleFonts.inter(
              color: Colors.white24,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return _buildEntryCard(entry);
      },
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final color = CategoryColors.get(entry['categoryId']);
    final accepted = entry['accepted'] == true;
    final isFav = HistoryService.isFavorite(entry['taskId']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                entry['categoryIcon'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task text
                  Text(
                    entry['taskText'],
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Meta row
                  Row(
                    children: [
                      // Player
                      Text(
                        '${entry['playerName']}',
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Points
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accepted
                              ? Colors.greenAccent.withValues(alpha: 0.12)
                              : Colors.redAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          accepted ? '+${entry['points']}' : '-${entry['points']}',
                          style: GoogleFonts.inter(
                            color: accepted ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Time
                      Text(
                        _formatTimestamp(entry['timestamp']),
                        style: GoogleFonts.inter(
                          color: Colors.white24,
                          fontSize: 10,
                        ),
                      ),

                      const Spacer(),

                      // Favorite toggle
                      GestureDetector(
                        onTap: () {
                          HistoryService.toggleFavorite(entry['taskId']);
                          _refresh();
                        },
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.redAccent : Colors.white24,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252542),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear History',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will remove all history entries. Favorites will be kept.',
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              HistoryService.clearAll();
              _refresh();
              Navigator.of(ctx).pop();
            },
            child: Text('Clear', style: TextStyle(color: AppColors.timerWarning)),
          ),
        ],
      ),
    );
  }
}
