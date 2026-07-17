import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_cef_example/l10n/app_localizations.dart';
import 'package:webview_cef_example/features/browser/bloc/browser_bloc.dart';
import '../../../../core/utils/app_theme.dart';

class TabSwitcherSheet extends StatelessWidget {
  final BrowserBloc bloc;

  const TabSwitcherSheet({super.key, required this.bloc});

  static void show(BuildContext context, BrowserBloc bloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BlocProvider.value(
          value: bloc,
          child: TabSwitcherSheet(bloc: bloc),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: BlocBuilder<BrowserBloc, BrowserState>(
        builder: (context, state) {
          return Column(
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.dragHandle,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 16),
              // Tab grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: state.tabs.length,
                  itemBuilder: (context, index) {
                    final tab = state.tabs[index];
                    final isActive = index == state.activeTabIndex;

                    // Clean URL/title for display
                    String displayUrl = l10n.newTab;
                    if (tab.currentUrl.isNotEmpty) {
                      try {
                        final uri = Uri.parse(tab.currentUrl);
                        displayUrl =
                            uri.host.isNotEmpty ? uri.host : tab.currentUrl;
                      } catch (_) {
                        displayUrl = tab.currentUrl;
                      }
                    }
                    final title = tab.title.isNotEmpty ? tab.title : displayUrl;

                    return GestureDetector(
                      onTap: () {
                        bloc.add(BrowserSwitchTabRequested(index));
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.popupBottomButtonBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive
                                ? colors.accentActive
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Card preview placeholder/icon
                            Center(
                              child: Icon(
                                Icons.public,
                                size: 48,
                                color: colors.dragHandle,
                              ),
                            ),
                            // Title & Close Button at the bottom
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                color: colors.popupBarrierColor.withValues(alpha: 0.45),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colors.searchBarText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        bloc.add(
                                            BrowserCloseTabRequested(index));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: colors.closeButtonBackground,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: colors.searchBarText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      bloc.add(const BrowserCloseAllTabsRequested());
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: colors.searchBarText,
                      backgroundColor: colors.popupBottomButtonBackground,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.closeAll,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
