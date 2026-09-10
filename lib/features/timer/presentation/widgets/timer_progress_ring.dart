import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

/// Circular progress ring that empties as time progresses (1 → 0).
class TimerProgressRing extends StatelessWidget {
  const TimerProgressRing({
    super.key,
    required this.progress,
    required this.accentColor,
    required this.child,
    this.size = 300,
    this.strokeWidth = 6,
  });

  /// 1.0 = full, 0.0 = empty.
  final double progress;
  final Color accentColor;
  final Widget child;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final track = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          accent: accentColor,
          track: track,
          strokeWidth: strokeWidth,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.accent,
    required this.track,
    required this.strokeWidth,
  });

  final double progress;
  final Color accent;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Start at 12 o'clock, sweep clockwise as time remains.
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(rect, start, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.track != track ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
