# Chorus Application Images - Core Scripts and Development Guide

This directory contains the core scripts and utilities for building Chorus-compatible application images.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Core Directory Structure](#core-directory-structure)
3. [Building an Application Image](#building-an-application-image)
4. [Development Guidelines](#development-guidelines)
5. [Init Container](#init-container)
6. [Example Applications](#example-applications)
7. [Testing Your App](#testing-your-app)
8. [Getting Help](#getting-help)

---

## Quick Start

### Minimal App Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
WORKDIR /apps/${APP_NAME}

# Install your application
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        myapp=${APP_VERSION} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV APP_CMD="/usr/bin/myapp"
ENV PROCESS_NAME="myapp"
ENV APP_DATA_DIR_ARRAY=""

# Install Chorus core scripts (includes libnss-wrapper + entrypoint)
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
```

### Build Script Pattern

```bash
#!/bin/sh
set -e

APP_NAME="myapp"
APP_VERSION="1.0.0"

# Copy core scripts into build context
cp -r ../../core ./core
trap "rm -rf ./core" EXIT

docker buildx build \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    -t "myapp:${APP_VERSION}" \
    .
```

---

## Core Directory Structure

The `core/` directory contains scripts organized by execution context:

```
core/
├── init/              # Init container scripts (runs as root during pod init)
│   ├── docker-entrypoint-init.sh
│   ├── 1-create-user.sh
│   └── 2-symlink-workspace.sh
├── app/               # Application scripts (runs as non-root user)
│   ├── docker-entrypoint.sh
│   ├── 1-copy-config.sh
│   └── 2-symlink-appdata.sh
└── shared/            # Build-time utilities (used by both)
    └── chorus-utils.sh
```

**Important**: Application Dockerfiles should ONLY use scripts from `app/` and `shared/`. Never include scripts from `init/` - those are handled by the trusted init container.

---

## Building an Application Image

### 1. Choose Base Image

Use Ubuntu 22.04 or 24.04:

```dockerfile
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]
```

### 2. Set Build Arguments

```dockerfile
ARG APP_NAME
ARG APP_VERSION
WORKDIR /apps/${APP_NAME}
```

### 3. Install Your Application

```dockerfile
ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
        your-packages-here && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### 4. Set Environment Variables

```dockerfile
ENV APP_CMD="/usr/bin/myapp"
ENV PROCESS_NAME="myapp"
ENV APP_DATA_DIR_ARRAY=""  # Optional: space-separated list of config dirs to persist
```

**Environment Variable Descriptions:**

| Variable | Required | Example | Purpose |
|----------|----------|---------|---------|
| `APP_CMD` | Yes | `"/usr/bin/code"` | Command to run the app |
| `PROCESS_NAME` | Yes | `"code"` | Process name for health checks |
| `APP_DATA_DIR_ARRAY` | Optional | `".config/Code"` | Config directories to persist (space-separated) |

### 5. Install Chorus Core Scripts

Choose the appropriate pattern based on your needs:

#### Basic Installation (Most Apps)

```dockerfile
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /
```

#### With App Data Persistence

If your app sets `APP_DATA_DIR_ARRAY`, add the appdata script:

```dockerfile
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    cp /tmp/core_scripts/app/2-symlink-appdata.sh /docker-entrypoint.d/
```

#### With Static Config Files

If you need to copy static config files to user's home directory:

```dockerfile
ENV CONFIG_ARRAY=".bash_profile"  # Files to copy from /apps/${APP_NAME}/config/

COPY ./config/ /apps/${APP_NAME}/config/

RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    cp /tmp/core_scripts/app/1-copy-config.sh /docker-entrypoint.d/
```

#### With Terminal Support

For scientific applications that need terminal emulator:

```dockerfile
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh -a terminal && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /
```

**chorus-utils.sh Options:**
- `-a terminal`: Install terminal emulator (xfce4-terminal)
- Add additional `-a` flags as needed for other utilities

### 6. Set Entrypoint

```dockerfile
ENTRYPOINT ["/docker-entrypoint.sh"]
```

### Decision Tree: Which Scripts Do I Need?

1. **All apps need:**
   - `shared/chorus-utils.sh` (with optional `-a` flags)
   - `app/docker-entrypoint.sh`

2. **Does your app need persistent config storage?**
   - YES → Set `APP_DATA_DIR_ARRAY` and include `app/2-symlink-appdata.sh`
   - NO → Skip appdata script

3. **Does your app have static config files to copy?**
   - YES → Set `CONFIG_ARRAY`, copy config files, and include `app/1-copy-config.sh`
   - NO → Skip config copy script

4. **Does your app need a terminal emulator?**
   - YES → Use `chorus-utils.sh -a terminal`
   - NO → Use `chorus-utils.sh` without flags

---

## Development Guidelines

### UID/GID Requirements ⚠️

#### Reserved UID Ranges

Chorus reserves specific UID ranges for different purposes:

| Range | Purpose | Managed By |
|-------|---------|------------|
| `0-999` | System users (root, daemon, nobody) | Base image |
| `1001-9999` | **Chorus users** (workbench users) | **Operator (DO NOT USE)** |
| `10000+` | Application-specific users (if needed) | App Dockerfile |

#### ❌ NEVER Create Users in Range 1001-9999

**DO NOT do this in your Dockerfile:**
```dockerfile
# ❌ BAD - Creates UID collision!
RUN useradd --uid 1234 myapp-user
RUN groupadd --gid 1001 myapp-group
```

**Why?** This creates a **UID collision** with Chorus users:
- Workbench user might be assigned UID 1234
- When user bypasses `libnss_wrapper`, they appear as "myapp-user" instead of their real name
- **Security impact:** Audit trail confusion, wrong usernames in logs

#### ✅ Correct Approach: Don't Create Users

**Best practice:**
```dockerfile
# ✅ GOOD - No user creation
FROM ubuntu:24.04

# Install your application
RUN apt-get update && \
    apt-get install -y myapp && \
    rm -rf /var/lib/apt/lists/*

# Don't create users - let init container handle it
```

**The init container will:**
- Create the user with the correct UID (from workbench spec)
- Set up home directory
- Configure NSS wrapper

#### ✅ If You MUST Create a User, Use UID ≥ 10000

If your app absolutely requires a pre-created user:

```dockerfile
# ✅ ACCEPTABLE - Uses safe UID range
RUN useradd --uid 10001 --gid 10001 myapp-service
RUN chown -R 10001:10001 /opt/myapp
```

**Note:** The actual workbench user will still run as their assigned UID (e.g., 1234), not as `myapp-service`.

### Base Image Requirements

#### Ubuntu-Based Images Only

Chorus currently supports **Ubuntu-based images only** (22.04 or 24.04):

```dockerfile
FROM ubuntu:24.04  # ✅ Supported
FROM ubuntu:22.04  # ✅ Supported
FROM alpine:latest # ❌ NOT supported (different libc, useradd syntax)
FROM fedora:latest # ❌ NOT supported (different package manager)
```

**Why?** The init container uses Ubuntu 24.04 with:
- GNU libc (not musl)
- `useradd`/`groupadd` (not Alpine's `adduser`)
- `libnss-wrapper` (must be compatible across images)

### Required Packages

#### libnss-wrapper (Required)

**Your app image MUST include `libnss-wrapper`** compiled for the same Ubuntu version as your app for libc compatibility.

**Why required:**
- libnss-wrapper is a shared library compiled against a specific glibc version
- Ubuntu 24.04 uses glibc 2.39, Ubuntu 22.04 uses glibc 2.35
- Binary incompatibility causes crashes if versions don't match
- Each app must have its own libc-compatible version

**Installation:**

```dockerfile
RUN apt-get update && \
    apt-get install -y libnss-wrapper && \
    rm -rf /var/lib/apt/lists/*
```

**Recommended: Use `chorus-utils.sh`**

```dockerfile
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh
    # Installs libnss-wrapper + VirtualGL + entrypoint directory
```

This installs libnss-wrapper with the correct libc version for your app's Ubuntu version.

### Persistent Data Configuration

#### APP_DATA_DIR_ARRAY

Use this to persist application configuration across restarts:

```dockerfile
ENV APP_DATA_DIR_ARRAY=".config/myapp .local/share/myapp .myapp"
```

**What happens:**
1. Init container creates symlinks:
   - `/home/alice/.config/myapp` → `/mnt/workspace-local/app_data/1234/.config/myapp`
2. App writes to `~/.config/myapp`
3. Data persists to storage backend (local/S3)
4. Restored on next pod start

**Supported paths:**
- **Relative paths** (recommended): `.config/myapp`, `.local/share/myapp`
  - Relative to user's home directory
  - Preserves directory structure on storage
- **Absolute paths**: `/opt/myapp/config`
  - Less common, use if needed

### File Permissions Best Practices

#### Don't Hardcode Ownership

**❌ BAD:**
```dockerfile
RUN chown -R 1234:1001 /opt/myapp
```

**✅ GOOD:**
```dockerfile
# Leave owned by root, make readable by all
RUN chmod -R 755 /opt/myapp
```

Or if you need writable directories:
```dockerfile
# Make writable by group 1001 (chorus group)
RUN mkdir -p /opt/myapp/data && \
    chgrp 1001 /opt/myapp/data && \
    chmod 770 /opt/myapp/data
```

#### Writable Directories for Apps

If your app needs to write to directories outside `$HOME`:

**Option 1: Use group permissions**
```dockerfile
RUN mkdir -p /opt/myapp/cache && \
    chgrp 1001 /opt/myapp/cache && \
    chmod 770 /opt/myapp/cache
```

**Option 2: Write to /tmp**
```dockerfile
ENV TMPDIR=/tmp/myapp
RUN mkdir -p /tmp/myapp && chmod 1777 /tmp/myapp
```

### Security Considerations

#### Read-Only Root Filesystem (Future)

Your app should be compatible with read-only root filesystems:

**Writable locations:**
- ✅ `/tmp` (always writable)
- ✅ `$HOME` (user's home directory)
- ✅ Mounted volumes (`/mnt/workspace-*`)
- ❌ `/opt`, `/usr`, `/etc` (read-only in future)

**Prepare now:**
```dockerfile
# Don't write to these at runtime:
# /var/log, /var/cache, /var/run, /opt, /usr
# Use /tmp or $HOME instead
```

#### Capabilities

Apps run with **zero Linux capabilities**:
```yaml
capabilities:
  drop: [ALL]
```

**Your app cannot:**
- Bind to privileged ports (< 1024)
- Change file ownership (no `CAP_CHOWN`)
- Create users (no `CAP_SETUID`)
- Mount filesystems (no `CAP_SYS_ADMIN`)

**Use high ports:**
```dockerfile
# ❌ Port 80 requires CAP_NET_BIND_SERVICE
EXPOSE 80

# ✅ Use high ports
EXPOSE 8080
```

---

## Init Container

The init container (`../init-container/`) is a **trusted, minimal init container** used exclusively for workbench user setup.

### Purpose

The init container runs as **root with limited capabilities** to:
1. Create the workbench user and group
2. Set up home directory structure
3. Create symlinks to persistent storage (workspace-local, workspace-archive, workspace-scratch)
4. Create base config and data directories for app data persistence
5. Export NSS wrapper files for the main container

### Scripts Included

The init container includes these scripts from `core/init/`:
- `docker-entrypoint-init.sh` - Main entrypoint
- `1-create-user.sh` - Creates user/group, exports NSS files
- `2-symlink-workspace.sh` - Creates workspace symlinks, config and data directories

### Security

**This image runs with elevated privileges** (root + capabilities), therefore:

- ✅ Only contains minimal, audited scripts
- ✅ Built from trusted Ubuntu 24.04 base
- ✅ No user-controllable code
- ✅ Only used during pod initialization (short-lived)
- ✅ Read-only root filesystem when deployed
- ✅ Resource limits enforced by operator

### Build

```bash
cd images/init-container
docker build -t ghcr.io/chorus-tre/init-container:v1.0.0 .
docker push ghcr.io/chorus-tre/init-container:v1.0.0
```

### Compatibility

**Supports:** Ubuntu-based app containers (22.04, 24.04)

The main app container must:
- Have `libnss-wrapper` installed
- Use `/docker-entrypoint.sh` as its entrypoint
- Be Ubuntu-based (for libc compatibility)

---

## Example Applications

### Simple App (No Persistence)

```dockerfile
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
ARG APP_NAME
ARG APP_VERSION
WORKDIR /apps/${APP_NAME}

# Install app...

ENV APP_CMD="myapp"
ENV PROCESS_NAME="myapp"
ENV APP_DATA_DIR_ARRAY=""

RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
```

### App with Config Persistence

```dockerfile
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
ARG APP_NAME
ARG APP_VERSION
WORKDIR /apps/${APP_NAME}

# Install app...

ENV APP_CMD="myapp"
ENV PROCESS_NAME="myapp"
ENV APP_DATA_DIR_ARRAY=".config/myapp .local/share/myapp"

RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    cp /tmp/core_scripts/app/2-symlink-appdata.sh /docker-entrypoint.d/

ENTRYPOINT ["/docker-entrypoint.sh"]
```

### Complete Example (FSL)

See `../apps/fsl/Dockerfile` for a complete real-world example with:
- Terminal support
- Static config files
- Custom installation procedure

---

## Testing Your App

### Test as Non-Root User

```bash
# Build image
docker build -t myapp:test .

# Test with non-root user and zero capabilities
docker run -it --rm \
  --user 1234:1001 \
  --cap-drop=ALL \
  --security-opt=no-new-privileges:true \
  -e CHORUS_USER=testuser \
  -e CHORUS_UID=1234 \
  -e CHORUS_GROUP=chorus \
  -e CHORUS_GID=1001 \
  -e APP_CMD="echo 'test'" \
  myapp:test
```

### Check for UID Collisions

```bash
# Inspect /etc/passwd in your image
docker run --rm myapp:test cat /etc/passwd | awk -F: '{print $3}' | sort -n

# Look for UIDs in range 1001-9999
# If found, change them to ≥ 10000 or remove the user creation
```

---

## Checklist for New Apps

- [ ] Based on Ubuntu 22.04 or 24.04
- [ ] No users created in UID range 1001-9999
- [ ] Installs `libnss-wrapper` (via `chorus-utils.sh` or explicit install)
- [ ] Uses `/docker-entrypoint.sh` as entrypoint (copied from `core/app/`)
- [ ] Sets `APP_CMD`, `PROCESS_NAME` env vars
- [ ] Sets `APP_DATA_DIR_ARRAY` for config persistence (if needed)
- [ ] Doesn't hardcode UID/GID ownership
- [ ] Writable directories use group 1001 permissions
- [ ] Works with zero capabilities (no privileged operations)
- [ ] Uses high ports (≥ 1024)
- [ ] Tested with `--user 1234:1001 --cap-drop=ALL`

---

## Getting Help

For questions or issues:
- Check existing app Dockerfiles in `../apps/` for examples
- Review the init container setup in `../init-container/`
- File bugs at https://github.com/chorus-tre/chorus/issues
- Consult the Chorus-TRE documentation

---

## References

- [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Linux Capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html)
- [NSS Wrapper](https://cwrap.org/nss_wrapper.html)
