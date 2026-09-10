import 'package:flutter/cupertino.dart';

import '../../domain/timer_status.dart';
import '../../../../core/l10n/app_strings.dart';

/// Compact primary action with icon + secondary reset.
class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.status,
    required this.accentColor,
    required this.strings,
    required this.onPrimary,
    required this.onReset,
    this.enabled = true,
  });

  final TimerStatus status;
  final Color accentColor;
  final AppStrings strings;
  final VoidCallback onPrimary;
  final VoidCallback onReset;
  final bool enabled;

  IconData get _primaryIcon {
    switch (status) {
      case TimerStatus.idle:
      case TimerStatus.completed:
        return CupertinoIcons.play_fill;
      case TimerStatus.getReady:
      case TimerStatus.running:
        return CupertinoIcons.pause_fill;
      case TimerStatus.paused:
        return CupertinoIcons.play_fill;
    }
  }

  String get _primaryLabel {
    switch (status) {
      case TimerStatus.idle:
      case TimerStatus.completed:
        return strings.start;
      case TimerStatus.getReady:
      case TimerStatus.running:
        return strings.pause;
      case TimerStatus.paused:
        return strings.resume;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final resetColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(14),
            color: accentColor,
            disabledColor: accentColor.withValues(alpha: 0.35),
            onPressed: enabled ? onPrimary : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _primaryIcon,
                  size: 18,
                  color: CupertinoColors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _primaryLabel,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: CupertinoColors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          onPressed: status == TimerStatus.idle ? null : onReset,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.arrow_counterclockwise,
                size: 15,
                color: status == TimerStatus.idle
                    ? resetColor.withValues(alpha: 0.35)
                    : resetColor,
              ),
              const SizedBox(width: 6),
              Text(
                strings.reset,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: status == TimerStatus.idle
                      ? resetColor.withValues(alpha: 0.35)
                      : resetColor,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
