# Chorus Application Images

This repository contains Docker images for **applications** that run inside a Chorus workspace (xpra-served GUI apps), and Helm charts for **services** that the workbench-operator deploys inside those workspaces (MLflow, PostgreSQL, …).

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
│   └── vscode/
├── services/          # Helm charts for workspace services
│   ├── mlflow/
│   └── postgres/
└── README.md          # This file
```

---

## Categories

Apps and services are tagged with one of the following categories, surfaced in the Chorus catalog UI. The set is **shared** between apps and services to keep filtering consistent.

| Category | Examples |
|----------|----------|
| `Data Science` | JupyterLab, RStudio, MLflow |
| `Development` | VS Code, SciTerminal |
| `Neuroscience` | Brainstorm, FreeSurfer, FSL, MRtrix3 |
| `Productivity` | OnlyOffice, File Manager |

Apps set this in their `labels` file as `ch.chorus-tre.app.category`. Services set it in their `Chart.yaml` `annotations` as `ch.chorus-tre.service.category`. Adding a new category requires a coordinated update to the Chorus backend / web UI catalogs — propose it via an issue first.

---

## Changelog

Both apps (`ch.chorus-tre.app.changelog` in their `labels` file) and services (`ch.chorus-tre.service.changelog` annotation in `Chart.yaml`) carry a short changelog string surfaced in the Chorus catalog UI when a new version of the app/service is released. The audience is the end user, so keep it short and only mention things that actually impact them. The field must never be empty — every release of an app or service ships some user-visible improvement, even if minor.

- **App / service software version updates** (the upstream program changed) — say so explicitly: e.g. *"Updated PostgreSQL to 18.3"*, *"Updated MLflow to 3.8.0"*.
- **Anything else** (chart-level repackaging, network policy adjustments, internal helm-chart restructuring, dependency bumps that don't change the deployed program version) — use a generic phrase: e.g. *"Security and stability improvements"*, *"Stability improvements"*.

---

# Applications

## Getting Started

> **Note:** Applications require the Chorus operator for license injection and user setup. For local testing, create the required Secrets in a Colima cluster.

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
| **ANTs** | Advanced Normalization Tools for brain and image mapping | `apps/ants/` |
| **ARX** | Data anonymization tool for sensitive personal data | `apps/arx/` |
| **Benchmark** | Performance benchmarking tool for Chorus environment | `apps/benchmark/` |
| **BIDSificator** | Tool for converting neuroimaging data to BIDS format | `apps/bidsificator/` |
| **BIDS I/O** | Input/output utility for BIDS formatted neuroimaging datasets | `apps/bidsio/` |
| **Brainstorm** | MEG and EEG analysis application for brain imaging data | `apps/brainstorm/` |
| **Browser** | Open-source Chromium browser for safer, faster, more stable web access | `apps/browser/` |
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
| **Localizer Win** | Windows version of Localizer running via Wine | `apps/localizer-win/` |
| **Matlab** | Numerical computing environment and programming language, used for signal processing and computational mathematics | `apps/matlab/` |
| **MRtrix3** | Advanced tools for the analysis of diffusion MRI data including tractography and connectomics | `apps/mrtrix/` |
| **OnlyOffice** | Office suite for document, spreadsheet, and presentation editing | `apps/onlyoffice/` |
| **ROBEX** | Robust brain extraction tool for T1-weighted MRI using a random forest classifier | `apps/robex/` |
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

## Labels

Each app has a `labels` file that defines metadata embedded into the Docker image as OCI labels. These labels are read by the backend sync job to populate the app catalog.

### Label Reference

| Label | Required | Description |
|-------|----------|-------------|
| `org.opencontainers.image.title` | Yes | Display name of the app |
| `org.opencontainers.image.description` | Yes | Short description |
| `org.opencontainers.image.url` | No | Upstream project homepage |
| `org.opencontainers.image.documentation` | No | Documentation URL |
| `org.opencontainers.image.licenses` | Yes | SPDX license identifier |
| `org.opencontainers.image.authors` | Yes | Author or organization |
| `org.opencontainers.image.vendor` | Yes | Always `Chorus-TRE` |
| `org.opencontainers.image.source` | Yes | This repository (`https://github.com/CHORUS-TRE/images`) |
| `ch.chorus-tre.app.icon` | Yes | Set to `AUTO_POPULATED_FROM_LOGO_PNG` (replaced at build time) |
| `ch.chorus-tre.app.changelog` | No | Changelog text |
| `ch.chorus-tre.app.license-url` | No | Direct link to the license file |
| `ch.chorus-tre.app.category` | Yes | One of the categories listed above |
| `ch.chorus-tre.app.stability` | Yes | App stability level (see below) |
| `ch.chorus-tre.resources.*` | No | Resource constraints (CPU, memory, ephemeral storage, shared memory) |
| `ch.chorus-tre.build.app-version` | Yes | Upstream application version |
| `ch.chorus-tre.build.pkg-rel` | Yes | Package release number (increment on rebuild without version change) |
| `ch.chorus-tre.build.cache-mode` | No | BuildKit cache mode (`max` or `min`, defaults to `max`) |
| `ch.chorus-tre.build.arg.*` | No | Build arguments passed to `docker build` |

