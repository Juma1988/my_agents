import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/challenge_category.dart';
import '../models/challenge_segment.dart';
import '../data/category_colors.dart';

class ResultCard extends StatefulWidget {
  final ChallengeCategory category;
  final ChallengeSegment task;
  final VoidCallback onAccept;
  final VoidCallback onSkip;

  const ResultCard({
    super.key,
    required this.category,
    required this.task,
    required this.onAccept,
    required this.onSkip,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _timerExpired = false;
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();
    if (widget.task.hasTimer) {
      _remainingSeconds = widget.task.timerSeconds!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!widget.task.hasTimer || _timerStarted) return;
    _timerStarted = true;
    _remainingSeconds = widget.task.timerSeconds!;
    _timerExpired = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _timerExpired = true;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _handleAccept() {
    _timer?.cancel();
    widget.onAccept();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = widget.task.timerSeconds ?? 0;
    final progress = totalSeconds > 0 && _timerStarted
        ? _remainingSeconds / totalSeconds
        : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF252542),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Category icon + name with color accent
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CategoryColors.get(widget.category.id).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.category.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.category.name.toUpperCase(),
                style: GoogleFonts.inter(
                  color: CategoryColors.get(widget.category.id),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // TASK label
          Text(
            'TASK',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),

          // Task text
          Text(
            widget.task.text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Timer display (if task has timer)
          if (widget.task.hasTimer) ...[
            const SizedBox(height: 8),
            _timerStarted
                ? Column(
                    children: [
                      // Circular countdown indicator
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background circle
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _timerExpired
                                      ? Colors.redAccent
                                      : const Color(0xFFFF8C42),
                                ),
                              ),
                            ),
                            // Time text
                            Text(
                              _timerExpired
                                  ? "Time's up!"
                                  : _formatTime(_remainingSeconds),
                              style: GoogleFonts.inter(
                                color: _timerExpired
                                    ? Colors.redAccent
                                    : Colors.white,
                                fontSize: _timerExpired ? 12 : 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: _startTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C42).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF8C42),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Color(0xFFFF8C42),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Start Timer: ${_formatTime(totalSeconds)}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFF8C42),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
          ],

          // Points + Timer row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat(
                  'Points', '+${widget.task.points} pts', Colors.greenAccent),
              if (widget.task.hasTimer && !_timerStarted) ...[
                const SizedBox(width: 32),
                _buildStat(
                  'Timer',
                  _formatTime(widget.task.timerSeconds!),
                  Colors.orangeAccent,
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),

          // Accept button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _handleAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                'Accept Challenge',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Skip button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                _timer?.cancel();
                widget.onSkip();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Skip (-1 pt)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(
          duration: 300.ms,
        );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
