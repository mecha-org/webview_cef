import 'package:webview_cef/src/webview.dart';
import 'package:webview_cef/src/webview_permission.dart';

typedef TitleChangeCb = void Function(String title);
typedef UrlChangeCb = void Function(String url);
/* Log severity levels. from CEF include/internal/cef_types.h
  0:default logging (currently info logging)
  1:verbose logging or debug logging
  2:info logging
  3:warning logging
  4:error logging
  5:fatal logging
  99:disable logging to file for all messages, and to stderr for messages with severity less than fatal
 */
typedef LoadStartCb = void Function(WebViewController controller, String url);
typedef LoadStopCb = void Function(WebViewController controller, String url);
typedef OnLoadErrorCb = void Function(
  WebViewController controller,
  int errorCode,
  String errorText,
  String failedUrl,
  bool isMainFrame,
);

typedef OnConsoleMessage = void Function(
    int level, String message, String source, int line);

typedef OnBeforeDownloadCb = void Function(
  WebViewController controller,
  int downloadId,
  String url,
  String suggestedName,
  String contentDisposition,
  String mimeType,
  int totalBytes,
);

typedef OnDownloadUpdatedCb = void Function(
  WebViewController controller,
  int downloadId,
  String url,
  String fullPath,
  int receivedBytes,
  int totalBytes,
  int currentSpeed,
  int percentComplete,
  bool isInProgress,
  bool isComplete,
  bool isCanceled,
  bool isInterrupted,
  int interruptReason,
);

/// A page asked for a permission. Answer with
/// [WebviewManager.respondToPermissionRequest]; until then the page waits.
typedef OnPermissionRequestCb = void Function(
  WebViewController controller,
  WebviewPermissionRequest request,
);

/// A request reported by [OnPermissionRequestCb] went away unanswered
/// (navigation, browser closed). Hide any UI for it; responding is a no-op.
typedef OnPermissionDismissedCb = void Function(
  WebViewController controller,
  int requestId,
  bool isMedia,
);

class WebviewEventsListener {
  TitleChangeCb? onTitleChanged;
  UrlChangeCb? onUrlChanged;
  OnConsoleMessage? onConsoleMessage;
  LoadStartCb? onLoadStart;
  LoadStopCb? onLoadEnd;
  OnLoadErrorCb? onLoadError;
  OnBeforeDownloadCb? onBeforeDownload;
  OnDownloadUpdatedCb? onDownloadUpdated;
  OnPermissionRequestCb? onPermissionRequest;
  OnPermissionDismissedCb? onPermissionDismissed;

  WebviewEventsListener({
    this.onTitleChanged,
    this.onUrlChanged,
    this.onConsoleMessage,
    this.onLoadStart,
    this.onLoadEnd,
    this.onLoadError,
    this.onBeforeDownload,
    this.onDownloadUpdated,
    this.onPermissionRequest,
    this.onPermissionDismissed,
  });
}
