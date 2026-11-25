import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Quick menu actions. The index is the action id sent to the native side
/// (`quickMenuAction`), so keep the order in sync with webview_handler.cc.
enum QuickMenuAction { dismiss, cut, copy, paste, selectAll }

/// Quick menu edit flags (cef_quick_menu_edit_state_flags_t).
const int _quickMenuCanCut = 1 << 1;
const int _quickMenuCanCopy = 1 << 2;
const int _quickMenuCanPaste = 1 << 3;

/// Touch handle state flags (cef_touch_handle_state_flags_t): each update
/// only carries the fields named in its flags.
const int _handleFlagEnabled = 1 << 0;
const int _handleFlagOrientation = 1 << 1;
const int _handleFlagOrigin = 1 << 2;
const int _handleFlagAlpha = 1 << 3;

/// Handle orientation (cef_horizontal_alignment_t).
const int _handleLeft = 0;
const int _handleCenter = 1;

/// Size Chromium hit-tests the handles with; matches kTouchHandleSize in
/// webview_handler.cc.
const double touchHandleSize = 32;

class WebTouchHandle {
  bool enabled = false;
  int orientation = _handleLeft;
  Offset origin = Offset.zero;
  double alpha = 0;

  bool get visible => enabled && alpha > 0;

  Rect get rect => origin & const Size(touchHandleSize, touchHandleSize);
}

/// Long-press text selection state for one browser, as reported by Chromium.
/// Chromium does the selecting and the handle dragging; this only mirrors
/// the state so it can be drawn.
class WebTouchSelection extends ChangeNotifier {
  WebTouchSelection({bool Function()? isEditable})
      : _isEditable = isEditable ?? (() => false);

  /// Whether the page's focused element takes text.
  final bool Function() _isEditable;

  /// Selection rect to place the quick menu around, or null when hidden.
  Rect? menuRect;
  int menuFlags = 0;
  final Map<int, WebTouchHandle> handles = {};

  /// Whether the app clipboard had text when the menu was last shown.
  bool _appClipboardHasText = false;

  bool get canCut => menuFlags & _quickMenuCanCut != 0;
  bool get canCopy => menuFlags & _quickMenuCanCopy != 0;

  /// Chromium only knows its own clipboard; paste also comes from the app
  /// clipboard (see [WebViewController.quickMenuAction]).
  bool get canPaste =>
      menuFlags & _quickMenuCanPaste != 0 ||
      (_appClipboardHasText && _isEditable());

  /// Whether a selection (handles or menu) is on screen.
  /// Handles scrolled off-screen stay enabled but invisible, so only
  /// visible handles count.
  bool get isActive =>
      menuRect != null || handles.values.any((handle) => handle.visible);

  /// Whether [position] is on a visible handle, i.e. a drag starting there
  /// moves the selection rather than the page.
  bool hitsHandle(Offset position) => handles.values
      .any((handle) => handle.visible && handle.rect.contains(position));

  void onQuickMenu(Map<dynamic, dynamic> args) {
    // With the selection scrolled off-screen Chromium still reports a menu,
    // with a zero-height rect; treat that as hidden. (A caret's rect has
    // zero width, so only the height is checked.)
    if (args['visible'] as bool && (args['height'] as int) > 0) {
      menuRect = Rect.fromLTWH(
        (args['x'] as int).toDouble(),
        (args['y'] as int).toDouble(),
        (args['width'] as int).toDouble(),
        (args['height'] as int).toDouble(),
      );
      menuFlags = args['flags'] as int;
      _checkAppClipboard();
    } else {
      menuRect = null;
      menuFlags = 0;
    }
    notifyListeners();
  }

  Future<void> _checkAppClipboard() async {
    // Not Clipboard.hasStrings: the elinux embedder doesn't implement it.
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final hasText = data?.text?.isNotEmpty ?? false;
    if (hasText != _appClipboardHasText) {
      _appClipboardHasText = hasText;
      if (menuRect != null) notifyListeners();
    }
  }

