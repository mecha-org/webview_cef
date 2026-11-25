import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_cef/webview_cef.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? clipboard;
  setUp(() {
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      // Like the elinux embedder: getData works, hasStrings isn't
      // implemented.
      if (call.method == 'Clipboard.getData') {
        return clipboard == null ? null : {'text': clipboard};
      }
      if (call.method == 'Clipboard.hasStrings') {
        throw MissingPluginException();
      }
      return null;
    });
  });

  Map<String, Object> menu({int flags = 0}) => {
        'visible': true,
        'x': 0,
        'y': 0,
        'width': 10,
        'height': 10,
        'flags': flags,
      };

  Future<WebTouchSelection> shown({
    required bool editable,
    int flags = 0,
  }) async {
    final selection = WebTouchSelection(isEditable: () => editable);
    selection.onQuickMenu(menu(flags: flags));
    await pumpEventQueue();
    return selection;
  }

  test('Paste is offered for app clipboard text in an editable field',
      () async {
    clipboard = 'from the address bar';
    expect((await shown(editable: true)).canPaste, isTrue);
  });

  test('no Paste outside editable fields', () async {
    clipboard = 'text';
    expect((await shown(editable: false)).canPaste, isFalse);
  });

  test('no Paste when neither clipboard has text', () async {
    expect((await shown(editable: true)).canPaste, isFalse);
  });

  test("Chromium's own paste flag still counts", () async {
    expect((await shown(editable: false, flags: 1 << 3)).canPaste, isTrue);
  });
}
