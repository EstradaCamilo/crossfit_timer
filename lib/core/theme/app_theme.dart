import 'package:flutter/cupertino.dart';

import '../settings/app_settings.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static CupertinoThemeData light(AccentColor accent) {
    final primary = AppColors.primaryFor(accent);
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      barBackgroundColor: AppColors.surfaceLight.withValues(alpha: 0.86),
      textTheme: _textTheme(
        primary: AppColors.textPrimaryLight,
        secondary: AppColors.textSecondaryLight,
        action: primary,
      ),
    );
  }

  static CupertinoThemeData dark(AccentColor accent) {
    final primary = AppColors.primaryFor(accent);
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      barBackgroundColor: AppColors.surfaceDark.withValues(alpha: 0.86),
      textTheme: _textTheme(
        primary: AppColors.textPrimaryDark,
        secondary: AppColors.textSecondaryDark,
        action: primary,
      ),
    );
  }

  static CupertinoTextThemeData _textTheme({
    required Color primary,
    required Color secondary,
    required Color action,
  }) {
    // System font (SF Pro on iOS) — no custom font packages.
    return CupertinoTextThemeData(
      primaryColor: action,
      textStyle: TextStyle(
        inherit: false,
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        letterSpacing: -0.41,
        color: primary,
        decoration: TextDecoration.none,
      ),
      actionTextStyle: TextStyle(
        inherit: false,
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        letterSpacing: -0.41,
        color: action,
        decoration: TextDecoration.none,
      ),
      tabLabelTextStyle: TextStyle(
        inherit: false,
        fontFamily: '.SF Pro Text',
        fontSize: 10,
        letterSpacing: -0.24,
        color: secondary,
        decoration: TextDecoration.none,
      ),
      navTitleTextStyle: TextStyle(
        inherit: false,
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: primary,
        decoration: TextDecoration.none,
      ),
      navLargeTitleTextStyle: TextStyle(
        inherit: false,
        fontFamily: '.SF Pro Display',
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.37,
        color: primary,
        decoration: TextDecoration.none,
      ),
      pickerTextStyle: TextStyle(
        inherit: false,
        fontFamily: '.SF Pro Display',
        fontSize: 23,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.48,
        color: primary,
        decoration: TextDecoration.none,
      ),
      dateTimePickerTextStyle: TextStyle(
        inherit: false,
        fontFamily: '.SF Pro Display',
        fontSize: 21,
        letterSpacing: -0.48,
        color: primary,
        decoration: TextDecoration.none,
      ),
    );
  }
}
