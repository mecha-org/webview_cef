/// Bit values of `cef_media_access_permission_types_t`, used when
/// [WebviewPermissionRequest.isMedia] is true (getUserMedia/getDisplayMedia).
class MediaPermission {
  MediaPermission._();
  static const int deviceAudioCapture = 1 << 0;
  static const int deviceVideoCapture = 1 << 1;
  static const int desktopAudioCapture = 1 << 2;
  static const int desktopVideoCapture = 1 << 3;
}

/// Bit values of `cef_permission_request_types_t`, used when
/// [WebviewPermissionRequest.isMedia] is false. Only the commonly handled
/// types are listed; any other bit may still appear in the mask.
class PromptPermission {
  PromptPermission._();
  static const int cameraPanTiltZoom = 1 << 1;
  static const int cameraStream = 1 << 2;
  static const int clipboard = 1 << 4;
  static const int storageAccessTopLevel = 1 << 5;
  static const int diskQuota = 1 << 6;
  static const int localFonts = 1 << 7;
  static const int geolocation = 1 << 8;
  static const int idleDetection = 1 << 11;
  static const int micStream = 1 << 12;
  static const int midiSysex = 1 << 13;
  static const int multipleDownloads = 1 << 14;
  static const int notifications = 1 << 15;
  static const int keyboardLock = 1 << 16;
  static const int pointerLock = 1 << 17;
  static const int protectedMediaIdentifier = 1 << 18;
  static const int storageAccess = 1 << 20;
  static const int windowManagement = 1 << 23;
  static const int fileSystemAccess = 1 << 24;
  static const int sensors = 1 << 28;
}

/// Mirrors `cef_permission_request_result_t`.
enum PermissionPromptResult { accept, deny, dismiss, ignore }

/// A pending permission request from a page. Answer it exactly once with
/// [WebviewManager.respondToPermissionRequest].
class WebviewPermissionRequest {
  /// Unique per [isMedia] kind; media and prompt ids are separate spaces.
  final int requestId;

  /// True for camera/microphone/screen capture (mask of [MediaPermission]),
  /// false for everything else (mask of [PromptPermission]).
  final bool isMedia;

  /// Origin of the requesting frame, e.g. `https://meet.example.com/`.
  final String origin;

  /// Bit mask of requested permissions.
  final int permissions;

  const WebviewPermissionRequest({
    required this.requestId,
    required this.isMedia,
    required this.origin,
    required this.permissions,
  });

  bool has(int bit) => (permissions & bit) != 0;

  @override
  bool operator ==(Object other) =>
      other is WebviewPermissionRequest &&
      other.requestId == requestId &&
      other.isMedia == isMedia;

  @override
  int get hashCode => Object.hash(requestId, isMedia);

  @override
  String toString() =>
      'WebviewPermissionRequest(id: $requestId, media: $isMedia, origin: $origin, permissions: 0x${permissions.toRadixString(16)})';
}
