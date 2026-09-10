import 'package:flutter/cupertino.dart';

import '../../domain/timer_status.dart';
import 'timer_progress_ring.dart';

/// Large, reusable timer readout with a depleting progress ring.
class CrossFitTimerDisplay extends StatelessWidget {
  const CrossFitTimerDisplay({
    super.key,
    required this.remaining,
    required this.status,
    required this.accentColor,
    required this.progress,
    this.typeLabel,
    this.subtitle,
    this.prepSeconds,
  });

  final Duration remaining;
  final TimerStatus status;
  final Color accentColor;

  /// 1.0 full → 0.0 empty.
  final double progress;
  final String? typeLabel;
  final String? subtitle;

  /// When set (get-ready), shows a big digit instead of mm:ss.
  final int? prepSeconds;

  static String format(Duration d) {
    final total = d.inSeconds.clamp(0, 359999);
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Color _timeColor(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    switch (status) {
      case TimerStatus.idle:
      case TimerStatus.running:
        return isDark ? CupertinoColors.white : CupertinoColors.black;
      case TimerStatus.getReady:
        return accentColor;
      case TimerStatus.paused:
        return isDark
            ? const Color(0xFF8E8E93)
            : const Color(0xFF636366);
      case TimerStatus.completed:
        return const Color(0xFF22C55E);
    }
  }

  Color _ringColor() {
    switch (status) {
      case TimerStatus.completed:
        return const Color(0xFF22C55E);
      case TimerStatus.paused:
        return accentColor.withValues(alpha: 0.55);
      case TimerStatus.idle:
      case TimerStatus.getReady:
      case TimerStatus.running:
        return accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    const secondary = Color(0xFF8E8E93);
    final showPrep = status == TimerStatus.getReady && prepSeconds != null;
    final timeText = showPrep ? '$prepSeconds' : format(remaining);

    return AnimatedScale(
      scale: status == TimerStatus.completed
          ? 1.02
          : (showPrep ? 1.04 : 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: status == TimerStatus.paused ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (typeLabel != null) ...[
              Text(
                typeLabel!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.4,
                  color: secondary,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),
            ],
            TimerProgressRing(
              progress: progress,
              accentColor: _ringColor(),
              size: 236,
              strokeWidth: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.92, end: 1).animate(
                          animation,
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    timeText,
                    key: ValueKey(timeText),
                    style: TextStyle(
                      fontSize: showPrep ? 72 : 52,
                      fontWeight: showPrep ? FontWeight.w300 : FontWeight.w200,
                      height: 1.0,
                      letterSpacing: showPrep ? -2 : -1.4,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: _timeColor(context),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 18),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: secondary,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
