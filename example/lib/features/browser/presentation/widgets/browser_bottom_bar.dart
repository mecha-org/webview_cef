import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_cef_example/features/browser/bloc/browser_bloc.dart';
import 'package:webview_cef_example/features/browser/presentation/widgets/browser_menu_sheet.dart';
import 'package:webview_cef_example/features/browser/presentation/widgets/tab_count_button.dart';

class BrowserBottomBar extends StatefulWidget {
  const BrowserBottomBar({super.key});

  @override
  State<BrowserBottomBar> createState() => _BrowserBottomBarState();
}

class _BrowserBottomBarState extends State<BrowserBottomBar> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BrowserBloc>();

    return BlocListener<BrowserBloc, BrowserState>(
      listenWhen: (previous, current) =>
          previous.currentUrl != current.currentUrl,
      listener: (context, state) {
        _textController.text = state.currentUrl;
      },
      child: BlocBuilder<BrowserBloc, BrowserState>(
        builder: (context, state) {
          return Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            color: Color(0xFF8E8E93), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                            cursorColor: Colors.white54,
                            decoration: const InputDecoration(
                              hintText: "Search or enter address",
                              hintStyle: TextStyle(
                                  color: Color(0xFF8E8E93), fontSize: 15),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (url) {
                              if (state.isInitialized) {
                                bloc.add(BrowserUrlLoadRequested(url));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                BottomIconButton(
                  icon: Icons.add,
                  onTap: () {
                    if (state.isInitialized) {
                      bloc.add(BrowserGoHomeRequested());
                    }
                  },
                ),
                const SizedBox(width: 16),
                TabCountButton(
                  count: 11,
                  onTap: () {
                    if (state.isInitialized) {
                      bloc.add(BrowserGoHomeRequested());
                    }
                  },
                ),
                const SizedBox(width: 16),
                BottomIconButton(
                  icon: Icons.menu,
                  onTap: () {
                    showBrowserMenuSheet(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BottomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const BottomIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
