import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

/// Centered brand header with settings anchored to the trailing edge.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.handle,
    required this.onSettings,
    required this.accentColor,
  });

  final String title;
  final String handle;
  final VoidCallback onSettings;
  final Color accentColor;

  static const double _actionSize = 40;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.resolve(AppColors.textPrimary, context);
    final secondary = AppColors.resolve(AppColors.textSecondary, context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 18),
      child: SizedBox(
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // True visual center for title + handle.
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    height: 1.1,
                    color: primary,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  handle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                    color: secondary.withValues(alpha: 0.7),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _actionSize,
                height: _actionSize,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onSettings,
                  child: Icon(
                    CupertinoIcons.gear,
                    color: accentColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
