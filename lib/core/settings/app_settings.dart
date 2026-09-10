import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../l10n/app_strings.dart';

enum AppearanceMode { system, light, dark }

/// Tailwind-inspired accents: Green, Lime, Sky, Violet, Amber.
enum AccentColor { green, lime, sky, violet, amber }

extension AccentColorLabel on AccentColor {
  String label(AppStrings s) {
    switch (this) {
      case AccentColor.green:
        return s.green;
      case AccentColor.lime:
        return s.lime;
      case AccentColor.sky:
        return s.sky;
      case AccentColor.violet:
        return s.violet;
      case AccentColor.amber:
        return s.amber;
    }
  }

  Color get color => AppColors.primaryFor(this);
}

/// In-memory app preferences. No persistence yet.
class AppSettings extends ChangeNotifier {
  AppearanceMode _appearance = AppearanceMode.system;
  AccentColor _accent = AccentColor.lime;
  bool _soundEnabled = true;
  AppLocale _locale = AppLocale.spanish;

  AppearanceMode get appearance => _appearance;
  AccentColor get accent => _accent;
  bool get soundEnabled => _soundEnabled;
  AppLocale get locale => _locale;

  AppStrings get strings => AppStrings(_locale);

  Color get primaryColor => AppColors.primaryFor(_accent);

  Brightness? get brightnessOverride {
    switch (_appearance) {
      case AppearanceMode.system:
        return null;
      case AppearanceMode.light:
        return Brightness.light;
      case AppearanceMode.dark:
        return Brightness.dark;
    }
  }

  void setAppearance(AppearanceMode mode) {
    if (_appearance == mode) return;
    _appearance = mode;
    notifyListeners();
  }

  void setAccent(AccentColor accent) {
    if (_accent == accent) return;
    _accent = accent;
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    if (_soundEnabled == enabled) return;
    _soundEnabled = enabled;
    notifyListeners();
  }

  void setLocale(AppLocale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}
