import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../data/sound_service.dart';
import '../widgets/custom_snackbar.dart';
import '../main.dart';

/// Global dev overlay that shows restart + copy-file-path buttons on every screen.
/// Only visible when isDebug = true. Requires triple-click to activate.
class DevOverlay extends StatefulWidget {
  final Widget child;
  const DevOverlay({super.key, required this.child});

  /// Current file path being displayed — screens update this on mount.
  static String currentFilePath = 'unknown';

  @override
  State<DevOverlay> createState() => _DevOverlayState();
}

class _DevOverlayState extends State<DevOverlay> {
  int _clickCount = 0;
  Timer? _clickTimer;
  bool _actionsVisible = false;

  void _onTap(BuildContext context) {
    _clickCount++;
    _clickTimer?.cancel();
    _clickTimer = Timer(const Duration(milliseconds: 500), () {
      _clickCount = 0;
    });

    if (_clickCount >= 3) {
      _clickCount = 0;
      _clickTimer?.cancel();
      setState(() => _actionsVisible = !_actionsVisible);
    }
  }

  @override
  void dispose() {
    _clickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isDebug) return widget.child;

    return Stack(
      children: [
        widget.child,
        // Dev buttons (top-left)
        Positioned(
          top: MediaQuery.of(context).padding.top + 4,
          left: 8,
          child: GestureDetector(
            onTap: () => _onTap(context),
            child: AnimatedOpacity(
              opacity: _actionsVisible ? 1.0 : 0.08,
              duration: const Duration(milliseconds: 200),
              child: AnimatedScale(
                scale: _actionsVisible ? 1.0 : 0.8,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_actionsVisible) ...[
                      // Restart button
                      GestureDetector(
                        onLongPress: () {
                          SoundService.tap();
                          RestartWidget.restartApp(context);
                        },
                        child: _buildDevButton(
                          icon: Icons.refresh,
                          tooltip: 'Long-press to restart',
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Copy file path button
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: DevOverlay.currentFilePath));
                          SoundService.tap();
                          AppSnackBar.show(context, DevOverlay.currentFilePath);
                        },
                        child: _buildDevButton(
                          icon: Icons.copy,
                          tooltip: 'Tap to copy file path',
                        ),
                      ),
                    ] else ...[
                      _buildDevButton(icon: Icons.code, tooltip: 'Triple-tap'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevButton({required IconData icon, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _actionsVisible
              ? AppColors.accent.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: _actionsVisible
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
              : null,
        ),
        child: Icon(
          icon,
          color: _actionsVisible ? Colors.white : Colors.white24,
          size: 16,
        ),
      ),
    );
  }
}
