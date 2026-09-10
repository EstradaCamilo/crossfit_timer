import 'package:flutter/cupertino.dart';

import '../settings/app_settings.dart';

/// Tailwind CSS default color scales (hex equivalents).
/// Source: https://tailwindcss.com/docs/colors

abstract final class TailwindGreen {
  static const Color shade50 = Color(0xFFF0FDF4);
  static const Color shade100 = Color(0xFFDCFCE7);
  static const Color shade200 = Color(0xFFBBF7D0);
  static const Color shade300 = Color(0xFF86EFAC);
  static const Color shade400 = Color(0xFF4ADE80);
  static const Color shade500 = Color(0xFF22C55E);
  static const Color shade600 = Color(0xFF16A34A);
  static const Color shade700 = Color(0xFF15803D);
  static const Color shade800 = Color(0xFF166534);
  static const Color shade900 = Color(0xFF14532D);
  static const Color shade950 = Color(0xFF052E16);
}

abstract final class TailwindLime {
  static const Color shade50 = Color(0xFFF7FEE7);
  static const Color shade100 = Color(0xFFECFCCB);
  static const Color shade200 = Color(0xFFD9F99D);
  static const Color shade300 = Color(0xFFBEF264);
  static const Color shade400 = Color(0xFFA3E635);
  static const Color shade500 = Color(0xFF84CC16);
  static const Color shade600 = Color(0xFF65A30D);
  static const Color shade700 = Color(0xFF4D7C0F);
  static const Color shade800 = Color(0xFF3F6212);
  static const Color shade900 = Color(0xFF365314);
  static const Color shade950 = Color(0xFF1A2E05);
}

abstract final class TailwindSky {
  static const Color shade50 = Color(0xFFF0F9FF);
  static const Color shade100 = Color(0xFFE0F2FE);
  static const Color shade200 = Color(0xFFBAE6FD);
  static const Color shade300 = Color(0xFF7DD3FC);
  static const Color shade400 = Color(0xFF38BDF8);
  static const Color shade500 = Color(0xFF0EA5E9);
  static const Color shade600 = Color(0xFF0284C7);
  static const Color shade700 = Color(0xFF0369A1);
  static const Color shade800 = Color(0xFF075985);
  static const Color shade900 = Color(0xFF0C4A6E);
  static const Color shade950 = Color(0xFF082F49);
}

abstract final class TailwindViolet {
  static const Color shade50 = Color(0xFFF5F3FF);
  static const Color shade100 = Color(0xFFEDE9FE);
  static const Color shade200 = Color(0xFFDDD6FE);
  static const Color shade300 = Color(0xFFC4B5FD);
  static const Color shade400 = Color(0xFFA78BFA);
  static const Color shade500 = Color(0xFF8B5CF6);
  static const Color shade600 = Color(0xFF7C3AED);
  static const Color shade700 = Color(0xFF6D28D9);
  static const Color shade800 = Color(0xFF5B21B6);
  static const Color shade900 = Color(0xFF4C1D95);
  static const Color shade950 = Color(0xFF2E1065);
}

abstract final class TailwindAmber {
  static const Color shade50 = Color(0xFFFFFBEB);
  static const Color shade100 = Color(0xFFFEF3C7);
  static const Color shade200 = Color(0xFFFDE68A);
  static const Color shade300 = Color(0xFFFCD34D);
  static const Color shade400 = Color(0xFFFBBF24);
  static const Color shade500 = Color(0xFFF59E0B);
  static const Color shade600 = Color(0xFFD97706);
  static const Color shade700 = Color(0xFFB45309);
  static const Color shade800 = Color(0xFF92400E);
  static const Color shade900 = Color(0xFF78350F);
  static const Color shade950 = Color(0xFF451A03);
}

/// Centralized color tokens. Accent comes from [AccentColor].
class AppColors {
  AppColors._();

  /// Main interactive accent (buttons, ring, selection).
  static Color primaryFor(AccentColor accent) {
    switch (accent) {
      case AccentColor.green:
        return TailwindGreen.shade500;
      case AccentColor.lime:
        return TailwindLime.shade500;
      case AccentColor.sky:
        return TailwindSky.shade500;
      case AccentColor.violet:
        return TailwindViolet.shade500;
      case AccentColor.amber:
        return TailwindAmber.shade500;
    }
  }

