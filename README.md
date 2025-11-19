# Chorus Application Images

This directory contains Docker images and scripts for running applications on the Chorus-TRE platform.

## License and Usage Restrictions

Any use of the software for purposes other than academic research, including for commercial purposes, shall be requested in advance from [CHUV](mailto:pactt.legal@chuv.ch).

## Acknowledgments

This project has received funding from the Swiss State Secretariat for Education, Research and Innovation (SERI) under contract number 23.00638, as part of the Horizon Europe project "EBRAINS 2.0".

---

## Directory Structure

```
images/
├── core/              # Core scripts and utilities for building apps
│   ├── init/          # Init container scripts (privileged setup)
│   ├── app/           # Application container scripts (non-root)
│   └── shared/        # Build-time utilities
├── init-container/    # Trusted init container for user setup
├── apps/              # Application image definitions
│   ├── filemanager/
│   ├── fsl/
│   ├── jupyter/
│   ├── matlab/
│   ├── rstudio/
│   ├── spyder/
│   └── vscode/
└── README.md          # This file
```

---

## Getting Started

### For Application Developers

**📖 Read the comprehensive guide:** [core/README.md](./core/README.md)

This guide covers:
- Building Chorus-compatible application images
- UID/GID requirements and security guidelines
- Persistent storage configuration
- Testing and debugging
- Complete examples and checklist

### Quick Links

- **Building your first app:** See [Quick Start](./core/README.md#quick-start) in core/README.md
- **Example applications:** Browse `apps/` directory for real-world examples
- **Init container:** See `init-container/` for user setup container

---

## Available Applications

| Application | Description | Directory |
|-------------|-------------|-----------|
| **File Manager** | Thunar file manager | `apps/filemanager/` |
| **FSL** | FMRIB Software Library (neuroimaging) | `apps/fsl/` |
| **Jupyter** | Jupyter Notebook/Lab | `apps/jupyter/` |
| **MATLAB** | MATLAB with desktop | `apps/matlab/` |
| **RStudio** | RStudio IDE | `apps/rstudio/` |
| **Spyder** | Scientific Python IDE | `apps/spyder/` |
| **VS Code** | Visual Studio Code | `apps/vscode/` |

---

## Architecture Overview

### Init Container Pattern

Chorus uses an **init container pattern** for secure user setup:

1. **Init Container** (privileged, runs as root)
   - Creates workbench user with correct UID/GID
   - Sets up home directory structure
   - Creates workspace symlinks
   - Exports NSS wrapper configuration

2. **Application Container** (unprivileged, runs as user)
   - Runs your application as the workbench user
   - Zero Linux capabilities
   - Read-only root filesystem (future)

### Persistent Storage

Users have access to three workspace types:

| Workspace | Path | Purpose | Backend |
|-----------|------|---------|---------|
| `workspace-local` | `~/workspace-local` | Fast local storage | Local disk |
| `workspace-archive` | `~/workspace-archive` | Long-term storage | S3/MinIO |
| `workspace-scratch` | `~/workspace-scratch` | Shared NFS storage | NFS |

### Configuration Persistence

Apps can persist configuration using `APP_DATA_DIR_ARRAY`:

```dockerfile
ENV APP_DATA_DIR_ARRAY=".config/myapp .local/share/myapp"
```

This creates symlinks from `~/.config/myapp` to persistent storage on `workspace-local`.

---

## Contributing

### Adding a New Application

1. **Create app directory:** `apps/your-app/`
2. **Follow the guide:** Read [core/README.md](./core/README.md)
3. **Use existing apps as templates:** Browse `apps/` for examples
4. **Test thoroughly:** Use non-root user with zero capabilities
5. **Submit PR:** Include Dockerfile, build script, and any config files

### Updating Core Scripts

**⚠️ Caution:** Core scripts affect ALL applications

- **init/**: Init container scripts (privileged operations)
- **app/**: Application scripts (non-privileged operations)
- **shared/**: Build-time utilities (chorus-utils.sh)

When updating:
1. Test with multiple applications
2. Update documentation
3. Update init-container if init/ scripts change
4. Consider backward compatibility

---

## Security Considerations

### UID/GID Ranges

**Reserved ranges:**
- `0-999`: System users
- `1001-9999`: **Chorus users (DO NOT USE IN DOCKERFILES)**
- `10000+`: Application-specific users (if needed)

### Capabilities

All applications run with:
- ✅ Non-root user (UID from workbench spec)
- ✅ Zero Linux capabilities (`capabilities: drop: [ALL]`)
- ✅ No new privileges (`securityContext.allowPrivilegeEscalation: false`)
- ✅ Read-only root filesystem (future)

### Best Practices

- Never create users in UID range 1001-9999
- Don't hardcode UID/GID in Dockerfiles
- Use high ports (≥ 1024)
- Write to `/tmp` or `$HOME` only
- Test with `--user 1234:1001 --cap-drop=ALL`

---

## Build System

### Registry Configuration

Images are built and pushed to Harbor registry:

```bash
REGISTRY="harbor.build.chorus-tre.ch"
REGISTRY_NAMESPACE="chorus"
```

### Cache Configuration

Build cache is stored in MinIO:

```bash
CACHE_REGISTRY="minio.build.chorus-tre.ch"
CACHE_NAMESPACE="buildcache"
```

### Building an App

Each app has a `build.sh` script:

```bash
cd apps/myapp
./build.sh
```

This will:
1. Copy core scripts into build context
2. Build image with BuildKit
3. Push to Harbor registry
4. Clean up temporary files

---

## Troubleshooting

### Common Issues

**Problem:** User appears as UID instead of username

**Solution:** Check that `libnss-wrapper` is installed in app image

---

**Problem:** Permission denied errors

**Solution:** Check file permissions, ensure group 1001 can write if needed

---

**Problem:** App fails to start

**Solution:** Check logs for NSS wrapper errors, verify entrypoint script is executable

---

**Problem:** Config not persisting

**Solution:** Verify `APP_DATA_DIR_ARRAY` is set and `2-symlink-appdata.sh` is included

---

## Getting Help

- **Documentation:** [core/README.md](./core/README.md)
- **Examples:** Browse `apps/` directory
- **Issues:** https://github.com/chorus-tre/chorus/issues
- **Init Container:** See `init-container/README.md`

---

## References

- [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Linux Capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html)
- [NSS Wrapper](https://cwrap.org/nss_wrapper.html)
- [BuildKit Documentation](https://docs.docker.com/build/buildkit/)
