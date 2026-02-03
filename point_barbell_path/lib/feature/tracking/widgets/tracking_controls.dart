import 'package:flutter/material.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';

class TrackingControls extends StatelessWidget {
  final bool isTracking;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback? onNewSet;
  final VoidCallback onFinish;

  const TrackingControls({
    super.key,
    required this.isTracking,
    required this.onStart,
    required this.onStop,
    this.onNewSet,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // New Set button
          _ControlButton(
            icon: Icons.add,
            label: l10n.newSet,
            onTap: onNewSet,
            small: true,
          ),

          // Main start/stop button
          GestureDetector(
            onTap: isTracking ? onStop : onStart,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isTracking ? Colors.red : Colors.white,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Center(
                child: isTracking
                    ? Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 36,
                      ),
              ),
            ),
          ),

          // Finish button
          _ControlButton(
            icon: Icons.check,
            label: l10n.finishSet,
            onTap: onFinish,
            small: true,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool small;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: small ? 44 : 56,
              height: small ? 44 : 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: Icon(icon, color: Colors.white, size: small ? 22 : 28),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
