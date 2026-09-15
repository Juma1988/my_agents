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
  @override
  Widget build(BuildContext context) {
    if (!isDebug) return widget.child;

    return Stack(
      children: [
        widget.child,
        // Dev buttons (top-left) — always visible
        Positioned(
          top: MediaQuery.of(context).padding.top + 4,
          left: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Restart button
              GestureDetector(
                onTap: () {
                  SoundService.tap();
                  RestartWidget.restartApp(context);
                },
                child: _buildDevButton(
                  icon: Icons.refresh,
                  tooltip: 'Tap to restart',
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
            ],
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
          color: AppColors.accent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        ),
        child: Icon(
          icon,
          color: Colors.white70,
          size: 16,
        ),
      ),
    );
  }
}
