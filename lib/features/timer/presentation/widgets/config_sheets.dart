import 'package:flutter/cupertino.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom sheet (action sheet style) to pick minutes + seconds.
Future<Duration?> showDurationSheet({
  required BuildContext context,
  required AppStrings strings,
  required String title,
  required Duration initial,
}) {
  var minutes = initial.inMinutes.clamp(0, 99);
  var seconds = initial.inSeconds.remainder(60);

  return showCupertinoModalPopup<Duration>(
    context: context,
    builder: (context) {
      return Container(
        height: 300,
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppColors.resolve(AppColors.surface, context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(strings.cancel),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                        fontSize: 17,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          Duration(minutes: minutes, seconds: seconds),
                        );
                      },
                      child: Text(strings.done),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController:
                            FixedExtentScrollController(initialItem: minutes),
                        itemExtent: 40,
                        magnification: 1.08,
                        useMagnifier: true,
                        onSelectedItemChanged: (i) => minutes = i,
                        children: [
                          for (var i = 0; i <= 99; i++)
                            Center(
                              child: Text(
                                '${i.toString().padLeft(2, '0')} ${strings.min}',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController:
                            FixedExtentScrollController(initialItem: seconds),
                        itemExtent: 40,
                        magnification: 1.08,
                        useMagnifier: true,
                        onSelectedItemChanged: (i) => seconds = i,
                        children: [
                          for (var i = 0; i <= 59; i++)
                            Center(
                              child: Text(
                                '${i.toString().padLeft(2, '0')} ${strings.sec}',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Bottom sheet to pick round count.
Future<int?> showRoundsSheet({
  required BuildContext context,
  required AppStrings strings,
  required int initial,
}) {
  var draft = initial.clamp(1, 99);

  return showCupertinoModalPopup<int>(
    context: context,
    builder: (context) {
      return Container(
        height: 280,
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppColors.resolve(AppColors.surface, context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(strings.cancel),
                    ),
                    Text(
                      strings.rounds,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                        fontSize: 17,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context, draft),
                      child: Text(strings.done),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: draft - 1),
                  itemExtent: 40,
                  onSelectedItemChanged: (i) => draft = i + 1,
                  children: [
                    for (var i = 1; i <= 99; i++) Center(child: Text('$i')),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Compact tappable row used on Home instead of inline wheels.
class ConfigValueButton extends StatelessWidget {
  const ConfigValueButton({
    super.key,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.onTap,
    this.showBottomPadding = true,
  });

  final String label;
  final String value;
  final Color accentColor;
  final VoidCallback onTap;
  final bool showBottomPadding;

  @override
  Widget build(BuildContext context) {
    final secondary = AppColors.resolve(AppColors.textSecondary, context);

    return Padding(
      padding: EdgeInsets.only(bottom: showBottomPadding ? 8 : 0),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: secondary,
                  decoration: TextDecoration.none,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: accentColor,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_up_chevron_down,
                size: 14,
                color: secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Groups config rows into one surface so modes like EMOM stay visually united.
class ConfigGroup extends StatelessWidget {
  const ConfigGroup({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final surface = AppColors.resolve(AppColors.surface, context);
    final separator = AppColors.resolve(AppColors.separator, context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Container(
                height: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: separator.withValues(alpha: 0.55),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

String formatClock(int minutes, int seconds) {
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
