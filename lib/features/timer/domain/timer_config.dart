import 'timer_type.dart';

/// Immutable configuration for a timer session.
class TimerConfig {
  const TimerConfig({
    required this.type,
    required this.duration,
    this.restDuration = Duration.zero,
    this.rounds = 10,
  });

  /// Workout mode.
  final TimerType type;

  /// AMRAP/For Time total, EMOM interval, or Tabata work length.
  final Duration duration;

  /// Tabata (and later Intervals) rest length.
  final Duration restDuration;

  /// EMOM / Tabata rounds.
  final int rounds;

  bool get usesRounds =>
      type == TimerType.emom || type == TimerType.tabata;

  bool get usesRest => type == TimerType.tabata;

  TimerConfig copyWith({
    TimerType? type,
    Duration? duration,
    Duration? restDuration,
    int? rounds,
  }) {
    return TimerConfig(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      restDuration: restDuration ?? this.restDuration,
      rounds: rounds ?? this.rounds,
    );
  }

  /// Sensible defaults when switching modes.
  static TimerConfig defaultsFor(TimerType type) {
    switch (type) {
      case TimerType.forTime:
        return const TimerConfig(
          type: TimerType.forTime,
          duration: Duration(minutes: 20),
        );
      case TimerType.amrap:
        return const TimerConfig(
          type: TimerType.amrap,
          duration: Duration(minutes: 10),
        );
      case TimerType.emom:
        return const TimerConfig(
          type: TimerType.emom,
          duration: Duration(minutes: 1),
          rounds: 10,
        );
      case TimerType.tabata:
        return const TimerConfig(
          type: TimerType.tabata,
          duration: Duration(seconds: 20),
          restDuration: Duration(seconds: 10),
          rounds: 8,
        );
      case TimerType.intervals:
        return const TimerConfig(
          type: TimerType.intervals,
          duration: Duration(minutes: 1),
          restDuration: Duration(seconds: 30),
          rounds: 5,
        );
    }
  }
}