  void onTouchHandle(Map<dynamic, dynamic> args) {
    final handle = handles.putIfAbsent(args['id'] as int, WebTouchHandle.new);
    final flags = args['flags'] as int;
    if (flags & _handleFlagEnabled != 0) {
      handle.enabled = args['enabled'] as bool;
    }
    if (flags & _handleFlagOrientation != 0) {
      handle.orientation = args['orientation'] as int;
    }
    if (flags & _handleFlagOrigin != 0) {
      handle.origin = Offset(
        (args['x'] as int).toDouble(),
        (args['y'] as int).toDouble(),
      );
    }
    if (flags & _handleFlagAlpha != 0) {
      handle.alpha = (args['alpha'] as num).toDouble();
    }
    notifyListeners();
  }
}

/// Draws the selection handles and the cut/copy/paste toolbar over the
/// webview. Only the toolbar takes touches; everything else goes through to
/// the page, where Chromium hit-tests the handles itself.
class WebTouchSelectionOverlay extends StatelessWidget {
  final WebTouchSelection selection;
  final ValueChanged<QuickMenuAction> onAction;

  const WebTouchSelectionOverlay({
    super.key,
    required this.selection,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: selection,
      builder: (context, _) {
        final menuRect = selection.menuRect;
        return Stack(
          children: [
            for (final handle in selection.handles.values)
              if (handle.visible) _buildHandle(context, handle),
            if (menuRect != null) _buildToolbar(context, menuRect),
          ],
        );
      },
    );
  }

  Widget _buildHandle(BuildContext context, WebTouchHandle handle) {
    final color = TextSelectionTheme.of(context).selectionHandleColor ??
        Theme.of(context).colorScheme.primary;
    const knob = 22.0;
    const corner = Radius.circular(knob / 2);
    Widget shape(BorderRadius radius) => Container(
          width: knob,
          height: knob,
          decoration: BoxDecoration(color: color, borderRadius: radius),
        );

    // Chromium puts the selection point on the top edge of the handle rect:
    // at its right end for the left handle, at its left end for the right
    // handle and in the middle for the insertion (caret) handle.
    final Widget knobWidget;
    if (handle.orientation == _handleCenter) {
      // A teardrop pointing up: the square corner rotated to the top.
      knobWidget = Positioned(
        left: (touchHandleSize - knob) / 2,
        top: knob * (math.sqrt2 - 1) / 2,
        child: Transform.rotate(
          angle: math.pi / 4,
          child: shape(const BorderRadius.only(
            topRight: corner,
            bottomLeft: corner,
            bottomRight: corner,
          )),
        ),
      );
    } else if (handle.orientation == _handleLeft) {
      knobWidget = Positioned(
        right: 0,
        top: 0,
        child: shape(const BorderRadius.only(
          topLeft: corner,
          bottomLeft: corner,
          bottomRight: corner,
        )),
      );
    } else {
      knobWidget = Positioned(
        left: 0,
        top: 0,
        child: shape(const BorderRadius.only(
          topRight: corner,
          bottomLeft: corner,
          bottomRight: corner,
        )),
      );
    }

    return Positioned.fromRect(
      rect: handle.rect,
      child: IgnorePointer(
        child: Opacity(
          opacity: handle.alpha.clamp(0.0, 1.0),
          child: Stack(clipBehavior: Clip.none, children: [knobWidget]),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, Rect menuRect) {
    final localizations = MaterialLocalizations.of(context);
    final items = <(String, QuickMenuAction)>[
      if (selection.canCut) (localizations.cutButtonLabel, QuickMenuAction.cut),
      if (selection.canCopy)
        (localizations.copyButtonLabel, QuickMenuAction.copy),
      if (selection.canPaste)
        (localizations.pasteButtonLabel, QuickMenuAction.paste),
      (localizations.selectAllButtonLabel, QuickMenuAction.selectAll),
    ];
    return Positioned.fill(
      child: TextSelectionToolbar(
        anchorAbove: Offset(menuRect.center.dx, menuRect.top),
        anchorBelow:
            Offset(menuRect.center.dx, menuRect.bottom + touchHandleSize),
        children: [
          for (var i = 0; i < items.length; i++)
            TextSelectionToolbarTextButton(
              padding:
                  TextSelectionToolbarTextButton.getPadding(i, items.length),
              onPressed: () => onAction(items[i].$2),
              child: Text(items[i].$1),
            ),
        ],
      ),
    );
  }
}
