/*
 * MIT-SHM disable wrapper
 * 
 * This library intercepts X11 shared memory extension functions to prevent
 * Wine from using MIT-SHM, which crashes in containerized Xpra environments.
 *
 * Compile: gcc -shared -fPIC -o noshm.so noshm.c -lX11 -lXext
 * Usage: LD_PRELOAD=/path/to/noshm.so wine program.exe
 */

#define _GNU_SOURCE
#include <X11/Xlib.h>
#include <X11/extensions/XShm.h>

/* Intercept XShmQueryExtension to always return False (SHM not available) */
Bool XShmQueryExtension(Display *dpy) {
    (void)dpy;
    return False;
}

/* Intercept XShmQueryVersion to always return False */
Bool XShmQueryVersion(Display *dpy, int *major, int *minor, Bool *pixmaps) {
    (void)dpy;
    if (major) *major = 0;
    if (minor) *minor = 0;
    if (pixmaps) *pixmaps = False;
    return False;
}

/* Intercept XShmAttach to always fail */
Bool XShmAttach(Display *dpy, XShmSegmentInfo *shminfo) {
    (void)dpy;
    (void)shminfo;
    return False;
}

/* Intercept XShmDetach */
Bool XShmDetach(Display *dpy, XShmSegmentInfo *shminfo) {
    (void)dpy;
    (void)shminfo;
    return True;
}

/* Intercept XShmPutImage to always fail */
Bool XShmPutImage(Display *dpy, Drawable d, GC gc, XImage *image,
                  int src_x, int src_y, int dst_x, int dst_y,
                  unsigned int width, unsigned int height, Bool send_event) {
    (void)dpy; (void)d; (void)gc; (void)image;
    (void)src_x; (void)src_y; (void)dst_x; (void)dst_y;
    (void)width; (void)height; (void)send_event;
    return False;
}

/* Intercept XShmGetImage to always fail */
Bool XShmGetImage(Display *dpy, Drawable d, XImage *image,
                  int x, int y, unsigned long plane_mask) {
    (void)dpy; (void)d; (void)image;
    (void)x; (void)y; (void)plane_mask;
    return False;
}

/* Intercept XShmCreateImage to return NULL */
XImage *XShmCreateImage(Display *dpy, Visual *visual, unsigned int depth,
                        int format, char *data, XShmSegmentInfo *shminfo,
                        unsigned int width, unsigned int height) {
    (void)dpy; (void)visual; (void)depth; (void)format;
    (void)data; (void)shminfo; (void)width; (void)height;
    return NULL;
}

/* Intercept XShmCreatePixmap to return None */
Pixmap XShmCreatePixmap(Display *dpy, Drawable d, char *data,
                        XShmSegmentInfo *shminfo, unsigned int width,
                        unsigned int height, unsigned int depth) {
    (void)dpy; (void)d; (void)data; (void)shminfo;
    (void)width; (void)height; (void)depth;
    return None;
}

/* Intercept XShmPixmapFormat */
int XShmPixmapFormat(Display *dpy) {
    (void)dpy;
    return 0;
}
