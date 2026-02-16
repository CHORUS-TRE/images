# Chorus Init Container

This is a **trusted, minimal init container** used exclusively for workbench user setup.

## Purpose

The init container runs as **root with limited capabilities** to:
1. Create the workbench user and group
2. Set up home directory structure
3. Create symlinks to persistent storage (workspace-local, workspace-archive, workspace-scratch)
4. Create base config directories for app data persistence
5. Export NSS wrapper files for the main container

## Scripts Included

The init container includes these scripts from `core/init/`:
- `docker-entrypoint.sh` - Main entrypoint
- `1-create-user.sh` - Creates user/group, exports NSS files
- `2-symlink-workspace.sh` - Creates workspace symlinks and config directories

## Security

**This image runs with elevated privileges** (root + capabilities), therefore:

- ✅ Only contains minimal, audited scripts
- ✅ Built from trusted Ubuntu 24.04 base
- ✅ No user-controllable code
- ✅ Only used during pod initialization (short-lived)
- ✅ Read-only root filesystem when deployed
- ✅ Resource limits enforced by operator

## Build

```bash
cd images/app-init
docker build -t ghcr.io/chorus-tre/app-init:v1.0.0 .
docker push ghcr.io/chorus-tre/app-init:v1.0.0
```

## Dependencies

- `bash` - For running entrypoint scripts
- `passwd` - Provides `useradd`, `groupadd` commands
- `coreutils` - Basic utilities (`chown`, `chmod`, `mkdir`, etc.)
- `findutils` - Provides `find` command

## Compatibility

**Supports:** Ubuntu-based app containers (22.04, 24.04)

The main app container must:
- Have `libnss-wrapper` installed
- Use `/docker-entrypoint.sh` as its entrypoint
- Be Ubuntu-based (for libc compatibility)

## Maintenance

When updating entrypoint scripts:
1. Update scripts in `core/init/`
2. Rebuild this image
3. Update image reference in operator configuration
4. Test with representative app images
