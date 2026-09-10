import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

/// Brand header outside the navigation bar so the title can breathe.
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

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.resolve(AppColors.textPrimary, context);
    final secondary = AppColors.resolve(AppColors.textSecondary, context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 0, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
          ),
          CupertinoButton(
            padding: const EdgeInsets.only(left: 8, top: 2),
            onPressed: onSettings,
            child: Icon(
              CupertinoIcons.gear,
              color: accentColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
