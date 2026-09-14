import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_button_3d.dart';

class SpinButton extends StatefulWidget {
  final bool isSpinning;
  final VoidCallback onPressed;

  const SpinButton({
    super.key,
    required this.isSpinning,
    required this.onPressed,
  });

  @override
  State<SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<SpinButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(SpinButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      _pulseController.stop();
    } else if (!widget.isSpinning && oldWidget.isSpinning) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isSpinning
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: _pulseAnimation.value,
                    ),
                  ],
          ),
          child: child,
        );
      },
      child: SizedBox(
        width: 200,
        child: CustomButton3D(
          label: '',
          disabled: widget.isSpinning,
          onPressed: widget.onPressed,
          faceColor: widget.isSpinning
              ? Colors.grey.shade300
              : const Color(0xFFFFD700),
          depthColor: widget.isSpinning
              ? Colors.grey.shade600
              : const Color(0xFFCC8800),
          textColor: widget.isSpinning
              ? Colors.grey.shade600
              : Colors.black,
          radius: 12,
          depth: 6,
          child: Center(
            child: Text(
              widget.isSpinning ? 'Spinning...' : '✦  S P I N  ✦',
              style: GoogleFonts.inter(
                color: widget.isSpinning ? Colors.grey.shade600 : Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
