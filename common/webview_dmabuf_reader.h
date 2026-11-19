#ifndef WEBVIEW_DMABUF_READER_H_
#define WEBVIEW_DMABUF_READER_H_

#include <cstdint>
#include <vector>

#include "include/cef_render_handler.h"

// Reads the pixels of a Linux OnAcceleratedPaint frame (a dmabuf) back to the
// CPU, for screenshots on the GPU texture path where OnPaint never runs.
//
// It imports the dmabuf as an EGLImage into its own surfaceless GLES context
// and reads it with glReadPixels. Call it only on one thread (the CEF UI
// thread), and only inside OnAcceleratedPaint: the buffer goes back to CEF's
// pool when that callback returns.
class DmabufReader {
public:
    ~DmabufReader();

    // Fills |rgba| with the visible part of the frame, top row first, 4 bytes
    // per pixel in R, G, B, A order. Returns false if the frame can't be read.
    bool Read(const CefAcceleratedPaintInfo &info, int fallback_width,
              int fallback_height, std::vector<uint8_t> &rgba, int &width,
              int &height);

private:
    bool EnsureContext();

    void *display_ = nullptr; // EGLDisplay
    void *context_ = nullptr; // EGLContext
    bool init_failed_ = false;
};

#endif // WEBVIEW_DMABUF_READER_H_
