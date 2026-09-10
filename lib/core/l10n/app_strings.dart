enum AppLocale { spanish, english }

/// Lightweight in-app strings (no external i18n package).
class AppStrings {
  const AppStrings(this.locale);

  final AppLocale locale;

  bool get isSpanish => locale == AppLocale.spanish;

  String get settings => isSpanish ? 'Ajustes' : 'Settings';
  String get appearance => isSpanish ? 'Apariencia' : 'Appearance';
  String get accentColor => isSpanish ? 'Color de acento' : 'Accent color';
  String get soundSection => isSpanish ? 'Sonido' : 'Sound';
  String get language => isSpanish ? 'Idioma' : 'Language';
  String get spanish => 'Español';
  String get english => 'English';
  String get sound => isSpanish ? 'Sonido' : 'Sound';

  String get system => isSpanish ? 'Sistema' : 'System';
  String get light => isSpanish ? 'Claro' : 'Light';
  String get dark => isSpanish ? 'Oscuro' : 'Dark';

  String get green => isSpanish ? 'Verde' : 'Green';
  String get lime => isSpanish ? 'Lima' : 'Lime';
  String get sky => isSpanish ? 'Cielo' : 'Sky';
  String get violet => isSpanish ? 'Violeta' : 'Violet';
  String get amber => isSpanish ? 'Ámbar' : 'Amber';

  String get start => isSpanish ? 'Iniciar' : 'Start';
  String get pause => isSpanish ? 'Pausar' : 'Pause';
  String get resume => isSpanish ? 'Reanudar' : 'Resume';
  String get reset => isSpanish ? 'Reiniciar' : 'Reset';
  String get cancel => isSpanish ? 'Cancelar' : 'Cancel';
  String get done => isSpanish ? 'Listo' : 'Done';

  String get appName => 'CrossFit Timer';
  String get handle => '_camiloestrada';

  String get duration => isSpanish ? 'Duración' : 'Duration';
  String get timeCap => isSpanish ? 'Límite de tiempo' : 'Time cap';
  String get interval => isSpanish ? 'Intervalo' : 'Interval';
  String get work => isSpanish ? 'Trabajo' : 'Work';
  String get rest => isSpanish ? 'Descanso' : 'Rest';
  String get rounds => isSpanish ? 'Rondas' : 'Rounds';
  String get round => isSpanish ? 'Ronda' : 'Round';
  String get paused => isSpanish ? 'Pausado' : 'Paused';
  String get complete => isSpanish ? 'Completado' : 'Complete';
  String get min => isSpanish ? 'min' : 'min';
  String get sec => isSpanish ? 'seg' : 'sec';

  String roundsCount(int n) =>
      isSpanish ? '$n rondas' : '$n rounds';

  String roundOf(int current, int total) =>
      isSpanish ? 'Ronda $current/$total' : 'Round $current/$total';

  String get working => isSpanish ? 'Trabajo' : 'Work';
  String get resting => isSpanish ? 'Descanso' : 'Rest';
}
