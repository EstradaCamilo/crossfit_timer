import 'package:flutter/cupertino.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../timer/domain/timer_phase.dart';
import '../../timer/domain/timer_status.dart';
import '../../timer/domain/timer_type.dart';
import '../../timer/logic/timer_controller.dart';
import '../../timer/presentation/widgets/config_sheets.dart';
import '../../timer/presentation/widgets/timer_controls.dart';
import '../../timer/presentation/widgets/timer_display.dart';
import '../../timer/presentation/widgets/timer_mode_selector.dart';
import '../../settings/presentation/settings_page.dart';
import 'widgets/app_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.settings,
    required this.timerController,
  });

  final AppSettings settings;
  final TimerController timerController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _minutes;
  late int _seconds;
  late int _restMinutes;
  late int _restSeconds;
  late int _rounds;

  AppSettings get _settings => widget.settings;
  TimerController get _timer => widget.timerController;
  AppStrings get _s => _settings.strings;

  @override
  void initState() {
    super.initState();
    _syncFromConfig();
  }

  void _syncFromConfig() {
    final d = _timer.config.duration;
    _minutes = d.inMinutes.clamp(0, 99);
    _seconds = d.inSeconds.remainder(60);
    final r = _timer.config.restDuration;
    _restMinutes = r.inMinutes.clamp(0, 99);
    _restSeconds = r.inSeconds.remainder(60);
    _rounds = _timer.config.rounds.clamp(1, 99);
  }

  void _onModeSelected(TimerType type) {
    _timer.setType(type);
    setState(_syncFromConfig);
  }

  void _onPrimary() {
    switch (_timer.status) {
      case TimerStatus.idle:
      case TimerStatus.completed:
        _timer.start();
      case TimerStatus.getReady:
      case TimerStatus.running:
        _timer.pause();
      case TimerStatus.paused:
        _timer.resume();
    }
  }

  String? _subtitle() {
    final type = _timer.type;
    switch (_timer.status) {
      case TimerStatus.idle:
        if (type == TimerType.emom || type == TimerType.tabata) {
          return _s.roundsCount(_rounds);
        }
        return null;
      case TimerStatus.getReady:
        return _s.getReady;
      case TimerStatus.running:
      case TimerStatus.paused:
        if (_timer.isInPrep && _timer.status == TimerStatus.paused) {
          return '${_s.getReady} · ${_s.paused}';
        }
        if (type == TimerType.emom) {
          final base = _s.roundOf(_timer.currentRound, _timer.totalRounds);
          if (_timer.status == TimerStatus.paused) {
            return '$base · ${_s.paused}';
          }
          return base;
        }
        if (type == TimerType.tabata) {
          final phase =
              _timer.phase == TimerPhase.work ? _s.working : _s.resting;
          final base =
              '${_s.roundOf(_timer.currentRound, _timer.totalRounds)} · $phase';
          if (_timer.status == TimerStatus.paused) {
            return '$base · ${_s.paused}';
          }
          return base;
        }
        if (_timer.status == TimerStatus.paused) return _s.paused;
        return null;
      case TimerStatus.completed:
        return _s.complete;
    }
  }

  Duration _displayDuration() {
    if (_timer.isIdle) {
      return Duration(minutes: _minutes, seconds: _seconds);
    }
    return _timer.displayTime;
  }

  double _displayProgress() {
    if (_timer.isIdle) return 1.0;
    if (_timer.isCompleted) return 0.0;
    return _timer.progress;
  }

  bool get _canStart {
    if (_minutes == 0 && _seconds == 0) return false;
    if (_timer.type == TimerType.tabata &&
        _restMinutes == 0 &&
        _restSeconds == 0) {
      return false;
    }
    return true;
  }

  bool get _canEdit => _timer.isIdle || _timer.isCompleted;

  String _primaryLabel() {
    switch (_timer.type) {
      case TimerType.emom:
        return _s.interval;
      case TimerType.forTime:
      case TimerType.amrap:
        return _s.timeCap;
      case TimerType.tabata:
        return _s.work;
      case TimerType.intervals:
        return _s.duration;
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => SettingsPage(settings: _settings),
      ),
    );
  }

  Future<void> _editPrimaryDuration() async {
    if (!_canEdit) return;
    final result = await showDurationSheet(
      context: context,
      strings: _s,
      title: _primaryLabel(),
      initial: Duration(minutes: _minutes, seconds: _seconds),
    );
    if (result == null || !mounted) return;
    setState(() {
      _minutes = result.inMinutes.clamp(0, 99);
      _seconds = result.inSeconds.remainder(60);
    });
    _timer.setDuration(result);
  }

  Future<void> _editRestDuration() async {
    if (!_canEdit) return;
    final result = await showDurationSheet(
      context: context,
      strings: _s,
      title: _s.rest,
      initial: Duration(minutes: _restMinutes, seconds: _restSeconds),
    );
    if (result == null || !mounted) return;
    setState(() {
      _restMinutes = result.inMinutes.clamp(0, 99);
      _restSeconds = result.inSeconds.remainder(60);
    });
    _timer.setRestDuration(result);
  }

  Future<void> _editRounds() async {
    if (!_canEdit) return;
    final result = await showRoundsSheet(
      context: context,
      strings: _s,
      initial: _rounds,
    );
    if (result == null || !mounted) return;
    setState(() => _rounds = result);
    _timer.setRounds(result);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_settings, _timer]),
      builder: (context, _) {
        final accent = _settings.primaryColor;
        final s = _s;
        final showConfig = _canEdit;
        final bg = AppColors.resolve(AppColors.background, context);
        final ringAccent = _timer.type == TimerType.tabata &&
                _timer.phase == TimerPhase.rest &&
                _timer.isRunning
            ? AppColors.warning
            : accent;

        return CupertinoPageScaffold(
          backgroundColor: bg,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            AppHeader(
                              title: s.appName,
                              handle: s.handle,
                              accentColor: accent,
                              onSettings: _openSettings,
                            ),
                            TimerModeSelector(
                              selected: _timer.type,
                              accentColor: accent,
                              enabled: showConfig,
                              onSelected: _onModeSelected,
                            ),
                            const Spacer(flex: 2),
                            CrossFitTimerDisplay(
                              remaining: _displayDuration(),
                              status: _timer.status,
                              accentColor: ringAccent,
                              progress: _displayProgress(),
                              subtitle: _subtitle(),
                              prepSeconds: _timer.isGetReady
                                  ? _timer.prepSeconds
                                  : null,
                            ),
                            const SizedBox(height: 28),
                            // Fixed config block — Visibility keeps size so
                            // mode switches / running state don't jump.
                            SizedBox(
                              height: 168,
                              child: IgnorePointer(
                                ignoring: !showConfig,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: showConfig ? 1 : 0,
                                  child: Column(
                                    children: [
                                      ConfigValueButton(
                                        label: _primaryLabel(),
                                        value: formatClock(_minutes, _seconds),
                                        accentColor: accent,
                                        onTap: _editPrimaryDuration,
                                      ),
                                      Visibility(
                                        visible:
                                            _timer.type == TimerType.tabata,
                                        maintainSize: true,
                                        maintainAnimation: true,
                                        maintainState: true,
                                        child: ConfigValueButton(
                                          label: s.rest,
                                          value: formatClock(
                                            _restMinutes,
                                            _restSeconds,
                                          ),
                                          accentColor: accent,
                                          onTap: _editRestDuration,
                                        ),
                                      ),
                                      Visibility(
                                        visible: _timer.config.usesRounds,
                                        maintainSize: true,
                                        maintainAnimation: true,
                                        maintainState: true,
                                        child: ConfigValueButton(
                                          label: s.rounds,
                                          value: '$_rounds',
                                          accentColor: accent,
                                          onTap: _editRounds,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(flex: 2),
                            TimerControls(
                              status: _timer.status,
                              accentColor: accent,
                              strings: s,
                              enabled: showConfig ? _canStart : true,
                              onPrimary: _onPrimary,
                              onReset: () {
                                _timer.reset();
                                setState(_syncFromConfig);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
