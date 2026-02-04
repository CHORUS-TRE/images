# MIT-SHM Fix for Wine in Containerized Xpra Environments

## Problem

Wine applications crash immediately when running in a container connected to a remote Xpra display with the following error:

```
X Error of failed request:  BadValue (integer parameter out of range for operation)
  Major opcode of failed request:  130 (MIT-SHM)
  Minor opcode of failed request:  3 (X_ShmPutImage)
  Value in failed request:  0xe0
  Serial number of failed request:  2664
```

## Root Cause

The crash occurs because:

1. **MIT-SHM (X11 Shared Memory Extension)** is designed for X11 applications running on the same machine as the X server, where they share the same memory space.

2. In our architecture, the **Wine app container** and the **Xpra server** run in **different Kubernetes pods** (different memory namespaces). They communicate over TCP, not shared memory.

3. When Wine connects to Xpra, Xpra advertises MIT-SHM support (because it works locally), but the shared memory operations fail when Wine tries to use them across the network boundary.

4. **Wine's `UseXShm=N` registry setting doesn't work** because Wine queries the X server for MIT-SHM capability and attempts to use it **before** reading the registry settings.

## Failed Approaches

We tried several approaches that did NOT work:

1. **Wine Registry Setting** (`UseXShm=N` in `HKEY_CURRENT_USER\Software\Wine\X11 Driver`)
   - Wine reads the registry AFTER connecting to X11 and querying extensions
   - The crash happens before the registry is consulted

2. **Environment Variables** (`QT_X11_NO_MITSHM=1`, `_X11_NO_MITSHM=1`)
   - These only affect Qt applications, not Wine's X11 driver

3. **Increasing shared memory** (`--shm-size 2g`)
   - Doesn't help because the app and Xpra are in different pods
   - MIT-SHM fundamentally cannot work across network/pod boundaries

4. **Single-architecture LD_PRELOAD wrapper**
   - Wine runs both 32-bit and 64-bit processes internally
   - A 64-bit-only wrapper doesn't intercept 32-bit Wine processes

## Solution

We created a shared library (`noshm.so`) that intercepts all XShm* functions from libXext and makes them fail gracefully, forcing Wine to fall back to non-SHM rendering.

### Components

1. **`noshm.c`** - C source that intercepts:
   - `XShmQueryExtension()` - Returns False (SHM not available)
   - `XShmQueryVersion()` - Returns False
   - `XShmAttach()` - Returns False
   - `XShmDetach()` - Returns True (no-op)
   - `XShmPutImage()` - Returns False
   - `XShmGetImage()` - Returns False
   - `XShmCreateImage()` - Returns NULL
   - `XShmCreatePixmap()` - Returns None
   - `XShmPixmapFormat()` - Returns 0

2. **Dockerfile** - Builds both 32-bit and 64-bit versions:
   ```dockerfile
   RUN gcc -shared -fPIC -o /usr/lib/x86_64-linux-gnu/noshm.so /tmp/noshm.c -lX11 -lXext && \
       gcc -m32 -shared -fPIC -o /usr/lib/i386-linux-gnu/noshm.so /tmp/noshm.c -lX11 -lXext
   ```

3. **`wine-wrapper.sh`** - Loads both libraries via LD_PRELOAD:
   ```bash
   exec env LD_PRELOAD="/usr/lib/x86_64-linux-gnu/noshm.so /usr/lib/i386-linux-gnu/noshm.so" wine "$@"
   ```

### Why This Works

- **LD_PRELOAD** loads our library before libXext, so our functions are called instead
- The dynamic linker automatically uses the correct architecture (32-bit or 64-bit) for each Wine process
- Wine queries MIT-SHM, gets "not available", and falls back to standard X11 rendering
- Standard X11 rendering works perfectly over Xpra's TCP connection

### Expected Log Output

You will see these harmless warnings (the dynamic linker trying the wrong architecture):
```
ERROR: ld.so: object '/usr/lib/i386-linux-gnu/noshm.so' from LD_PRELOAD cannot be preloaded (wrong ELF class: ELFCLASS32): ignored.
ERROR: ld.so: object '/usr/lib/x86_64-linux-gnu/noshm.so' from LD_PRELOAD cannot be preloaded (wrong ELF class: ELFCLASS64): ignored.
```

This is normal - each process loads the library matching its architecture and ignores the other.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Kubernetes Cluster                        │
│                                                                   │
│  ┌─────────────────────┐         ┌─────────────────────────────┐ │
│  │   Workbench Pod     │   TCP   │      App Pod                │ │
│  │                     │◄───────►│                             │ │
│  │  ┌───────────────┐  │  :80    │  ┌───────────────────────┐  │ │
│  │  │  Xpra Server  │  │         │  │    Wine + Localizer   │  │ │
│  │  │               │  │         │  │                       │  │ │
│  │  │ Advertises    │  │         │  │  LD_PRELOAD=noshm.so  │  │ │
│  │  │ MIT-SHM       │  │         │  │  ↓                    │  │ │
│  │  │ (but can't    │  │         │  │  XShmQueryExtension() │  │ │
│  │  │  work across  │  │         │  │  → Returns False      │  │ │
│  │  │  pods)        │  │         │  │  ↓                    │  │ │
│  │  └───────────────┘  │         │  │  Falls back to        │  │ │
│  │                     │         │  │  standard X11 ✓       │  │ │
│  └─────────────────────┘         │  └───────────────────────┘  │ │
│                                   └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Applicability

This fix is specific to **Wine applications** running in containers with remote Xpra displays. Other applications (native Linux GUI apps) typically handle MIT-SHM unavailability gracefully on their own.

If other Wine-based apps are added to the platform, they should use the same approach:
1. Copy `noshm.c` and the Dockerfile build steps
2. Use the `wine-wrapper.sh` pattern with LD_PRELOAD

## References

- [MIT-SHM Extension](https://www.x.org/releases/current/doc/xextproto/shm.html)
- [Wine X11 Driver](https://wiki.winehq.org/X11_Driver)
- [LD_PRELOAD Technique](https://man7.org/linux/man-pages/man8/ld.so.8.html)

## Date

January 2026
