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

  TimerConfig get config => _config;
  TimerStatus get status => _status;
  TimerType get type => _config.type;
  int get currentRound => _currentRound;
  int get totalRounds => _config.rounds;
  TimerPhase get phase => _phase;

  /// Always remaining time (all modes count down to zero).
  Duration get displayTime => remaining;

  Duration get remaining {
    switch (_status) {
      case TimerStatus.idle:
      case TimerStatus.paused:
        return _remainingWhenPaused;
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

  /// 1.0 → full ring, 0.0 → empty for the active segment.
  double get progress {
    final totalMs = _segmentDuration.inMilliseconds;
    if (totalMs <= 0) return 0;
    final leftMs = remaining.inMilliseconds.clamp(0, totalMs);
    return leftMs / totalMs;
  }

  Duration get _segmentDuration {
    if (_config.type == TimerType.tabata && _phase == TimerPhase.rest) {
      return _config.restDuration;
    }
    return _config.duration;
  }

  bool get isIdle => _status == TimerStatus.idle;
  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isCompleted => _status == TimerStatus.completed;

  bool get canStart {
    if (_status != TimerStatus.idle && _status != TimerStatus.completed) {
      return false;
    }
    if (_config.duration <= Duration.zero) return false;
    if (_config.usesRest && _config.restDuration <= Duration.zero) return false;
    return true;
  }

  bool get canPause => _status == TimerStatus.running;
  bool get canResume => _status == TimerStatus.paused;

  void updateServices({
    required TimerSoundService sound,
    required HapticService haptics,
  }) {
    _sound = sound;
    _haptics = haptics;
  }

  void setType(TimerType type) {
    if (_status == TimerStatus.running || _status == TimerStatus.paused) {
      return;
    }
    if (_config.type == type) return;
    _applyConfig(TimerConfig.defaultsFor(type));
  }

  void setDuration(Duration duration) {
    if (_status == TimerStatus.running || _status == TimerStatus.paused) {
      return;
    }
    final clamped = duration < Duration.zero ? Duration.zero : duration;
    _applyConfig(_config.copyWith(duration: clamped), preserveIdleRemaining: true);
  }

  void setRestDuration(Duration duration) {
    if (_status == TimerStatus.running || _status == TimerStatus.paused) {
      return;
    }
    final clamped = duration < Duration.zero ? Duration.zero : duration;
    _applyConfig(_config.copyWith(restDuration: clamped), preserveIdleRemaining: true);
  }

  void setRounds(int rounds) {
    if (_status == TimerStatus.running || _status == TimerStatus.paused) {
      return;
    }
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
    notifyListeners();
  }

  void start() {
    if (!canStart) return;

    _phase = TimerPhase.work;
    _currentRound = 1;

    final duration = _config.duration;
    if (duration <= Duration.zero) return;
    _remainingWhenPaused = duration;
    _endAt = DateTime.now().add(duration);

    _status = TimerStatus.running;
    _completionSignaled = false;
    _lastCountdownCueSecond = null;
    _sound.playStart();
    unawaited(_haptics.start());
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (!canPause) return;
    _remainingWhenPaused = remaining;
    _endAt = null;
    _status = TimerStatus.paused;
    _stopTicker();
    notifyListeners();
  }

  void resume() {
    if (!canResume) return;
    if (_remainingWhenPaused <= Duration.zero) {
      _advanceSegment();
      return;
    }
    _endAt = DateTime.now().add(_remainingWhenPaused);
    _status = TimerStatus.running;
    _startTicker();
    notifyListeners();
  }

  void reset() {
    _applyConfig(_config);
  }

  void _tick() {
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
        // After work → rest (including after last round's work).
        _phase = TimerPhase.rest;
        _beginSegment(_config.restDuration);
        _sound.playRoundChange();
        unawaited(_haptics.roundChange());
        notifyListeners();
        return;
      }

      // After rest → next work round, or finish.
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
