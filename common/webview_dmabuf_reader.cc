#include "webview_dmabuf_reader.h"

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>

#include <cstdio>
#include <cstring>

#ifndef DRM_FORMAT_ARGB8888
#define DRM_FORMAT_ARGB8888 0x34325241
#endif
#ifndef DRM_FORMAT_ABGR8888
#define DRM_FORMAT_ABGR8888 0x34324241
#endif
#ifndef EGL_PLATFORM_SURFACELESS_MESA
#define EGL_PLATFORM_SURFACELESS_MESA 0x31DD
#endif

namespace {

bool HasExtension(const char *extensions, const char *name)
{
    if (extensions == nullptr)
        return false;
    const size_t len = strlen(name);
    for (const char *p = extensions; (p = strstr(p, name)) != nullptr; p += len)
    {
        if ((p == extensions || p[-1] == ' ') && (p[len] == ' ' || p[len] == '\0'))
            return true;
    }
    return false;
}

void LogOnce(bool &logged, const char *message)
{
    if (logged)
        return;
    logged = true;
    fprintf(stderr, "[webview_cef] screenshot: %s\n", message);
    fflush(stderr);
}

bool g_logged_init = false;
bool g_logged_read = false;

// Restores whatever EGL context was current on this thread.
class ScopedCurrent {
public:
    ScopedCurrent()
        : display_(eglGetCurrentDisplay()),
          context_(eglGetCurrentContext()),
          draw_(eglGetCurrentSurface(EGL_DRAW)),
          read_(eglGetCurrentSurface(EGL_READ)) {}
    ~ScopedCurrent()
    {
        if (display_ != EGL_NO_DISPLAY)
            eglMakeCurrent(display_, draw_, read_, context_);
        else if (EGLDisplay d = eglGetCurrentDisplay(); d != EGL_NO_DISPLAY)
            eglMakeCurrent(d, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    }

private:
    EGLDisplay display_;
    EGLContext context_;
    EGLSurface draw_;
    EGLSurface read_;
};

} // namespace

DmabufReader::~DmabufReader()
{
    if (context_ != nullptr)
        eglDestroyContext(static_cast<EGLDisplay>(display_), static_cast<EGLContext>(context_));
}

bool DmabufReader::EnsureContext()
{
    if (context_ != nullptr)
        return true;
    if (init_failed_)
        return false;
    init_failed_ = true; // cleared on success

    EGLDisplay display = EGL_NO_DISPLAY;
    const char *client_ext = eglQueryString(EGL_NO_DISPLAY, EGL_EXTENSIONS);
    auto get_platform_display = reinterpret_cast<PFNEGLGETPLATFORMDISPLAYEXTPROC>(
        eglGetProcAddress("eglGetPlatformDisplayEXT"));
    if (get_platform_display != nullptr &&
        HasExtension(client_ext, "EGL_MESA_platform_surfaceless"))
    {
        display = get_platform_display(EGL_PLATFORM_SURFACELESS_MESA, EGL_DEFAULT_DISPLAY, nullptr);
    }
    if (display == EGL_NO_DISPLAY)
        display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (display == EGL_NO_DISPLAY || !eglInitialize(display, nullptr, nullptr))
    {
        LogOnce(g_logged_init, "no EGL display");
        return false;
    }

    const char *ext = eglQueryString(display, EGL_EXTENSIONS);
    if (!HasExtension(ext, "EGL_EXT_image_dma_buf_import") ||
        !HasExtension(ext, "EGL_KHR_surfaceless_context"))
    {
        LogOnce(g_logged_init, "EGL lacks dma-buf import or surfaceless contexts");
        return false;
    }

    eglBindAPI(EGL_OPENGL_ES_API);
    EGLConfig config = nullptr;
    if (!HasExtension(ext, "EGL_KHR_no_config_context"))
    {
        const EGLint config_attribs[] = {
            EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
            EGL_NONE,
        };
        EGLint count = 0;
        if (!eglChooseConfig(display, config_attribs, &config, 1, &count) || count < 1)
        {
            LogOnce(g_logged_init, "no EGL config");
            return false;
        }
    }
    const EGLint context_attribs[] = {EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE};
    EGLContext context = eglCreateContext(display, config, EGL_NO_CONTEXT, context_attribs);
    if (context == EGL_NO_CONTEXT)
    {
        LogOnce(g_logged_init, "could not create a GLES context");
        return false;
    }

    display_ = display;
    context_ = context;
    init_failed_ = false;
    return true;
}

bool DmabufReader::Read(const CefAcceleratedPaintInfo &info, int fallback_width,
                        int fallback_height, std::vector<uint8_t> &rgba,
                        int &width, int &height)
{
    if (info.plane_count != 1 || info.planes[0].fd < 0)
        return false;

    // The buffer can be larger than the frame (coded size); the frame is its
    // visible rect.
    int image_w = info.extra.coded_size.width;
    int image_h = info.extra.coded_size.height;
    if (image_w <= 0 || image_h <= 0)
    {
        image_w = fallback_width;
        image_h = fallback_height;
    }
    int x = info.extra.visible_rect.x;
    int y = info.extra.visible_rect.y;
    width = info.extra.visible_rect.width;
    height = info.extra.visible_rect.height;
    if (width <= 0 || height <= 0 || x + width > image_w || y + height > image_h)
    {
        x = y = 0;
        width = image_w;
        height = image_h;
    }
    if (width <= 0 || height <= 0)
        return false;

    if (!EnsureContext())
        return false;

    EGLDisplay display = static_cast<EGLDisplay>(display_);
    ScopedCurrent restore;
    if (!eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, static_cast<EGLContext>(context_)))
    {
        LogOnce(g_logged_read, "could not make the GLES context current");
        return false;
    }

