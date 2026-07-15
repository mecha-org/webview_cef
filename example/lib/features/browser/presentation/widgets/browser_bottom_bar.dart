import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_cef_example/features/browser/bloc/browser_bloc.dart';
import 'package:webview_cef_example/features/browser/presentation/widgets/browser_menu_sheet.dart';
import 'package:webview_cef_example/features/browser/presentation/widgets/browser_suggestions_panel.dart';
import 'package:webview_cef_example/features/browser/presentation/widgets/tab_count_button.dart';

class BrowserBottomBar extends StatefulWidget {
  const BrowserBottomBar({super.key});

  @override
  State<BrowserBottomBar> createState() => _BrowserBottomBarState();
}

class _BrowserBottomBarState extends State<BrowserBottomBar> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    if (_focusNode.hasFocus) {
      _showOverlay();
      context
          .read<BrowserBloc>()
          .add(BrowserSearchQueryChanged(_textController.text));
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final bloc = context.read<BrowserBloc>();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 72, // Float above the 72px bottom bar
          child: Material(
            color: Colors.transparent,
            child: TapRegion(
              groupId: 'browser_search',
              child: BlocProvider.value(
                value: bloc,
                child: BlocBuilder<BrowserBloc, BrowserState>(
                  builder: (context, state) {
                    if (state.searchResults.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return BrowserSuggestionsPanel(
                      textController: _textController,
                      focusNode: _focusNode,
                      bloc: bloc,
                      state: state,
                      onTapItem: () {
                        _hideOverlay();
                        _focusNode.unfocus();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
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
          return TapRegion(
            groupId: 'browser_search',
            onTapOutside: (event) {
              _hideOverlay();
              _focusNode.unfocus();
              context
                  .read<BrowserBloc>()
                  .add(const BrowserSearchQueryChanged(''));
            },
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      focusNode: _focusNode,
                      controller: _textController,
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor: const WidgetStatePropertyAll(
                        Color(0xFF1C1C1E),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(
                            color: Colors.white10,
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16),
                      ),
                      constraints: const BoxConstraints(
                        minHeight: 48,
                        maxHeight: 48,
                      ),
                      leading: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF8E8E93),
                        size: 18,
                      ),
                      hintText: "Search or enter address",
                      hintStyle: const WidgetStatePropertyAll(
                        TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 15,
                        ),
                      ),
                      textStyle: const WidgetStatePropertyAll(
                        TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      onChanged: (value) {
                        bloc.add(BrowserSearchQueryChanged(value));
                      },
                      onSubmitted: (url) {
                        if (state.isInitialized) {
                          bloc.add(BrowserUrlLoadRequested(url));
                          bloc.add(const BrowserSearchQueryChanged(''));
                          _hideOverlay();
                          _focusNode.unfocus();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  BottomIconButton(
                    icon: Icons.add,
                    onTap: () {
                      if (state.isInitialized) {
                        bloc.add(BrowserGoHomeRequested());
                        bloc.add(const BrowserSearchQueryChanged(''));
                        _hideOverlay();
                        _focusNode.unfocus();
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  TabCountButton(
                    count: 11,
                    onTap: () {
                      if (state.isInitialized) {
                        bloc.add(BrowserGoHomeRequested());
                        bloc.add(const BrowserSearchQueryChanged(''));
                        _hideOverlay();
                        _focusNode.unfocus();
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  BottomIconButton(
                    icon: Icons.menu,
                    onTap: () {
                      _hideOverlay();
                      _focusNode.unfocus();
                      showBrowserMenuSheet(context);
                    },
                  ),
                ],
              ),
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
