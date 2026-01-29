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
├── build.py           # Unified build script for all images
├── buildtools/        # Python build library (config, builder, utils)
├── core/              # Core scripts and utilities for building apps
│   ├── init/          # Init container scripts (privileged setup)
│   ├── app/           # Application container scripts (non-root)
│   └── shared/        # Build-time utilities
├── app-init/          # Trusted init container for user setup
├── server/            # Xpra remote desktop server image
├── apps/              # Application image definitions
│   ├── arx/
│   ├── ........
│   ├── bidsificator/
│   ├── ........
│   ├── filemanager/
│   ├── freesurfer/
│   ├── ........
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
- **Init container:** See `app-init/` for user setup container

---

## Available Applications

| Application | Description | Directory |
|-------------|-------------|-----------|
| **ARX** | Data anonymization tool for sensitive personal data | `apps/arx/` |
| **Benchmark** | Performance benchmarking tool for Chorus environment | `apps/benchmark/` |
| **BIDSificator** | Tool for converting neuroimaging data to BIDS format | `apps/bidsificator/` |
| **BIDS I/O** | Input/output utility for BIDS formatted neuroimaging datasets | `apps/bidsio/` |
| **Brainstorm** | MEG and EEG analysis application for brain imaging data | `apps/brainstorm/` |
| **BTV Replay** | Viewer and replay tool for BTV format medical data | `apps/btvreplay/` |
| **Chorus Assistant** | AI-powered assistant for Chorus research environment | `apps/chorus-assistant/` |
| **CiCLONE** | Computational imaging pipeline for neuroimaging analysis | `apps/ciclone/` |
| **dcm2niix** | DICOM to NIfTI converter for neuroimaging data | `apps/dcm2niix/` |
| **File Manager** | Web-based file browser and manager | `apps/filemanager/` |
| **FreeSurfer** | Brain MRI analysis software for cortical and subcortical segmentation | `apps/freesurfer/` |
| **FSL** | Comprehensive library of analysis tools for fMRI, MRI and DTI brain imaging | `apps/fsl/` |
| **HiBoP** | Brain visualization and analysis tool for neuroimaging research | `apps/hibop/` |
| **ITK-SNAP** | Interactive software for medical image segmentation | `apps/itksnap/` |
| **JupyterLab** | Web-based interactive development environment for notebooks, code, and data | `apps/jupyterlab/` |
| **Kiosk** | Kiosk mode browser for controlled web access | `apps/kiosk/` |
| **Localizer** | Brain localization tool for neuroimaging analysis | `apps/localizer/` |
| **OnlyOffice** | Office suite for document, spreadsheet, and presentation editing | `apps/onlyoffice/` |
| **RStudio** | Integrated development environment for R programming language | `apps/rstudio/` |
| **SciTerminal** | Scientific terminal environment for command-line research tools | `apps/sciterminal/` |
| **3D Slicer** | Open-source platform for medical image informatics and visualization | `apps/slicer/` |
| **TRC Anonymizer** | Anonymization tool for TRC format EEG data files | `apps/trcanonymizer/` |
| **Tune Insight** | Privacy-preserving data collaboration platform with JupyterLab interface | `apps/tune-insight/` |
| **Visual Studio Code** | Lightweight source code editor with debugging and Git integration | `apps/vscode/` |

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
4. **Build with:** `python build.py your-app`
5. **Test thoroughly:** Use non-root user with zero capabilities
6. **Submit PR:** Include Dockerfile, labels file, and any config files

### Updating Core Scripts

**⚠️ Caution:** Core scripts affect ALL applications

- **init/**: Init container scripts (privileged operations)
- **app/**: Application scripts (non-privileged operations)
- **shared/**: Build-time utilities (chorus-utils.sh)

When updating:
1. Test with multiple applications
2. Update documentation
3. Update app-init if init/ scripts change
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

All images are built using the unified `build.py` script at the repository root.

### Building an App

```bash
python build.py <app-name>        # Build by app name (e.g., python build.py vscode)
python build.py ./apps/vscode     # Build by path
python build.py server            # Build server image
python build.py app-init          # Build app-init image
```

### Listing Available Apps

```bash
python build.py --list
```

### Dry Run

Preview the build command without executing:

```bash
python build.py <app-name> --dry-run
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REGISTRY` | `harbor.build.chorus-tre.local` | Container registry |
| `REPOSITORY` | `apps` | Repository name |
| `CACHE` | `cache` | Cache repository name |
| `TARGET_ARCH` | `linux/amd64` | Target architecture |
| `OUTPUT` | `docker` | Output type (`docker` or `registry`) |

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
- **Init Container:** See `app-init/README.md`

---

## References

- [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Linux Capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html)
- [NSS Wrapper](https://cwrap.org/nss_wrapper.html)
- [BuildKit Documentation](https://docs.docker.com/build/buildkit/)
