import 'package:flutter/cupertino.dart';

import '../../domain/selectable_timer_types.dart';
import '../../domain/timer_type.dart';

/// Compact mode switcher for the main workout types.
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
    final chipBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < selectableTimerTypes.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            _ModeChip(
              label: selectableTimerTypes[i].shortLabel,
              selected: selected == selectableTimerTypes[i],
              enabled: enabled,
              accentColor: accentColor,
              mutedColor: muted,
              background: chipBg,
              onTap: () => onSelected(selectableTimerTypes[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.accentColor,
    required this.mutedColor,
    required this.background,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final Color accentColor;
  final Color mutedColor;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accentColor.withValues(alpha: 0.14) : background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accentColor : mutedColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: selected ? accentColor : mutedColor,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
