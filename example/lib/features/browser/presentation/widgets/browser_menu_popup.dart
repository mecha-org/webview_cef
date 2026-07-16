import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_cef_example/core/routes/app_routes.dart';
import 'package:webview_cef_example/features/browser/bloc/browser_bloc.dart';

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
    // Clear any active snackbars to prevent layout queueing
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDesktopSite ? "Desktop site enabled" : "Desktop site disabled",
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserBloc, BrowserState>(
      bloc: widget.bloc,
      builder: (context, state) {
        return Container(
          width: 346,
          height: 395,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, 8),
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
                      _buildListTile(
                        context,
                        icon: Icons.add,
                        label: "New tab",
                        onTap: () {
                          widget.onDismiss();
                          if (state.isInitialized) {
                            widget.bloc.add(const BrowserNewTabRequested());
                          }
                        },
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.visibility_off_outlined,
                        label: "New Private Tab",
                        onTap: () {
                          widget.onDismiss();
                          if (state.isInitialized) {
                            widget.bloc.add(BrowserGoHomeRequested());
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Private tab opened"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.history,
                        label: "History",
                        onTap: () {
                          widget.onDismiss();
                          Navigator.pushNamed(context, AppRoutes.history);
                        },
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.bookmark_border_rounded,
                        label: "Bookmarks",
                        onTap: () {
                          widget.onDismiss();
                          Navigator.pushNamed(context, AppRoutes.bookmarks);
                        },
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.download_outlined,
                        label: "Downloads",
                        onTap: () {
                          widget.onDismiss();
                          Navigator.pushNamed(context, AppRoutes.downloads);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.08),
                          height: 16,
                          thickness: 1,
                        ),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.share_outlined,
                        label: "Share",
                        onTap: () {
                          widget.onDismiss();
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Sharing page..."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.computer_outlined,
                        label: "Desktop site",
                        trailing: Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Checkbox(
                            value: isDesktopSite,
                            activeColor: Colors.blueAccent,
                            checkColor: Colors.white,
                            onChanged: (val) {
                              _toggleDesktopSite(val ?? false);
                            },
                          ),
                        ),
                        onTap: () {
                          _toggleDesktopSite(!isDesktopSite);
                        },
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.settings_outlined,
                        label: "Settings",
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
                color: Colors.white.withValues(alpha: 0.08),
                height: 1,
                thickness: 1,
              ),
              // Bottom Navigation Row Section
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF151515),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBottomButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () {
                        widget.onDismiss();
                        if (state.isInitialized) {
                          widget.bloc.add(BrowserGoBackRequested());
                        }
                      },
                    ),
                    _buildBottomButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: () {
                        widget.onDismiss();
                        if (state.isInitialized) {
                          widget.bloc.add(BrowserGoForwardRequested());
                        }
                      },
                    ),
                    _buildBottomButton(
                      icon: Icons.refresh_rounded,
                      onTap: () {
                        widget.onDismiss();
                        if (state.isInitialized) {
                          widget.bloc.add(BrowserReloadRequested());
                        }
                      },
                    ),
                    _buildBottomButton(
                      icon: Icons.bookmark_border_rounded,
                      onTap: () {
                        widget.onDismiss();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Page bookmarked"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildBottomButton(
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

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8E8E93), size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailing,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      hoverColor: Colors.white.withValues(alpha: 0.05),
      splashColor: Colors.white.withValues(alpha: 0.1),
      onTap: onTap,
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF2C2C2E),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.white.withValues(alpha: 0.12),
        hoverColor: Colors.white.withValues(alpha: 0.24),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
