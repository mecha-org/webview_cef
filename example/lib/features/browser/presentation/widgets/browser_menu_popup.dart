import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_cef_example/core/routes/app_routes.dart';
import 'package:webview_cef_example/features/browser/bloc/browser_bloc.dart';
import 'package:webview_cef_example/l10n/app_localizations.dart';

import '../../../../core/utils/app_theme.dart';

class BrowserMenuPopupContent extends StatefulWidget {
  final BrowserBloc bloc;
  final VoidCallback onDismiss;
  final VoidCallback? onFindInPage;

  const BrowserMenuPopupContent({
    super.key,
    required this.bloc,
    required this.onDismiss,
    this.onFindInPage,
  });

  @override
  State<BrowserMenuPopupContent> createState() =>
      _BrowserMenuPopupContentState();
}

class _BrowserMenuPopupContentState extends State<BrowserMenuPopupContent> {
  bool isDesktopSite = false;

  void _toggleDesktopSite(bool newValue) {
    setState(() {
      isDesktopSite = newValue;
    });
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDesktopSite ? l10n.desktopSiteEnabled : l10n.desktopSiteDisabled,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<BrowserBloc, BrowserState>(
      bloc: widget.bloc,
      builder: (context, state) {
        return Container(
          width: 346,
          height: 395,
          decoration: BoxDecoration(
            color: colors.panelBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.panelBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.popupBarrierColor.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Upper List Section
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _MenuPopupListTile(
                        icon: Icons.add,
                        label: l10n.newTab,
                        onTap: () {
                          widget.onDismiss();
                          if (state.isInitialized) {
                            widget.bloc.add(const BrowserNewTabRequested());
                          }
                        },
                      ),
                      _MenuPopupListTile(
                        icon: Icons.visibility_off_outlined,
                        label: l10n.newPrivateTab,
                        onTap: () {
                          widget.onDismiss();
                          if (state.isInitialized) {
                            widget.bloc.add(BrowserGoHomeRequested());
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.privateTabOpened),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      _MenuPopupListTile(
                        icon: Icons.history,
                        label: l10n.history,
                        onTap: () {
                          widget.onDismiss();
                          Navigator.pushNamed(context, AppRoutes.history);
                        },
                      ),
                      _MenuPopupListTile(
                        icon: Icons.bookmark_border_rounded,
                        label: l10n.bookmarks,
                        onTap: () {
                          widget.onDismiss();
                          Navigator.pushNamed(context, AppRoutes.bookmarks);
                        },
                      ),
                      _MenuPopupListTile(
                        icon: Icons.download_outlined,
                        label: l10n.downloads,
                        onTap: () {
                          widget.onDismiss();
                          Navigator.pushNamed(context, AppRoutes.downloads);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: colors.panelBorder,
                          height: 16,
                          thickness: 1,
                        ),
                      ),
                      _MenuPopupListTile(
                        icon: Icons.share_outlined,
                        label: l10n.share,
                        onTap: () {
                          widget.onDismiss();
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.sharingPage),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      _MenuPopupListTile(
                        icon: Icons.computer_outlined,
                        label: l10n.desktopSite,
                        trailing: Checkbox(
                          value: isDesktopSite,
                          activeColor: colors.accentActive,
                          checkColor: colors.searchBarText,
                          onChanged: (val) {
                            _toggleDesktopSite(val ?? false);
                          },
                        ),
                        onTap: () {
                          _toggleDesktopSite(!isDesktopSite);
                        },
                      ),
                      _MenuPopupListTile(
                        icon: Icons.settings_outlined,
                        label: l10n.settings,
                        onTap: () {
                          widget.onDismiss();
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              Divider(
                color: colors.panelBorder,
                height: 1,
                thickness: 1,
              ),
              // Bottom Navigation Row Section
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: colors.popupBottomBackground,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MenuPopupButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () {
                        widget.onDismiss();
                        if (state.isInitialized) {
                          widget.bloc.add(BrowserGoBackRequested());
                        }
                      },
                    ),
                    _MenuPopupButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: () {
                        widget.onDismiss();
                        if (state.isInitialized) {
                          widget.bloc.add(BrowserGoForwardRequested());
                        }
                      },
                    ),
                    _MenuPopupButton(
                      icon: Icons.refresh_rounded,
                      onTap: () {
                        widget.onDismiss();
                        if (state.isInitialized) {
                          widget.bloc.add(BrowserReloadRequested());
                        }
                      },
                    ),
                    _MenuPopupButton(
                      icon: Icons.bookmark_border_rounded,
                      onTap: () {
                        widget.onDismiss();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.pageBookmarked),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _MenuPopupButton(
                      icon: Icons.search_rounded,
                      onTap: () {
                        widget.onDismiss();
                        widget.onFindInPage?.call();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuPopupListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuPopupListTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      ),
      trailing: trailing,
      dense: true,
      hoverColor: colors.closeButtonBackground.withValues(alpha: 0.4),
      splashColor: colors.closeButtonBackground,
      onTap: onTap,
    );
  }
}

class _MenuPopupButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MenuPopupButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    return Material(
      color: colors.popupBottomButtonBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: colors.closeButtonBackground,
        hoverColor: colors.shortcutHoverBackground,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: colors.searchBarText, size: 20),
        ),
      ),
    );
  }
}
