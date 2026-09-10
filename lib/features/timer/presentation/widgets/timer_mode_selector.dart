import 'package:flutter/cupertino.dart';

import '../../domain/selectable_timer_types.dart';
import '../../domain/timer_type.dart';

/// Modern pill mode picker. Same footprint when locked to avoid layout jumps.
class TimerModeSelector extends StatelessWidget {
  const TimerModeSelector({
    super.key,
    required this.selected,
    required this.accentColor,
    required this.onSelected,
    this.enabled = true,
  });

  final TimerType selected;
  final Color accentColor;
  final ValueChanged<TimerType> onSelected;
  final bool enabled;

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final track = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8ED);
    final muted = isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.92,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = selectableTimerTypes.length;
                final segmentWidth = constraints.maxWidth / count;
                final index = selectableTimerTypes.indexOf(selected).clamp(0, count - 1);

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      left: segmentWidth * index,
                      top: 0,
                      bottom: 0,
                      width: segmentWidth,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular((height - 6) / 2),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final type in selectableTimerTypes)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: enabled ? () => onSelected(type) : null,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 180),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: selected == type
                                        ? CupertinoColors.white
                                        : muted,
                                    decoration: TextDecoration.none,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!enabled && selected == type) ...[
                                        Icon(
                                          CupertinoIcons.lock_fill,
                                          size: 10,
                                          color: CupertinoColors.white
                                              .withValues(alpha: 0.9),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Flexible(
                                        child: Text(
                                          type.shortLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
