# micapipe

[micapipe](https://micapipe.readthedocs.io/) is a multimodal MRI processing
pipeline from the MICA Lab (Montreal Neurological Institute). From a BIDS dataset
it produces ready-to-use, modality-based connectomes (structural, functional,
geodesic distance, and microstructural profile covariance) across several atlases.

It is a **command-line BIDS-app**, not a GUI tool. In Chorus it runs like the other
command-line neuro apps (ANTs, MRtrix3, FSL): the app opens a terminal in which the
`micapipe` command and its whole toolchain are already on `PATH`.

## Running it

```bash
micapipe -bids /path/to/bids -out /path/to/derivatives \
         -sub HC001 -ses 01 -fs_licence "$FS_LICENSE" \
         -threads 6 -proc_structural
```

`FS_LICENSE` is pre-set in the environment (see below). See the
[micapipe docs](https://micapipe.readthedocs.io/en/latest/) for the full list of
processing modules (`-proc_structural`, `-proc_surf`, `-proc_func`, `-proc_dwi`,
`-post_structural`, `-GD`, `-MPC`, `-SC`, …).

## FreeSurfer license

micapipe uses FreeSurfer internally and requires a FreeSurfer license. The license
is injected by the workbench-operator via the `FREESURFER_LICENSE` environment
variable, using the same `freesurfer` secret as the FreeSurfer and CiCLONE apps.
The `.bash_profile` writes it to `$HOME/license.txt` and exports `FS_LICENSE` at
startup. To request a license: https://surfer.nmr.mgh.harvard.edu/registration.html

## Packaging notes (rebuild on Ubuntu 24.04)

Upstream ships micapipe as a Neurodocker image on **Ubuntu 18.04**
(`micalab/micapipe:v0.2.3`). This image is a from-scratch rebuild of the same
pinned stack on **Ubuntu 24.04** to match the Chorus app model. The tool versions
mirror upstream (FreeSurfer 7.3.2, FSL 6.0.2, AFNI, ANTs 2.3.4, MRtrix3 3.0.1,
Connectome Workbench 1.3.2, dcm2niix v1.0.20190902, MATLAB MCR R2017b, c3d 1.0.0,
Miniconda 22.11.1). The following sources had to be substituted because the
originals are dead or 18.04-specific:

- **FreeSurfer 7.3.2** — `ftp://` → `https://` (identical ubuntu18 tarball).
- **ANTs 2.4.1** — prebuilt binary, bumped from upstream's 2.3.4. ANTsX publishes no
  prebuilt binary for any 2.3.x release and the original Dropbox asset returns 403, so
  we use the earliest official Linux release (the ubuntu-22.04 build runs on 24.04).
- **Connectome Workbench 1.3.2** — installed from the exact NeuroDebian `.deb`
  (`1.3.2-2~nd16.04+1`); the HCP zip for 1.3.2 is no longer hosted.
- **FIX 1.068** — the upstream download URL is dead (404). `FIXPATH` is wired and
  the settings file is staged, but the MATLAB-compiled FIX binary is **not**
  bundled. Drop it into `/opt/fix1.068` manually if ICA-FIX denoising is needed.
- **apt package names** — mapped to their 24.04 equivalents (`lsb-release`,
  `libarchive-tools`, `libgl1`, `libncurses6`, …).

### Known build risks (verify in CI)

This is a large, version-locked stack ported to a newer base; the highest-risk
steps, in order, are:

1. **Connectome Workbench .deb** — a xenial package; its Qt dependencies are
   resolved against 24.04's Qt5. Fallback: the still-hosted HCP
   `workbench-linux64-v1.5.0.zip`.
2. **FastSurfer** (optional surface engine) — old conda env + model-weight
   download; guarded so it degrades instead of failing the build. Remove the block
   entirely if FastSurfer surfaces are not needed (FreeSurfer recon-all is the
   default).
3. **MATLAB MCR R2017b** on 24.04 — needs `libncurses6` rather than `libncurses5`.
4. **R packages** — upstream pins R 3.x-era versions; on 24.04 we use CRAN R 4.x and
   run `install_R_env.sh` best-effort (these packages are only used by FSL-FIX, not
   by micapipe's core processing).
