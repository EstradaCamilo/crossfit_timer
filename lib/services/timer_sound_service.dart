import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Timer audio cues. One shared asset; play [cueLeadIn] before a phase starts
/// so the clip finishes as the interval begins.
class TimerSoundService {
  TimerSoundService({this.enabled = true});

  static const String _assetPath = 'sounds/start-beeps.mp3';

  /// Measured length of [start-beeps.mp3] (~4.05s). Used as lead-in.
  static const Duration defaultCueLeadIn = Duration(milliseconds: 4050);

  bool enabled;
  final AudioPlayer _player = AudioPlayer();
  Duration cueLeadIn = defaultCueLeadIn;
  bool _warmedUp = false;

  /// Resolves clip duration once so lead-in stays accurate.
  Future<void> warmUp() async {
    if (_warmedUp) return;
    try {
      await _player.setSource(AssetSource(_assetPath));
      final duration = await _player.getDuration();
      if (duration != null && duration > Duration.zero) {
        cueLeadIn = duration;
      }
      _warmedUp = true;
    } catch (_) {
      cueLeadIn = defaultCueLeadIn;
    }
  }

  void playCue() => unawaited(_play());

  // Keep named APIs for call sites / future distinct assets.
  void playStart() => playCue();
  void playCountdown() => playCue();
  void playRoundChange() => playCue();
  void playComplete() => playCue();

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> _play() async {
    if (!enabled) return;
    try {
      await warmUp();
      await _player.stop();
      await _player.play(AssetSource(_assetPath));
    } catch (_) {
      // Ignore playback failures (web autoplay, missing asset, etc.).
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
