/// Extensible workout timer modes.
enum TimerType {
  countdown,
  amrap,
  emom,
  forTime,
  tabata,
  intervals,
}

extension TimerTypeLabel on TimerType {
  String get label {
    switch (this) {
      case TimerType.countdown:
        return 'Countdown';
      case TimerType.amrap:
        return 'AMRAP';
      case TimerType.emom:
        return 'EMOM';
      case TimerType.forTime:
        return 'For Time';
      case TimerType.tabata:
        return 'Tabata';
      case TimerType.intervals:
        return 'Intervals';
    }
  }

  /// Compact label for chips.
  String get shortLabel => label;
}
