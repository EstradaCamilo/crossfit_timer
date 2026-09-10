import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../services/haptic_service.dart';
import '../../../services/timer_sound_service.dart';
import '../domain/timer_config.dart';
import '../domain/timer_phase.dart';
import '../domain/timer_status.dart';
import '../domain/timer_type.dart';

/// Precise timer engine driven by wall-clock timestamps.
class TimerController extends ChangeNotifier {
  TimerController({
    TimerConfig? initialConfig,
    this._sound = const TimerSoundService(),
    this._haptics = const HapticService(),
  })  : _config = initialConfig ?? TimerConfig.defaultsFor(TimerType.forTime),
        _remainingWhenPaused =
            (initialConfig ?? TimerConfig.defaultsFor(TimerType.forTime))
                .duration;

  static const Duration prepDuration = Duration(seconds: 5);

  TimerConfig _config;
  TimerSoundService _sound;
  HapticService _haptics;

  TimerStatus _status = TimerStatus.idle;
  DateTime? _endAt;
  Duration _remainingWhenPaused;
  Timer? _ticker;
  bool _completionSignaled = false;
  int? _lastCountdownCueSecond;
  int _currentRound = 1;
  TimerPhase _phase = TimerPhase.work;
  bool _pausedDuringPrep = false;

  TimerConfig get config => _config;
  TimerStatus get status => _status;
  TimerType get type => _config.type;
  int get currentRound => _currentRound;
  int get totalRounds => _config.rounds;
  TimerPhase get phase => _phase;
  bool get isGetReady => _status == TimerStatus.getReady;
  bool get isInPrep =>
      _status == TimerStatus.getReady ||
      (_status == TimerStatus.paused && _pausedDuringPrep);

  /// Displayed clock value (prep seconds or workout remaining).
  Duration get displayTime => remaining;

  Duration get remaining {
    switch (_status) {
      case TimerStatus.idle:
      case TimerStatus.paused:
        return _remainingWhenPaused;
      case TimerStatus.getReady:
      case TimerStatus.running:
        final end = _endAt;
        if (end == null) return _remainingWhenPaused;
        final left = end.difference(DateTime.now());
        if (left.isNegative) return Duration.zero;
        return left;
      case TimerStatus.completed:
        return Duration.zero;
    }
  }

  /// Whole seconds left in the get-ready phase (5..1).
  int get prepSeconds {
    final s = remaining.inMilliseconds;
    if (s <= 0) return 0;
    return ((s + 999) ~/ 1000).clamp(0, prepDuration.inSeconds);
  }

  /// 1.0 → full ring, 0.0 → empty for the active segment.
  double get progress {
    final totalMs = _segmentDuration.inMilliseconds;
    if (totalMs <= 0) return 0;
    final leftMs = remaining.inMilliseconds.clamp(0, totalMs);
    return leftMs / totalMs;
  }

  Duration get _segmentDuration {
    if (_status == TimerStatus.getReady ||
        (_status == TimerStatus.paused && _pausedDuringPrep)) {
      return prepDuration;
    }
    if (_config.type == TimerType.tabata && _phase == TimerPhase.rest) {
      return _config.restDuration;
    }
    return _config.duration;
  }

  bool get isIdle => _status == TimerStatus.idle;
  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isCompleted => _status == TimerStatus.completed;
  bool get isActive =>
      _status == TimerStatus.getReady ||
      _status == TimerStatus.running ||
      _status == TimerStatus.paused;

  bool get canStart {
    if (_status != TimerStatus.idle && _status != TimerStatus.completed) {
      return false;
    }
    if (_config.duration <= Duration.zero) return false;
    if (_config.usesRest && _config.restDuration <= Duration.zero) return false;
    return true;
  }

  bool get canPause =>
      _status == TimerStatus.running || _status == TimerStatus.getReady;
  bool get canResume => _status == TimerStatus.paused;

  void updateServices({
    required TimerSoundService sound,
    required HapticService haptics,
  }) {
    _sound = sound;
    _haptics = haptics;
  }

  void setType(TimerType type) {
    if (isActive) return;
    if (_config.type == type) return;
    _applyConfig(TimerConfig.defaultsFor(type));
  }

  void setDuration(Duration duration) {
    if (isActive) return;
    final clamped = duration < Duration.zero ? Duration.zero : duration;
    _applyConfig(_config.copyWith(duration: clamped), preserveIdleRemaining: true);
  }

  void setRestDuration(Duration duration) {
    if (isActive) return;
    final clamped = duration < Duration.zero ? Duration.zero : duration;
    _applyConfig(_config.copyWith(restDuration: clamped), preserveIdleRemaining: true);
  }

  void setRounds(int rounds) {
    if (isActive) return;
    final clamped = rounds.clamp(1, 99);
    _applyConfig(_config.copyWith(rounds: clamped), preserveIdleRemaining: true);
  }