### Stability

The `ch.chorus-tre.app.stability` label indicates the readiness level of an app:

| Value | Meaning | In Chorus |
|-------|---------|-----------|
| ready | Production-ready, fully tested and available to all users | Available |
| beta | Feature-complete but still under validation | Available with beta tag |
| alpha | Early testing, may have known issues | Not Available but built |
| off | Deactivated — the app should not be built or made available | Not built |

Set this in the app's `labels` file:

```
ch.chorus-tre.app.stability="ready"
```

When an app needs to be temporarily disabled (e.g., due to a critical bug), change its stability to `off`. The CI pipeline will skip image builds for `off` apps.

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

- **App developer guide:** [core/README.md](./core/README.md)
- **App examples:** Browse the `apps/` directory
- **Init container:** See `app-init/README.md`
- **Issues:** https://github.com/CHORUS-TRE/images/issues

---

# Services

## Getting Started

Services are Helm charts deployed by the **workbench-operator** inside a Chorus workspace, on demand. Each service ships:

- A **`Chart.yaml`** with Helm-native fields plus annotations consumed by the Chorus backend / catalog.
- A **`logo.png`** at chart root. The Chorus backend reads it from `chart.Files["logo.png"]` when syncing the catalog (no `icon:` field needed in `Chart.yaml`, no build-time substitution).
- A **`chorus.yaml`** at chart root that the operator reads at install time to know what values to inject, what credentials secret to generate, and what connection URL to surface in `WorkspaceStatus`.
- **NetworkPolicy / CiliumNetworkPolicy** templates restricting traffic to/from the service Pod (see *Network policy* below).

This split keeps `WorkspaceService` CRs thin — they only specify the chart pointer and per-instance overrides; everything else lives next to the chart.

---

## Available Services

| Service | Description | Directory |
|---------|-------------|-----------|
| **MLflow** | Open source platform for the machine learning lifecycle (bundled PostgreSQL) | `services/mlflow/` |
| **PostgreSQL** | PostgreSQL database on Kubernetes | `services/postgres/` |

---

## Chart.yaml Annotations

Each service `Chart.yaml` carries the same descriptive metadata as apps' OCI labels. Keys with a Helm-native equivalent (`name`, `description`, `version`, `appVersion`, `home`, `sources`, `maintainers`, `icon`) use the native field; everything else lives under `annotations:`.

| Field | Where in Chart.yaml | Description |
|---|---|---|
| Chart name | `name` | Helm chart name |
| Version | `version` | Helm chart semver |
| App version | `appVersion` | Upstream application version |
| Chart description | `description` | One-line description for chart maintainers (Helm convention). Not surfaced in the catalog UI. |
| Project home | `home` | Upstream project homepage |
| Source repo | `sources: [...]` | This repository (`https://github.com/CHORUS-TRE/images`) |
| Maintainers | `maintainers: [...]` | CHORUS-TRE maintainers |
| `org.opencontainers.image.title` | `annotations` | User-facing display name shown in the catalog (e.g. `"MLflow"`, `"PostgreSQL"`). |
| `org.opencontainers.image.description` | `annotations` | User-facing one-liner shown in the catalog. Marketing copy from the upstream project, not chart-author wording. |
| `org.opencontainers.image.authors` | `annotations` | Upstream project's canonical attribution from the project's website footer (e.g. `"The PostgreSQL Global Development Group"`). |
| `org.opencontainers.image.documentation` | `annotations` | Documentation URL |
| `org.opencontainers.image.licenses` | `annotations` | SPDX license identifier |
| `org.opencontainers.image.vendor` | `annotations` | Always `Chorus-TRE` |
| `ch.chorus-tre.service.changelog` | `annotations` | Changelog text |
| `ch.chorus-tre.service.license-url` | `annotations` | Direct link to the license file |
| `ch.chorus-tre.service.category` | `annotations` | One of the categories listed above |
| `ch.chorus-tre.service.stability` | `annotations` | Service stability level (same scale as apps: `ready`, `beta`, `alpha`, `off`) |

