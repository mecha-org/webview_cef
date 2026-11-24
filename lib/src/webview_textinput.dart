import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

mixin WebeViewTextInput implements DeltaTextInputClient {
  @override
  TextEditingValue? currentTextEditingValue;

  @override
  AutofillScope? currentAutofillScope;

  TextInputConnection? _textInputConnection;

  /// Opens the keyboard for the focused web field. [inputHint] comes from the
  /// renderer ("url", "email", "phone", "number", "multiline" or "text") and
  /// picks the matching keyboard layout.
  attachTextInputClient({String inputHint = ''}) {
    // On Windows the OS IME is driven by the native WM_IME pipeline (the Flutter
    // text-input/delta path does not deliver composition for an OSR browser on
    // Windows). Don't claim the IME here so the native path can own it.
    if (Platform.isWindows) {
      return;
    }
    _textInputConnection?.close();
    _textInputConnection = TextInput.attach(
        this,
        TextInputConfiguration(
          inputType: _inputTypeForHint(inputHint),
          enableDeltaModel: true,
        ));
    // show() makes this connection the active IME target so the OS IME composes
    // into it and the framework emits composing deltas we relay to CEF.
    _textInputConnection?.show();
  }

  static TextInputType _inputTypeForHint(String inputHint) {
    switch (inputHint) {
      case 'url':
        return TextInputType.url;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'number':
        return TextInputType.number;
      // 'multiline' (textarea, contenteditable) stays text on purpose: with
      // TextInputType.multiline the embedder inserts "\n" on Enter *and* sends
      // the action that onVirtualAction turns into an Enter key, so the page
      // would get two line breaks.
      default:
        return TextInputType.text;
    }
  }

  detachTextInputClient() {
    _textInputConnection?.close();
  }

  /// Replaces the platform's editing state, e.g. to reset it after an edit
  /// was forwarded to the page.
  void setTextInputEditingValue(TextEditingValue value) {
    currentTextEditingValue = value;
    _textInputConnection?.setEditingState(value);
  }

  updateIMEComposionPosition(double x, double y, double height, Offset offset) {
    // x/y are the caret position inside the webview (logical px), with y at the
    // caret's bottom (the native side reports the element/character bottom);
    // height is the line height. offset is the webview widget's global origin.
    final caretHeight = height > 0 ? height : 20.0;
    // Place a transform whose origin is the caret's TOP in global coordinates,
    // so a local-space caret rect maps back onto the input line.
    final transform = Matrix4.translationValues(
        offset.dx + x, offset.dy + y - caretHeight, 0);
    _textInputConnection?.setEditableSizeAndTransform(
        Size(1, caretHeight), transform);
    // macOS derives the IME candidate-window position from the composing/caret
    // rect transformed by the editable transform above. Without a marked rect
    // the engine has nothing to anchor to and parks the candidate window at the
    // screen's bottom-left corner. Report the caret rect (in editable-local
    // space) so the candidate window tracks the actual caret.
    final caretRect = Rect.fromLTWH(0, 0, 1, caretHeight);
    _textInputConnection?.setComposingRect(caretRect);
    _textInputConnection?.setCaretRect(caretRect);
  }

  @override
  didChangeInputControl(
      TextInputControl? oldControl, TextInputControl? newControl) {
    debugPrint("changed");
  }

  @override
  connectionClosed() {}

  @override
  bool onFocusReceived() => false;

  @override
  insertTextPlaceholder(Size size) {}

  @override
  insertContent(KeyboardInsertedContent content) {}

  @override
  performAction(TextInputAction action) {
    // Send Enter key event when virtual keyboard action button (Enter, Done, Go, Search, etc.) is tapped
    onVirtualAction(action);
  }

  void onVirtualAction(TextInputAction action) {}


  @override
  performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  performSelector(String selectorName) {}

  @override
  removeTextPlaceholder() {}

  @override
  showAutocorrectionPromptRect(int start, int end) {}

  @override
  showToolbar() {}

  @override
  updateEditingValue(TextEditingValue value) {
    onVirtualEditingValue(value);
  }

  void onVirtualEditingValue(TextEditingValue value) {}

  @override
  updateFloatingCursor(RawFloatingCursorPoint point) {}
}
