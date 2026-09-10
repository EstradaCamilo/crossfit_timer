import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../services/haptic_service.dart';
import '../../../services/timer_sound_service.dart';
import '../domain/timer_config.dart';
import '../domain/timer_phase.dart';
import '../domain/timer_status.dart';
import '../domain/timer_type.dart';

/// Precise timer engine driven by wall-clock timestamps.
///
/// Audio plays [TimerSoundService.cueLeadIn] before each phase transition so
/// the clip ends as the next interval begins (prep → work, work → rest, etc.).
class TimerController extends ChangeNotifier {
  TimerController({
    TimerConfig? initialConfig,
    TimerSoundService? sound,
    this._haptics = const HapticService(),
  })  : _sound = sound ?? TimerSoundService(),
        _config = initialConfig ?? TimerConfig.defaultsFor(TimerType.forTime),
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
  int _currentRound = 1;
  TimerPhase _phase = TimerPhase.work;
  bool _pausedDuringPrep = false;
  bool _leadInPlayed = false;

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

  int get prepSeconds {
    final s = remaining.inMilliseconds;
    if (s <= 0) return 0;
    return ((s + 999) ~/ 1000).clamp(0, prepDuration.inSeconds);
  }

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
    unawaited(_sound.stop());
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
    _currentRound = 1;
    _pausedDuringPrep = false;
    _leadInPlayed = false;
    notifyListeners();
  }

  void start() {
    if (!canStart) return;

    _phase = TimerPhase.work;
    _currentRound = 1;
    _pausedDuringPrep = false;
    _completionSignaled = false;
    _leadInPlayed = false;

    _remainingWhenPaused = prepDuration;
    _endAt = DateTime.now().add(prepDuration);
    _status = TimerStatus.getReady;

    // If prep is shorter than the clip, start cue immediately.
    _maybePlayLeadIn(prepDuration);

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
    unawaited(_sound.stop());
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
      _maybePlayLeadIn(left);
      notifyListeners();
      return;
    }

    if (_status != TimerStatus.running) return;

    final left = remaining;
    if (left <= Duration.zero) {
      if (_config.type == TimerType.emom || _config.type == TimerType.tabata) {
        _advanceSegment();
      } else {
        _complete();
      }
      return;
    }

    // Lead-in before next phase / finish (EMOM, Tabata, AMRAP, For Time).
    _maybePlayLeadIn(left);
    notifyListeners();
  }

  /// Plays the cue once when [left] enters the lead-in window.
  void _maybePlayLeadIn(Duration left) {
    if (_leadInPlayed) return;
    final lead = _sound.cueLeadIn;
    if (left > lead) return;

    _leadInPlayed = true;
    _sound.playCue();
    unawaited(_haptics.countdown());
  }

  void _beginWorkout() {
    _pausedDuringPrep = false;
    final duration = _config.duration;
    if (duration <= Duration.zero) {
      _complete();
      return;
    }
    _beginSegment(duration);
    unawaited(_haptics.start());
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
      unawaited(_haptics.roundChange());
      notifyListeners();
      return;
    }

    if (_config.type == TimerType.tabata) {
      if (_phase == TimerPhase.work) {
        _phase = TimerPhase.rest;
        _beginSegment(_config.restDuration);
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
      unawaited(_haptics.roundChange());
      notifyListeners();
      return;
    }

    _complete();
  }

  void _beginSegment(Duration duration) {
    _remainingWhenPaused = duration;
    _endAt = DateTime.now().add(duration);
    _status = TimerStatus.running;
    _leadInPlayed = false;

    // Short intervals: start cue immediately so it still leads the next change.
    if (duration <= _sound.cueLeadIn) {
      _maybePlayLeadIn(duration);
    }

    if (_ticker == null) _startTicker();
  }

  void _complete() {
    if (_completionSignaled) return;
    _completionSignaled = true;
    _stopTicker();
    _endAt = null;
    _remainingWhenPaused = Duration.zero;
    _pausedDuringPrep = false;
    _status = TimerStatus.completed;
    // Lead-in already played near the end of the last segment — no second cue.
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