---

## `chorus.yaml`

Each service chart ships a `chorus.yaml` at chart root. The workbench-operator reads it via `chart.Files` at install time to know what defaults the chart needs without forcing users to put them in every `WorkspaceService` CR.

```yaml
# services/<svc>/chorus.yaml
values:
  <chart-key>:
    extraVolumes:
      - name: artifacts
        persistentVolumeClaim:
          claimName: "{{.ReleaseName}}-artifacts"
    extraVolumeMounts:
      - name: artifacts
        mountPath: /<svc>/data
    resources:
      limits:
        cpu: 2000m
        memory: 4Gi
        # ephemeral-storage: ""
      # requests:
      #   cpu: ""
      #   memory: ""
      #   ephemeral-storage: ""

credentials:
  secretName: "{{.ReleaseName}}-creds"
  paths:
    - <chart-path-to-password>
    - <another-path>|<paired-path>      # values share the same generated secret entry

connectionInfoTemplate: "<scheme>://{{.ReleaseName}}.{{.Namespace}}"
```

| Top-level key | Description |
|---|---|
| `values` | Helm values overlay merged below the user's `values:` and `computedValues:` from the `WorkspaceService` CR. The operator template-substitutes `{{.ReleaseName}}`, `{{.Namespace}}`, `{{.SecretName}}` over the entire block before merging. |
| `credentials.secretName` | Name of the Secret the operator creates for generated passwords. Supports template placeholders. The operator falls back to `<release-name>-creds` when neither chorus.yaml nor the CR specifies a name. |
| `credentials.paths` | List of dot-notation paths in the rendered chart values whose leaf is a password the operator should generate. Each path becomes a key in the credentials Secret. Multiple paths joined with `|` share the same generated value. |
| `connectionInfoTemplate` | Surfaced in `WorkspaceStatus.services[].connectionInfo`. Supports the same template placeholders as above. |

The `WorkspaceService` CR fields `credentials.*` and `connectionInfoTemplate` override these defaults when set; otherwise they fall through to the metadata.

For resources, the working convention (mirroring apps) is to set **limits only** and leave requests commented out — the cluster supplies tiny default requests.

---

## Network Policy

Service Pods must not be reachable from outside the workspace. Each service chart ships a `templates/networkpolicy.yaml` and a `templates/ciliumnetworkpolicy.yaml` (toggle by `networkPolicy.enabled` and `networkPolicy.enabledL7Waf` in `values.yaml`).

Default posture:

- **Ingress**: deny by default. Allow only same-namespace pods (the workspace), all ports. Setting `networkPolicy.ingress` **replaces** that default with whatever the env supplies (e.g., letting the chorus-gateway namespace reach a service that's also exposed externally — the env values must restate same-namespace if it's still wanted).
- **Egress**: allow same-namespace traffic only, all ports. Setting `networkPolicy.egress` **replaces** that default — same precedence as ingress. **DNS is intentionally NOT allowed here**; it's granted by the workspace-level `CiliumNetworkPolicy` that the workbench-operator creates in the namespace, so the chart doesn't restate it. Charts installed standalone (outside a workspace) therefore have no DNS egress unless the operator is providing it; that's the intended posture (no egress beyond the platform-managed allows).
- **Note on port restriction**: chart NetPols intentionally do not restrict to specific service ports. The workspace-level `CiliumNetworkPolicy` selects every pod in the namespace and grants all-port intra-namespace traffic, so any chart-level port restriction would be overridden by union-of-allows semantics. If a chart needs real per-port enforcement (e.g. for standalone installs outside a workspace), set `networkPolicy.ingress` / `networkPolicy.egress` in env values with the desired `ports` clause.
- **`networkPolicy.ingress: []` does NOT deny-all**: Helm/Sprig treats an empty slice as a falsy value, so the template's `{{- if .Values.networkPolicy.ingress }}` falls through to the same-namespace default. To truly deny all ingress, set `networkPolicy.enabled: false` and ship a separate, custom-named NetworkPolicy / CiliumNetworkPolicy with `ingress: []` and `policyTypes: [Ingress]`. Same caveat applies to `networkPolicy.egress: []`.