  void _applyConfig(
    TimerConfig config, {
    bool preserveIdleRemaining = false,
  }) {
    _stopTicker();
    _config = config;
    _phase = TimerPhase.work;
    if (!preserveIdleRemaining || _status == TimerStatus.completed) {
      _remainingWhenPaused = config.duration;
    } else if (_phase == TimerPhase.work) {
      _remainingWhenPaused = config.duration;
    }
    _endAt = null;
    _status = TimerStatus.idle;
    _completionSignaled = false;
    _lastCountdownCueSecond = null;
    _currentRound = 1;
    _pausedDuringPrep = false;
    notifyListeners();
  }

  /// Starts the mandatory 5s get-ready countdown, then the workout.
  void start() {
    if (!canStart) return;

    _phase = TimerPhase.work;
    _currentRound = 1;
    _pausedDuringPrep = false;
    _completionSignaled = false;
    _lastCountdownCueSecond = null;

    _remainingWhenPaused = prepDuration;
    _endAt = DateTime.now().add(prepDuration);
    _status = TimerStatus.getReady;
    _lastCountdownCueSecond = prepDuration.inSeconds;

    _sound.playCountdown();
    unawaited(_haptics.countdown());
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (!canPause) return;
    _pausedDuringPrep = _status == TimerStatus.getReady;
    _remainingWhenPaused = remaining;
    _endAt = null;
    _status = TimerStatus.paused;
    _stopTicker();
    notifyListeners();
  }

  void resume() {
    if (!canResume) return;
    if (_remainingWhenPaused <= Duration.zero) {
      if (_pausedDuringPrep) {
        _beginWorkout();
      } else {
        _advanceSegment();
      }
      return;
    }
    _endAt = DateTime.now().add(_remainingWhenPaused);
    _status =
        _pausedDuringPrep ? TimerStatus.getReady : TimerStatus.running;
    _startTicker();
    notifyListeners();
  }

  void reset() {
    _applyConfig(_config);
  }

  void _tick() {
    if (_status == TimerStatus.getReady) {
      final left = remaining;
      if (left <= Duration.zero) {
        _beginWorkout();
        return;
      }
      _cuePrepSeconds(left);
      notifyListeners();
      return;
    }

    if (_status != TimerStatus.running) return;

    if (_config.type == TimerType.emom || _config.type == TimerType.tabata) {
      final left = remaining;
      if (left > Duration.zero) {
        _cueFinalSeconds(left);
        notifyListeners();
        return;
      }
      _advanceSegment();
      return;
    }

    final left = remaining;
    if (left <= Duration.zero) {
      _complete();
      return;
    }
    _cueFinalSeconds(left);
    notifyListeners();
  }

  void _beginWorkout() {
    _pausedDuringPrep = false;
    final duration = _config.duration;
    if (duration <= Duration.zero) {
      _complete();
      return;
    }
    _remainingWhenPaused = duration;
    _endAt = DateTime.now().add(duration);
    _status = TimerStatus.running;
    _lastCountdownCueSecond = null;
    _sound.playStart();
    unawaited(_haptics.start());
    if (_ticker == null) _startTicker();
    notifyListeners();
  }

  void _advanceSegment() {
    if (_config.type == TimerType.emom) {
      if (_currentRound >= _config.rounds) {
        _complete();
        return;
      }
      _currentRound += 1;
      _beginSegment(_config.duration);
      _sound.playRoundChange();
      unawaited(_haptics.roundChange());
      notifyListeners();
      return;
    }

    if (_config.type == TimerType.tabata) {
      if (_phase == TimerPhase.work) {
        _phase = TimerPhase.rest;
        _beginSegment(_config.restDuration);
        _sound.playRoundChange();
        unawaited(_haptics.roundChange());
        notifyListeners();
        return;
      }

      if (_currentRound >= _config.rounds) {
        _complete();
        return;
      }
      _currentRound += 1;
      _phase = TimerPhase.work;
      _beginSegment(_config.duration);
      _sound.playRoundChange();
      unawaited(_haptics.roundChange());
      notifyListeners();
      return;
    }

    _complete();
  }

  void _beginSegment(Duration duration) {
    _remainingWhenPaused = duration;
    _endAt = DateTime.now().add(duration);
    _lastCountdownCueSecond = null;
    _status = TimerStatus.running;
    if (_ticker == null) _startTicker();
  }

  void _cuePrepSeconds(Duration left) {
    final wholeSeconds = prepSeconds;
    if (wholeSeconds >= 1 &&
        wholeSeconds <= prepDuration.inSeconds &&
        _lastCountdownCueSecond != wholeSeconds) {
      _lastCountdownCueSecond = wholeSeconds;
      _sound.playCountdown();
      unawaited(_haptics.countdown());
    }
  }

  void _cueFinalSeconds(Duration left) {
    final wholeSeconds = left.inSeconds;
    if (wholeSeconds >= 1 &&
        wholeSeconds <= 3 &&
        _lastCountdownCueSecond != wholeSeconds) {
      _lastCountdownCueSecond = wholeSeconds;
      _sound.playCountdown();
      unawaited(_haptics.countdown());
    }
  }

  void _complete() {
    if (_completionSignaled) return;
    _completionSignaled = true;
    _stopTicker();
    _endAt = null;
    _remainingWhenPaused = Duration.zero;
    _pausedDuringPrep = false;
    _status = TimerStatus.completed;
    _sound.playComplete();
    unawaited(_haptics.complete());
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
