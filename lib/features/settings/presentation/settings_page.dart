import 'package:flutter/cupertino.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final bg = AppColors.resolve(AppColors.background, context);
        final s = settings.strings;

        return CupertinoPageScaffold(
          backgroundColor: bg,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: bg.withValues(alpha: 0.92),
            middle: Text(s.settings),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
              children: [
                _SectionHeader(s.language),
                CupertinoListSection.insetGrouped(
                  backgroundColor: bg,
                  decoration: BoxDecoration(
                    color: AppColors.resolve(AppColors.surface, context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: [
                    _CheckRow(
                      title: s.spanish,
                      selected: settings.locale == AppLocale.spanish,
                      onTap: () => settings.setLocale(AppLocale.spanish),
                      accent: settings.primaryColor,
                    ),
                    _CheckRow(
                      title: s.english,
                      selected: settings.locale == AppLocale.english,
                      onTap: () => settings.setLocale(AppLocale.english),
                      accent: settings.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _SectionHeader(s.appearance),
                CupertinoListSection.insetGrouped(
                  backgroundColor: bg,
                  decoration: BoxDecoration(
                    color: AppColors.resolve(AppColors.surface, context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: [
                    for (final mode in AppearanceMode.values)
                      _CheckRow(
                        title: _appearanceLabel(mode, s),
                        selected: settings.appearance == mode,
                        onTap: () => settings.setAppearance(mode),
                        accent: settings.primaryColor,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _SectionHeader(s.accentColor),
                CupertinoListSection.insetGrouped(
                  backgroundColor: bg,
                  decoration: BoxDecoration(
                    color: AppColors.resolve(AppColors.surface, context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: [
                    for (final accent in AccentColor.values)
                      CupertinoListTile(
                        title: Text(accent.label(s)),
                        leading: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: accent.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        trailing: settings.accent == accent
                            ? Icon(
                                CupertinoIcons.check_mark,
                                color: settings.primaryColor,
                                size: 20,
                              )
                            : null,
                        onTap: () => settings.setAccent(accent),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _SectionHeader(s.soundSection),
                CupertinoListSection.insetGrouped(
                  backgroundColor: bg,
                  decoration: BoxDecoration(
                    color: AppColors.resolve(AppColors.surface, context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: [
                    CupertinoListTile(
                      title: Text(s.sound),
                      trailing: CupertinoSwitch(
                        value: settings.soundEnabled,
                        activeTrackColor: settings.primaryColor,
                        onChanged: settings.setSoundEnabled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _appearanceLabel(AppearanceMode mode, AppStrings s) {
    switch (mode) {
      case AppearanceMode.system:
        return s.system;
      case AppearanceMode.light:
        return s.light;
      case AppearanceMode.dark:
        return s.dark;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.08,
          color: AppColors.resolve(AppColors.textSecondary, context),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(title),
      trailing: selected
          ? Icon(CupertinoIcons.check_mark, color: accent, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