`enabledL7Waf: false` (default) renders a standard K8s NetworkPolicy. `enabledL7Waf: true` renders a CiliumNetworkPolicy with the same shape — required when a chart needs L7 HTTP filtering (path/method allowlists).

---

## Contributing

### Adding a New Service

1. **Create chart directory:** `services/your-service/`
2. **Drop a `Chart.yaml`** with the fields and annotations listed above (use `services/mlflow/Chart.yaml` as a template).
3. **Add a `logo.png`** at chart root (PNG, ideally with transparent background; 512px height works well — convert with `rsvg-convert -h 512 logo.svg -o logo.png` if you start from SVG).
4. **Define defaults in `chorus.yaml`** so the operator can deploy the service with no per-instance configuration.
5. **Add NetworkPolicy + CiliumNetworkPolicy templates** under `templates/`. Default-deny ingress except same-namespace; allow only DNS egress unless the service genuinely needs more.
6. **Test as standalone:** `helm install my-test ./services/your-service` — chart should produce a working release on its own (no operator needed for testing).
7. **Submit PR:** Chart, `chorus.yaml`, `logo.png`, NetPol/CNP templates, and any subchart pin updates.

---

## Troubleshooting

### Common Issues

**Problem:** PVC not bound after `helm install`

**Solution:** The chart's PVC name is derived from `extraVolumes[0].persistentVolumeClaim.claimName` in values; for standalone install make sure that key has a non-empty default in `values.yaml`.

---

**Problem:** Operator deploys the service but `connectionInfo` is empty in `WorkspaceStatus`

**Solution:** Verify the chart's `chorus.yaml` has `connectionInfoTemplate` set; the CR field can override but the metadata default should always be present.

---

**Problem:** Generated credentials secret is missing keys

**Solution:** Each path in `chorus.yaml` `credentials.paths` becomes a Secret key. Confirm the path matches the rendered chart values structure (operator walks the value tree).

---

**Problem:** Subchart's values aren't picked up after a metadata change

**Solution:** Both the operator (chorus.yaml × WorkspaceService values) and Helm (operator-output × chart `values.yaml`) merge arrays the same way: maps merge recursively; slices are wholesale-replaced. So any `extraVolumes`-style array entry in `chorus.yaml` must be **complete** — if the WorkspaceService CR also defines the array, its entries replace yours wholesale.

---

**Problem:** Workspace pods can't reach the service Pod

**Solution:** The chart's NetworkPolicy default-denies cross-namespace ingress. Same-namespace ingress on the service's port is already allowed by the chart default. If the calling pod is in a different namespace, set `networkPolicy.ingress` in the env values — note this **replaces** the default, so include the same-namespace rule too if you still want it.

---

**Problem:** Standalone `helm install ./services/mlflow` fails because chart values don't render

**Solution:** The mlflow chart relies on values that the workbench-operator normally injects from `chorus.yaml`: two generated passwords from the `credentials` block (postgres superuser + the user-DB password, the latter aliased into mlflow's backend-store config via the `|` syntax — three injection points) plus the chart-side computed postgres host. For a standalone install (without the operator) you must pass all four `--set` flags yourself:

```bash
helm install my-mlflow ./services/mlflow \
  --set postgres.settings.superuserPassword.value=<superuserPassword> \
  --set postgres.userDatabase.password.value=<userDbPassword> \
  --set mlflow.backendStore.postgres.host=<mlflow-postgres-host> \
  --set mlflow.backendStore.postgres.password=<userDbPassword>
```

The same four flags are what `helm lint services/mlflow/` needs to render successfully outside the operator — see the chart-author workflow in *Contributing*.

---

## Getting Help

- **Service examples:** Browse the `services/` directory
- **Issues:** https://github.com/CHORUS-TRE/images/issues

---

## References

- [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Linux Capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html)
- [NSS Wrapper](https://cwrap.org/nss_wrapper.html)
- [BuildKit Documentation](https://docs.docker.com/build/buildkit/)
- [Helm Chart.yaml reference](https://helm.sh/docs/topics/charts/#the-chartyaml-file)
