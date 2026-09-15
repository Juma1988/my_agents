import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sound_service.dart';
import '../theme/app_colors.dart';

/// Result returned when the timer screen is popped.
class TimerResult {
  /// Whether the user completed the task (true) or cancelled (false).
  final bool completed;

  const TimerResult({required this.completed});
}

/// Full-screen countdown timer shown for timed tasks.
///
/// Receives task details and counts down. When the timer reaches zero,
/// an alarm plays and vibration fires. The user can either complete
/// (Done!) or cancel at any point.
class TimerScreen extends StatefulWidget {
  final String taskText;
  final int timerSeconds;
  final int points;
  final String categoryName;
  final String categoryIcon;

  const TimerScreen({
    super.key,
    required this.taskText,
    required this.timerSeconds,
    required this.points,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isExpired = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timerSeconds;

    // Pulse animation for the "Time's Up!" overlay
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });

        // Vibrate at 30s and 10s markers
        if (_remainingSeconds == 30) {
          SoundService.timerWarning30();
        } else if (_remainingSeconds == 10) {
          SoundService.timerWarning10();
        }
      } else {
        timer.cancel();
        setState(() {
          _isExpired = true;
        });
        _onTimerExpired();
      }
    });
  }

  Future<void> _onTimerExpired() async {
    // Play alarm sound with fallback
    await SoundService.timerAlarm();
    // Vibrate for 3 seconds
    SoundService.timerVibrateLoop();
    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  /// Format seconds into M:SS display.
  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// Color for the countdown text based on remaining seconds.
  Color _timerTextColor() {
    if (_remainingSeconds <= 10) return AppColors.timerWarning;
    if (_remainingSeconds <= 30) return AppColors.timerOrange;
    return Colors.white;
  }

  /// Color for the progress ring based on remaining seconds.
  Color _ringColor() {
    if (_remainingSeconds <= 10) return AppColors.timerWarning;
    if (_remainingSeconds <= 30) return AppColors.timerOrange;
    return AppColors.accent;
  }

  double get _progress {
    if (widget.timerSeconds <= 0) return 0;
    return _remainingSeconds / widget.timerSeconds;
  }

  void _onDone() {
    _timer?.cancel();
    _pulseController.stop();
    Navigator.of(context).pop(const TimerResult(completed: true));
  }

  void _onCancel() {
    _timer?.cancel();
    _pulseController.stop();
    Navigator.of(context).pop(const TimerResult(completed: false));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onCancel();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category badge
                  _buildCategoryBadge(),
                  const SizedBox(height: 32),

                  // Timer circle + text
                  _buildTimerCircle(),
                  const SizedBox(height: 32),

                  // Task text
                  _buildTaskText(),
                  const SizedBox(height: 12),

                  // Points
                  _buildPoints(),
                  const SizedBox(height: 48),

                  // Buttons
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Column(
      children: [
        Text(
          widget.categoryIcon,
          style: const TextStyle(fontSize: 36),
        ),
        const SizedBox(height: 8),
        Text(
          widget.categoryName.toUpperCase(),
          style: GoogleFonts.inter(
            color: AppColors.accent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCircle() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: _TimerRingPainter(
                progress: _progress,
                ringColor: _ringColor(),
              ),
            ),
          ),
          // Center content
          if (_isExpired)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: Text(
                "Time's Up!",
                style: GoogleFonts.inter(
                  color: AppColors.timerWarning,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Text(
              _formatTime(_remainingSeconds),
              style: GoogleFonts.inter(
                color: _timerTextColor(),
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskText() {
    return Text(
      widget.taskText,
      style: GoogleFonts.inter(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPoints() {
    return Text(
      '+${widget.points} points',
      style: GoogleFonts.inter(
        color: AppColors.accent,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: _onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.timerWarning,
                side: BorderSide(
                  color: AppColors.timerWarning.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Done button
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isExpired ? null : _onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: Text(
                'Done!',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the circular timer progress ring.
class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;

  _TimerRingPainter({required this.progress, required this.ringColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6; // 6px ring width

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.ringColor != ringColor;
  }
}
