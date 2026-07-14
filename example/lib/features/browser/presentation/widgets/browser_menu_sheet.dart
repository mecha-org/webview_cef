import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_cef/webview_cef.dart';
import 'package:webview_cef_example/features/browser/bloc/browser_bloc.dart';

void showBrowserMenuSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF161616),
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final bloc = context.read<BrowserBloc>();
      final state = bloc.state;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildMenuItem(
                  icon: Icons.arrow_back,
                  label: "Back",
                  onTap: () {
                    Navigator.pop(context);
                    if (state.isInitialized) {
                      bloc.add(BrowserGoBackRequested());
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.arrow_forward,
                  label: "Forward",
                  onTap: () {
                    Navigator.pop(context);
                    if (state.isInitialized) {
                      bloc.add(BrowserGoForwardRequested());
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.refresh,
                  label: "Reload",
                  onTap: () {
                    Navigator.pop(context);
                    if (state.isInitialized) {
                      bloc.add(BrowserReloadRequested());
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.home_outlined,
                  label: "Home",
                  onTap: () {
                    Navigator.pop(context);
                    if (state.isInitialized) {
                      bloc.add(BrowserGoHomeRequested());
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.developer_mode,
                  label: "DevTools",
                  onTap: () {
                    Navigator.pop(context);
                    if (state.isInitialized) {
                      bloc.add(BrowserDevToolsRequested());
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.close,
                  label: "Quit",
                  onTap: () {
                    Navigator.pop(context);
                    WebviewManager().quit();
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildMenuItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
