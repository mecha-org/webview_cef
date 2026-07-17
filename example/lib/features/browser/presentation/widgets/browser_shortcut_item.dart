import 'package:flutter/material.dart';
import '../../../../core/utils/app_theme.dart';

class BrowserShortcutItem extends StatelessWidget {
  final String label;
  final String letter;
  final Color color;
  final VoidCallback onTap;

  const BrowserShortcutItem({
    super.key,
    required this.label,
    required this.letter,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: color,
              foregroundColor: colors.searchBarBackground,
              elevation: 0,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return colors.popupBarrierColor.withValues(alpha: 0.08);
                }
                if (states.contains(WidgetState.pressed)) {
                  return colors.popupBarrierColor.withValues(alpha: 0.16);
                }
                return null;
              }),
            ),
            child: Text(
              letter,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.searchBarBackground,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
