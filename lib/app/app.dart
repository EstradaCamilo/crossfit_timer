import 'package:flutter/cupertino.dart';

import '../core/settings/app_settings.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_page.dart';
import '../features/timer/logic/timer_controller.dart';
import '../services/haptic_service.dart';
import '../services/timer_sound_service.dart';

class CrossFitTimerApp extends StatefulWidget {
  const CrossFitTimerApp({super.key});

  @override
  State<CrossFitTimerApp> createState() => _CrossFitTimerAppState();
}

class _CrossFitTimerAppState extends State<CrossFitTimerApp> {
  late final AppSettings _settings;
  late final TimerController _timerController;

  @override
  void initState() {
    super.initState();
    _settings = AppSettings();
    _timerController = TimerController(
      sound: TimerSoundService(enabled: _settings.soundEnabled),
      haptics: const HapticService(),
    );
    _settings.addListener(_syncServices);
  }

  void _syncServices() {
    _timerController.updateServices(
      sound: TimerSoundService(enabled: _settings.soundEnabled),
      haptics: const HapticService(),
    );
  }

  @override
  void dispose() {
    _settings.removeListener(_syncServices);
    _timerController.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final accent = _settings.accent;
        return CupertinoApp(
          title: 'CrossFit Timer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(accent),
          // CupertinoApp picks dark via MediaQuery when brightness is dark
          // if we also honor forced appearance via builder below.
          builder: (context, child) {
            final override = _settings.brightnessOverride;
            final media = MediaQuery.of(context);
            final platform = media.platformBrightness;
            final brightness = override ?? platform;

            return MediaQuery(
              data: media.copyWith(platformBrightness: brightness),
              child: CupertinoTheme(
                data: brightness == Brightness.dark
                    ? AppTheme.dark(accent)
                    : AppTheme.light(accent),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: HomePage(
            settings: _settings,
            timerController: _timerController,
          ),
        );
      },
    );
  }
}
