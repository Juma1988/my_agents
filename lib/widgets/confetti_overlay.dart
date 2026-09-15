import 'dart:math';
import 'package:flutter/material.dart';

/// A full-screen confetti burst overlay.
/// Call [ConfettiOverlay.show] to trigger, [ConfettiOverlay.hide] to dismiss.
class ConfettiOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context, {Duration duration = const Duration(seconds: 2)}) {
    hide();
    _entry = OverlayEntry(
      builder: (_) => _ConfettiBurst(duration: duration),
    );
    Overlay.of(context).insert(_entry!);
    Future.delayed(duration + const Duration(milliseconds: 200), () => hide());
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _ConfettiBurst extends StatefulWidget {
  final Duration duration;
  const _ConfettiBurst({required this.duration});

  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(80, (_) => _Particle.random());
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return IgnorePointer(
          child: CustomPaint(
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
            size: MediaQuery.of(context).size,
          ),
        );
      },
    );
  }
}

class _Particle {
  final Offset origin;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;
  final double gravity;

  _Particle({
    required this.origin,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.gravity,
  });

  factory _Particle.random() {
    final rng = Random();
    final colors = [
      const Color(0xFFFF6B6B), // coral
      const Color(0xFF4ECDC4), // teal
      const Color(0xFFFFE66D), // yellow
      const Color(0xFFA855F7), // purple
      const Color(0xFFFF8C42), // orange
      const Color(0xFF45B7D1), // sky blue
      const Color(0xFFFFD700), // gold
      const Color(0xFFFF69B4), // pink
    ];
    return _Particle(
      origin: Offset(
        0.3 + rng.nextDouble() * 0.4, // spread from center-ish
        0.3 + rng.nextDouble() * 0.2,
      ),
      velocityX: (rng.nextDouble() - 0.5) * 600,
      velocityY: -(200 + rng.nextDouble() * 400), // upward
      rotation: rng.nextDouble() * 2 * pi,
      rotationSpeed: (rng.nextDouble() - 0.5) * 12,
      size: 4 + rng.nextDouble() * 8,
      color: colors[rng.nextInt(colors.length)],
      gravity: 600 + rng.nextDouble() * 400,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final x = size.width * p.origin.dx + p.velocityX * t;
      final y = size.height * p.origin.dy + p.velocityY * t + 0.5 * p.gravity * t * t;
      final rot = p.rotation + p.rotationSpeed * t;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Draw a small rectangle (confetti piece)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.size,
        height: p.size * 0.6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1)),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