    auto create_image = reinterpret_cast<PFNEGLCREATEIMAGEKHRPROC>(eglGetProcAddress("eglCreateImageKHR"));
    auto destroy_image = reinterpret_cast<PFNEGLDESTROYIMAGEKHRPROC>(eglGetProcAddress("eglDestroyImageKHR"));
    auto image_target_texture = reinterpret_cast<PFNGLEGLIMAGETARGETTEXTURE2DOESPROC>(
        eglGetProcAddress("glEGLImageTargetTexture2DOES"));
    if (create_image == nullptr || destroy_image == nullptr || image_target_texture == nullptr)
    {
        LogOnce(g_logged_read, "EGLImage functions missing");
        return false;
    }

    const auto &plane = info.planes[0];
    std::vector<EGLint> attribs = {
        EGL_WIDTH, image_w,
        EGL_HEIGHT, image_h,
        EGL_LINUX_DRM_FOURCC_EXT,
        static_cast<EGLint>(info.format == CEF_COLOR_TYPE_BGRA_8888 ? DRM_FORMAT_ARGB8888
                                                                    : DRM_FORMAT_ABGR8888),
        EGL_DMA_BUF_PLANE0_FD_EXT, plane.fd,
        EGL_DMA_BUF_PLANE0_OFFSET_EXT, static_cast<EGLint>(plane.offset),
        EGL_DMA_BUF_PLANE0_PITCH_EXT, static_cast<EGLint>(plane.stride),
    };
    if (info.modifier != 0)
    {
        attribs.insert(attribs.end(), {
            EGL_DMA_BUF_PLANE0_MODIFIER_LO_EXT, static_cast<EGLint>(info.modifier & 0xffffffffu),
            EGL_DMA_BUF_PLANE0_MODIFIER_HI_EXT, static_cast<EGLint>(info.modifier >> 32),
        });
    }
    attribs.push_back(EGL_NONE);

    EGLImageKHR image = create_image(display, EGL_NO_CONTEXT, EGL_LINUX_DMA_BUF_EXT, nullptr, attribs.data());
    if (image == EGL_NO_IMAGE_KHR)
    {
        LogOnce(g_logged_read, "could not import the frame as an EGLImage");
        return false;
    }

    GLuint texture = 0, framebuffer = 0;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    image_target_texture(GL_TEXTURE_2D, image);
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);

    bool ok = glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE;
    if (ok)
    {
        // Rows of a texture-backed framebuffer come back in memory order, so
        // row 0 is the top of the page.
        rgba.resize(static_cast<size_t>(width) * height * 4);
        glPixelStorei(GL_PACK_ALIGNMENT, 4);
        glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, rgba.data());
        ok = glGetError() == GL_NO_ERROR;
    }
    if (!ok)
        LogOnce(g_logged_read, "could not read the frame back");

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glDeleteFramebuffers(1, &framebuffer);
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, &texture);
    destroy_image(display, image);
    return ok;
}
