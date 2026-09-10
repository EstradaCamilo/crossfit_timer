/// Extensible workout timer modes.
enum TimerType {
  forTime,
  amrap,
  emom,
  tabata,
  intervals,
}

extension TimerTypeLabel on TimerType {
  String get label {
    switch (this) {
      case TimerType.forTime:
        return 'FOR TIME';
      case TimerType.amrap:
        return 'AMRAP';
      case TimerType.emom:
        return 'EMOM';
      case TimerType.tabata:
        return 'TABATA';
      case TimerType.intervals:
        return 'INTERVALS';
    }
  }

  /// Compact label for segmented control.
  String get shortLabel => label;
}
