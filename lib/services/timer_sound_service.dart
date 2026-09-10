/// Abstraction for timer audio cues. No concrete audio in Phase 1.
class TimerSoundService {
  const TimerSoundService({this.enabled = true});

  final bool enabled;

  void playStart() {
    if (!enabled) return;
    // Phase 2+: system sound / asset playback
  }

  void playCountdown() {
    if (!enabled) return;
  }

  void playRoundChange() {
    if (!enabled) return;
  }

  void playComplete() {
    if (!enabled) return;
  }
}