  static Color primaryStrongFor(AccentColor accent) {
    switch (accent) {
      case AccentColor.green:
        return TailwindGreen.shade600;
      case AccentColor.lime:
        return TailwindLime.shade600;
      case AccentColor.sky:
        return TailwindSky.shade600;
      case AccentColor.violet:
        return TailwindViolet.shade600;
      case AccentColor.amber:
        return TailwindAmber.shade600;
    }
  }

  static Color primarySoftFor(AccentColor accent) {
    switch (accent) {
      case AccentColor.green:
        return TailwindGreen.shade100;
      case AccentColor.lime:
        return TailwindLime.shade100;
      case AccentColor.sky:
        return TailwindSky.shade100;
      case AccentColor.violet:
        return TailwindViolet.shade100;
      case AccentColor.amber:
        return TailwindAmber.shade100;
    }
  }

  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color backgroundDark = Color(0xFF000000);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  static const Color textSecondaryLight = Color(0xFF8E8E93);
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  static const Color success = TailwindGreen.shade500;
  static const Color warning = TailwindAmber.shade500;
  static const Color danger = Color(0xFFEF4444);

  static const Color separatorLight = Color(0xFFC6C6C8);
  static const Color separatorDark = Color(0xFF38383A);

  static const CupertinoDynamicColor background = CupertinoDynamicColor(
    debugLabel: 'AppColors.background',
    color: backgroundLight,
    darkColor: backgroundDark,
    highContrastColor: backgroundLight,
    darkHighContrastColor: backgroundDark,
    elevatedColor: backgroundLight,
    darkElevatedColor: backgroundDark,
    highContrastElevatedColor: backgroundLight,
    darkHighContrastElevatedColor: backgroundDark,
  );

  static const CupertinoDynamicColor surface = CupertinoDynamicColor(
    debugLabel: 'AppColors.surface',
    color: surfaceLight,
    darkColor: surfaceDark,
    highContrastColor: surfaceLight,
    darkHighContrastColor: surfaceDark,
    elevatedColor: surfaceLight,
    darkElevatedColor: surfaceDark,
    highContrastElevatedColor: surfaceLight,
    darkHighContrastElevatedColor: surfaceDark,
  );

  static const CupertinoDynamicColor textPrimary = CupertinoDynamicColor(
    debugLabel: 'AppColors.textPrimary',
    color: textPrimaryLight,
    darkColor: textPrimaryDark,
    highContrastColor: textPrimaryLight,
    darkHighContrastColor: textPrimaryDark,
    elevatedColor: textPrimaryLight,
    darkElevatedColor: textPrimaryDark,
    highContrastElevatedColor: textPrimaryLight,
    darkHighContrastElevatedColor: textPrimaryDark,
  );

  static const CupertinoDynamicColor textSecondary = CupertinoDynamicColor(
    debugLabel: 'AppColors.textSecondary',
    color: textSecondaryLight,
    darkColor: textSecondaryDark,
    highContrastColor: textSecondaryLight,
    darkHighContrastColor: textSecondaryDark,
    elevatedColor: textSecondaryLight,
    darkElevatedColor: textSecondaryDark,
    highContrastElevatedColor: textSecondaryLight,
    darkHighContrastElevatedColor: textSecondaryDark,
  );

  static const CupertinoDynamicColor separator = CupertinoDynamicColor(
    debugLabel: 'AppColors.separator',
    color: separatorLight,
    darkColor: separatorDark,
    highContrastColor: separatorLight,
    darkHighContrastColor: separatorDark,
    elevatedColor: separatorLight,
    darkElevatedColor: separatorDark,
    highContrastElevatedColor: separatorLight,
    darkHighContrastElevatedColor: separatorDark,
  );

  static Color resolve(CupertinoDynamicColor color, BuildContext context) {
    return CupertinoDynamicColor.resolve(color, context);
  }
}
