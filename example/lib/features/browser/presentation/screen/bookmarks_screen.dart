import 'package:flutter/material.dart';
import '../../../../core/utils/app_theme.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Bookmarks"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.panelBackground,
                shape: BoxShape.circle,
                border: Border.all(color: colors.dividerColor, width: 1.5),
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                color: colors.textSecondary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Bookmarks is Coming Soon",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "We're working hard to bring this feature to you.",
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
