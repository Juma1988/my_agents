import 'package:flutter/material.dart';

/// A 3D push-button widget recreated from CSS.
///
/// The dark bottom layer acts as the "depth" / shadow.
/// The lighter top layer is the button face, offset upward.
/// Pressing flattens the face down for a tactile 3D feel.
class CustomButton3D extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color faceColor;
  final Color depthColor;
  final Color textColor;
  final double radius;
  final double depth; // how tall the 3D effect is (em-equivalent)
  final bool disabled;
  final Widget? child;

  const CustomButton3D({
    super.key,
    required this.label,
    this.onPressed,
    this.faceColor = const Color(0xFFE8E8E8),
    this.depthColor = const Color(0xFF000000),
    this.textColor = const Color(0xFF000000),
    this.radius = 12,
    this.depth = 6,
    this.disabled = false,
    this.child,
  });

  @override
  State<CustomButton3D> createState() => _CustomButton3DState();
}

class _CustomButton3DState extends State<CustomButton3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.disabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.disabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.disabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Interpolate offset: resting = depth, pressed = 0
    final currentDepth = widget.disabled ? 2.0 : widget.depth;
    final offset = _isPressed ? 0.0 : currentDepth;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.disabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(bottom: widget.disabled ? 2.0 : offset),
        child: Stack(
          children: [
            // Bottom layer — the "depth" / shadow
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: widget.disabled
                    ? Colors.grey.shade500
                    : widget.depthColor,
                borderRadius: BorderRadius.circular(widget.radius),
              ),
            ),
            // Top layer — the button face
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: widget.disabled
                    ? Colors.grey.shade300
                    : widget.faceColor,
                borderRadius: BorderRadius.circular(widget.radius),
                border: Border.all(
                  color: widget.disabled
                      ? Colors.grey.shade400
                      : widget.depthColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: widget.child ??
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.disabled
                            ? Colors.grey.shade600
                            : widget.textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
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
