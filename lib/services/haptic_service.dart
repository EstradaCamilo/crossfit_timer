import 'package:flutter/services.dart';

/// Centralized haptic feedback for timer events (iOS-friendly).
class HapticService {
  const HapticService({this.enabled = true});

  final bool enabled;

  Future<void> start() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> countdown() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> roundChange() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> complete() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }
}
