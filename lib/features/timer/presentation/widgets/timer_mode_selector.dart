import 'package:flutter/cupertino.dart';

import '../../domain/selectable_timer_types.dart';
import '../../domain/timer_type.dart';

/// Mode picker: segmented control when idle; locked badge while active.
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

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final muted = isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: enabled
          ? KeyedSubtree(
              key: const ValueKey('mode-picker'),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<TimerType>(
                  groupValue: selected,
                  thumbColor: accentColor,
                  backgroundColor: isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFE5E5EA),
                  padding: const EdgeInsets.all(3),
                  children: {
                    for (final type in selectableTimerTypes)
                      type: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Text(
                          type.shortLabel,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: selected == type
                                ? CupertinoColors.white
                                : muted,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                  },
                  onValueChanged: (value) {
                    if (value != null) onSelected(value);
                  },
                ),
              ),
            )
          : KeyedSubtree(
              key: const ValueKey('mode-locked'),
              child: _LockedModeBadge(
                label: selected.label,
                accentColor: accentColor,
                mutedColor: muted,
              ),
            ),
    );
  }
}

class _LockedModeBadge extends StatelessWidget {
  const _LockedModeBadge({
    required this.label,
    required this.accentColor,
    required this.mutedColor,
  });

  final String label;
  final Color accentColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.lock_fill,
              size: 12,
              color: accentColor.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: accentColor,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
